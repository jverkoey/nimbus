//
// Copyright 2011-2012 Jeff Verkoeyen
//
// This code was originally found in Apple's WWDC Session 240 on
// "Polishing Your Interface Rotations" and has been repurposed into a reusable class.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NISnapshotRotation.h"

#import "NIDebuggingTools.h"
#import "NISDKAvailability.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
UIImage* NISnapshotOfViewWithTransparencyOption(UIView* view, BOOL transparency) {
  // Passing 0 as the last argument ensures that the image context will match the current device's
  // scaling mode.
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, !transparency, 0);

  CGContextRef cx = UIGraphicsGetCurrentContext();

  // Views that can scroll do so by modifying their bounds. We want to capture the part of the view
  // that is currently in the frame, so we offset by the bounds of the view accordingly.
  CGContextTranslateCTM(cx, -view.bounds.origin.x, -view.bounds.origin.y);

  [view.layer renderInContext:cx];

  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIImage* NISnapshotOfView(UIView* view) {
  return NISnapshotOfViewWithTransparencyOption(view, NO);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIImageView* NISnapshotViewOfView(UIView* view) {
  UIImage* image = NISnapshotOfView(view);

  UIImageView* snapshotView = [[UIImageView alloc] initWithImage:image];
  snapshotView.frame = view.frame;

  return snapshotView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIImage* NISnapshotOfViewWithTransparency(UIView* view) {
  return NISnapshotOfViewWithTransparencyOption(view, YES);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIImageView* NISnapshotViewOfViewWithTransparency(UIView* view) {
  UIImage* image = NISnapshotOfViewWithTransparency(view);

  UIImageView* snapshotView = [[UIImageView alloc] initWithImage:image];
  snapshotView.frame = view.frame;
  
  return snapshotView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NISnapshotRotation()
@property (nonatomic, readwrite, assign) BOOL isSupportedOS;
@property (nonatomic, readwrite, assign) CGRect frameBeforeRotation;
@property (nonatomic, readwrite, assign) CGRect frameAfterRotation;

@property (nonatomic, readwrite, NI_STRONG) UIImageView* snapshotViewBeforeRotation;
@property (nonatomic, readwrite, NI_STRONG) UIImageView* snapshotViewAfterRotation;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISnapshotRotation

@synthesize isSupportedOS = _isSupportedOS;
@synthesize frameBeforeRotation = _frameBeforeRotation;
@synthesize frameAfterRotation = _frameAfterRotation;
@synthesize snapshotViewBeforeRotation = _snapshotViewBeforeRotation;
@synthesize snapshotViewAfterRotation = _snapshotViewAfterRotation;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<NISnapshotRotationDelegate>)delegate {
  if ((self = [super init])) {
    _delegate = delegate;

    // Check whether this feature is supported or not.
    UIImage* image = [[UIImage alloc] init];
    _isSupportedOS = [image respondsToSelector:@selector(resizableImageWithCapInsets:resizingMode:)];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithDelegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  if (!self.isSupportedOS) {
    return;
  }

  UIView* containerView = [self.delegate containerViewForSnapshotRotation:self];
  UIView* rotationView = [self.delegate rotatingViewForSnapshotRotation:self];

  // The container view must not be the same as the rotation view.
  NIDASSERT(containerView != rotationView);
  if (containerView == rotationView) {
    return;
  }

  self.frameBeforeRotation = rotationView.frame;
  self.snapshotViewBeforeRotation = NISnapshotViewOfView(rotationView);
  [containerView insertSubview:self.snapshotViewBeforeRotation aboveSubview:rotationView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  if (!self.isSupportedOS) {
    return;
  }

  UIView* containerView = [self.delegate containerViewForSnapshotRotation:self];
  UIView* rotationView = [self.delegate rotatingViewForSnapshotRotation:self];

  // The container view must not be the same as the rotation view.
  NIDASSERT(containerView != rotationView);
  if (containerView == rotationView) {
    return;
  }

  self.frameAfterRotation = rotationView.frame;
  
  [UIView setAnimationsEnabled:NO];
  
  self.snapshotViewAfterRotation = NISnapshotViewOfView(rotationView);
  // Set the new frame while maintaining the old frame's height.
  self.snapshotViewAfterRotation.frame = CGRectMake(self.frameBeforeRotation.origin.x,
                                                    self.frameBeforeRotation.origin.y,
                                                    self.frameBeforeRotation.size.width,
                                                    self.snapshotViewAfterRotation.frame.size.height);
  
  UIImage* imageBeforeRotation = self.snapshotViewBeforeRotation.image;
  UIImage* imageAfterRotation = self.snapshotViewAfterRotation.image;

  if ([self.delegate respondsToSelector:@selector(fixedInsetsForSnapshotRotation:)]) {
    UIEdgeInsets fixedInsets = [self.delegate fixedInsetsForSnapshotRotation:self];

    imageBeforeRotation = [imageBeforeRotation resizableImageWithCapInsets:fixedInsets resizingMode:UIImageResizingModeStretch];
    imageAfterRotation = [imageAfterRotation resizableImageWithCapInsets:fixedInsets resizingMode:UIImageResizingModeStretch];
  }

  self.snapshotViewBeforeRotation.image = imageBeforeRotation;
  self.snapshotViewAfterRotation.image = imageAfterRotation;

  [UIView setAnimationsEnabled:YES];

  if (imageAfterRotation.size.height < imageBeforeRotation.size.height) {
    self.snapshotViewAfterRotation.alpha = 0;

    [containerView insertSubview:self.snapshotViewAfterRotation aboveSubview:self.snapshotViewBeforeRotation];

    self.snapshotViewAfterRotation.alpha = 1;

  } else {
    [containerView insertSubview:self.snapshotViewAfterRotation belowSubview:self.snapshotViewBeforeRotation];
    self.snapshotViewBeforeRotation.alpha = 0;
  }

  self.snapshotViewAfterRotation.frame = self.frameAfterRotation;
  self.snapshotViewBeforeRotation.frame = CGRectMake(self.frameAfterRotation.origin.x,
                                                     self.frameAfterRotation.origin.y,
                                                     self.frameAfterRotation.size.width,
                                                     self.snapshotViewBeforeRotation.frame.size.height);

  rotationView.hidden = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  if (!self.isSupportedOS) {
    return;
  }

  UIView* containerView = [self.delegate containerViewForSnapshotRotation:self];
  UIView* rotationView = [self.delegate rotatingViewForSnapshotRotation:self];

  // The container view must not be the same as the rotation view.
  NIDASSERT(containerView != rotationView);
  if (containerView == rotationView) {
    return;
  }

  [self.snapshotViewBeforeRotation removeFromSuperview];
  [self.snapshotViewAfterRotation removeFromSuperview];
  self.snapshotViewBeforeRotation = nil;
  self.snapshotViewAfterRotation = nil;

  rotationView.hidden = NO;
}

@end


@interface NITableViewSnapshotRotation() <NISnapshotRotationDelegate>
@property (nonatomic, readwrite, NI_WEAK) id<NISnapshotRotationDelegate> forwardingDelegate;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewSnapshotRotation

@synthesize forwardingDelegate = _forwardingDelegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<NISnapshotRotationDelegate>)delegate {
  if (delegate == self) {
    [super setDelegate:delegate];

  } else {
    self.forwardingDelegate = delegate;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    self.delegate = self;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelectorToDelegate:(SEL)selector {
  struct objc_method_description description;
  // Only forward the selector if it's part of the protocol.
  description = protocol_getMethodDescription(@protocol(NISnapshotRotationDelegate), selector, NO, YES);

  BOOL isSelectorInProtocol = (description.name != NULL && description.types != NULL);
  return (isSelectorInProtocol && [self.forwardingDelegate respondsToSelector:selector]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)selector {
  if ([super respondsToSelector:selector] == YES) {
    return YES;
    
  } else {
    return [self shouldForwardSelectorToDelegate:selector];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)forwardingTargetForSelector:(SEL)selector {
  if ([self shouldForwardSelectorToDelegate:selector]) {
    return self.forwardingDelegate;

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NISnapshotRotation


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)containerViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation {
  return [self.forwardingDelegate containerViewForSnapshotRotation:snapshotRotation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)rotatingViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation {
  return [self.forwardingDelegate rotatingViewForSnapshotRotation:snapshotRotation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)fixedInsetsForSnapshotRotation:(NISnapshotRotation *)snapshotRotation {
  UIEdgeInsets insets = UIEdgeInsetsZero;

  // Find the right edge of the content view in the coordinate space of the UITableView.
  UIView* rotatingView = [self.forwardingDelegate rotatingViewForSnapshotRotation:snapshotRotation];
  NIDASSERT([rotatingView isKindOfClass:[UITableView class]]);
  if ([rotatingView isKindOfClass:[UITableView class]]) {
    UITableView* tableView = (UITableView *)rotatingView;

    NSArray* visibleCells = tableView.visibleCells;
    if (visibleCells.count > 0) {
      UIView* contentView = [[visibleCells objectAtIndex:0] contentView];
      CGFloat contentViewRightEdge = [tableView convertPoint:CGPointMake(contentView.bounds.size.width, 0) fromView:contentView].x;

      CGFloat fixedRightWidth = tableView.bounds.size.width - contentViewRightEdge;
      CGFloat fixedLeftWidth = MIN(snapshotRotation.frameAfterRotation.size.width, snapshotRotation.frameBeforeRotation.size.width) - fixedRightWidth - 1;
      insets = UIEdgeInsetsMake(0, fixedLeftWidth, 0, fixedRightWidth);
    }
  }
  return insets;
}

@end
