/*
 UIScrollView+ScrollAnimation.h
 
 
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
 https://github.com/plancalculus/MOScrollView
 */

#import <UIKit/UIKit.h>

@interface UIScrollView (ScrollAnimation)
// all methods were derived from: https://github.com/plancalculus/MOScrollView
/**
 *  Sets the contentOffset of the ScrollView and animates the transition. The
 *  animation takes 0.25 seconds.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction;

/**
 *  Sets the contentOffset of the ScrollView and animates the transition.
 *
 * @param contentOffset  A point (expressed in points) that is offset from the
 *                       content view’s origin.
 * @param timingFunction A timing function that defines the pacing of the
 *                       animation.
 * @param duration       Duration of the animation in seconds.
 */
- (void)setContentOffset:(CGPoint)contentOffset
      withTimingFunction:(CAMediaTimingFunction *)timingFunction
                duration:(CFTimeInterval)duration;

@end
