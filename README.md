UIScrollView-ScrollAnimation
============================

UIScrollView category with custom timing function for animation of setContentOffset

Background
---
 This work was inspired by this project here:
 https://github.com/plancalculus/MOScrollView


Features
--------

Provides methods

    - (void)setContentOffset:(CGPoint)contentOffset 
          withTimingFunction:(CAMediaTimingFunction *)timingFunction

and 

    - (void)setContentOffset:(CGPoint)contentOffset 
          withTimingFunction:(CAMediaTimingFunction *)timingFunction
                    duration:(CFTimeInterval)duration


Usage
-----

Import `UIScrollView+ScrollAnimation.h` and `UIScrollView+ScrollAnimation.m` into your
project. The implementation uses a `CADisplayLink`, therefore, you
have to add the `QuartzCore` library to your project. As the class
uses automatic refernce counting either your project has to use
automatic reference counting as well.

Exmaple:
``` objc

#import "UIScrollView+ScrollAnimation.h"

@interface MyCollectionViewController : UIViewController
@property (nonatomic, strong) UICollectionView* collectionView;
@end

@implementation MyCollectionViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // call method to slowly scroll up or down, left or right
    [self.collectionView setContentOffset:offsetPoint 
    				   withTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] 
    				   duration:animationDuration];
}

@end

```

Requirements
------------

XCode 4.2 or later and iOS 4 or later as the module uses automatic reference counting. 



License
---

```
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
 
 
 ```