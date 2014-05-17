/*
 UIScrollView+ScrollAnimation.m
 
 
 Created by Jonathan Lott.
 Copyright (c) 2014 A Lott Of Ideas. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 This work was inspired by this project here:
 https://github.com/plancalculus/MOScrollView/tree/master/MOScrollView
 */

#import "UIScrollView+ScrollAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


const static CFTimeInterval kDefaultSetContentOffsetDuration = 0.25;

/// Constants used for Newton approximation of cubic function root.
const static double kApproximationTolerance = 0.00000001;
const static int kMaximumSteps = 10;

@interface ScrollViewTimingDelegate : NSObject

@property (nonatomic, strong) UIScrollView* scrollView;

/// Display link used to trigger event to scroll the view.
@property(nonatomic) CADisplayLink *displayLink;

/// Timing function of an scroll animation.
@property(nonatomic) CAMediaTimingFunction *timingFunction;

/// Duration of an scroll animation.
@property(nonatomic) CFTimeInterval duration;

/// States whether the animation has started.
@property(nonatomic) BOOL animationStarted;

/// Time at the begining of an animation.
@property(nonatomic) CFTimeInterval beginTime;

/// The content offset at the begining of an animation.
@property(nonatomic) CGPoint beginContentOffset;

/// The delta between the contentOffset at the start of the animation and
/// the contentOffset at the end of the animation.
@property(nonatomic) CGPoint deltaContentOffset;

@end

@implementation ScrollViewTimingDelegate

#pragma mark - Set ContentOffset with Custom Animation

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction {
    [self setContentOffset:contentOffset
        withTimingFunction:timingFunction
                  duration:kDefaultSetContentOffsetDuration];
}

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration {
    
    if(!self.scrollView)
        return;
    
    self.duration = duration;
    self.timingFunction = timingFunction;
    
    self.deltaContentOffset = CGPointMinus(contentOffset, self.scrollView.contentOffset);
    
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink
                            displayLinkWithTarget:self
                            selector:@selector(updateContentOffset:)];
        self.displayLink.frameInterval = 1;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
    } else {
        self.displayLink.paused = NO;
    }
}

- (void)updateContentOffset:(CADisplayLink *)displayLink {
    if (self.beginTime == 0.0) {
        self.beginTime = self.displayLink.timestamp;
        self.beginContentOffset = self.scrollView.contentOffset;
    } else {
        CFTimeInterval deltaTime = displayLink.timestamp - self.beginTime;
        
        // Ratio of duration that went by
        CGFloat progress = (CGFloat)(deltaTime / self.duration);
        if (progress < 1.0) {
            // Ratio adjusted by timing function
            CGFloat adjustedProgress = (CGFloat)timingFunctionValue(self.timingFunction, progress);
            if (1 - adjustedProgress < 0.001) {
                [self stopAnimation];
            } else {
                [self updateProgress:adjustedProgress];
            }
        } else {
            [self stopAnimation];
        }
    }
}

- (void)updateProgress:(CGFloat)progress {
    CGPoint currentDeltaContentOffset = CGPointScalarMult(progress, self.deltaContentOffset);
    self.scrollView.contentOffset = CGPointAdd(self.beginContentOffset, currentDeltaContentOffset);
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    self.beginTime = 0.0;
    
    self.scrollView.contentOffset = CGPointAdd(self.beginContentOffset, self.deltaContentOffset);
    
    if (self.scrollView.delegate
        && [self.scrollView.delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        // inform delegate about end of animation
        [self.scrollView.delegate scrollViewDidEndScrollingAnimation:self.scrollView];
    }
}


CGPoint CGPointScalarMult(CGFloat s, CGPoint p) {
    return CGPointMake(s * p.x, s * p.y);
}

CGPoint CGPointAdd(CGPoint p, CGPoint q) {
    return CGPointMake(p.x + q.x, p.y + q.y);
}

CGPoint CGPointMinus(CGPoint p, CGPoint q) {
    return CGPointMake(p.x - q.x, p.y - q.y);
}

double cubicFunctionValue(double a, double b, double c, double d, double x) {
    return (a*x*x*x)+(b*x*x)+(c*x)+d;
}

double cubicDerivativeValue(double a, double b, double c, double __unused d, double x) {
    /// Derivation of the cubic (a*x*x*x)+(b*x*x)+(c*x)+d
    return (3*a*x*x)+(2*b*x)+c;
}

double rootOfCubic(double a, double b, double c, double d, double startPoint) {
    // We use 0 as start point as the root will be in the interval [0,1]
    double x = startPoint;
    double lastX = 1;
    
    // Approximate a root by using the Newton-Raphson method
    int y = 0;
    while (y <= kMaximumSteps && fabs(lastX - x) > kApproximationTolerance) {
        lastX = x;
        x = x - (cubicFunctionValue(a, b, c, d, x) / cubicDerivativeValue(a, b, c, d, x));
        y++;
    }
    
    return x;
}

double timingFunctionValue(CAMediaTimingFunction *function, double x) {
    float a[2];
    float b[2];
    float c[2];
    float d[2];
    
    [function getControlPointAtIndex:0 values:a];
    [function getControlPointAtIndex:1 values:b];
    [function getControlPointAtIndex:2 values:c];
    [function getControlPointAtIndex:3 values:d];
    
    // Look for t value that corresponds to provided x
    double t = rootOfCubic(-a[0]+3*b[0]-3*c[0]+d[0], 3*a[0]-6*b[0]+3*c[0], -3*a[0]+3*b[0], a[0]-x, x);
    
    // Return corresponding y value
    double y = cubicFunctionValue(-a[1]+3*b[1]-3*c[1]+d[1], 3*a[1]-6*b[1]+3*c[1], -3*a[1]+3*b[1], a[1], t);
    
    return y;
}
@end

@implementation UIScrollView (ScrollAnimation)

- (ScrollViewTimingDelegate*)scrollViewTimingDelegate
{
    ScrollViewTimingDelegate* timingDelegate = objc_getAssociatedObject(self, "scrollViewTimingDelegate");
    return timingDelegate;
}

- (void)setScrollViewTimingDelegate:(ScrollViewTimingDelegate*)timingDelegate
{
    objc_setAssociatedObject(self, "scrollViewTimingDelegate", timingDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
{
    if(![self scrollViewTimingDelegate])
    {
        ScrollViewTimingDelegate* timingDelegate = [[ScrollViewTimingDelegate alloc] init];
        timingDelegate.scrollView = self;
        [self setScrollViewTimingDelegate:timingDelegate];
    }
    [[self scrollViewTimingDelegate] setContentOffset:contentOffset withTimingFunction:timingFunction];
}

- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration
{
    if(![self scrollViewTimingDelegate])
    {
        ScrollViewTimingDelegate* timingDelegate = [[ScrollViewTimingDelegate alloc] init];
        timingDelegate.scrollView = self;
        [self setScrollViewTimingDelegate:timingDelegate];
    }
    [[self scrollViewTimingDelegate] setContentOffset:contentOffset withTimingFunction:timingFunction duration:duration];
}
@end
