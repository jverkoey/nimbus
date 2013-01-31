//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import "NIDeviceOrientation.h"

#import <QuartzCore/QuartzCore.h>

#import "NIDebuggingTools.h"
#import "NISDKAvailability.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsSupportedOrientation(UIInterfaceOrientation orientation) {
  if (NIIsPad()) {
    return YES;

  } else {
    switch (orientation) {
      case UIInterfaceOrientationPortrait:
      case UIInterfaceOrientationLandscapeLeft:
      case UIInterfaceOrientationLandscapeRight:
        return YES;
      default:
        return NO;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation NIInterfaceOrientation(void) {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;

  // This code used to use the navigator to find the currently visible view controller and
  // fall back to checking its orientation if we didn't know the status bar's orientation.
  // It's unclear when this was actually necessary, though, so this assertion is here to try
  // to find that case. If this assertion fails then the repro case needs to be analyzed and
  // this method made more robust to handle that case.
  NIDASSERT(UIDeviceOrientationUnknown != orient);

  return orient;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsLandscapePhoneOrientation(UIInterfaceOrientation orientation) {
  return NIIsPhone() && UIInterfaceOrientationIsLandscape(orientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGAffineTransform NIRotateTransformForOrientation(UIInterfaceOrientation orientation) {
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return CGAffineTransformMakeRotation((CGFloat)(M_PI * 1.5));

  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return CGAffineTransformMakeRotation((CGFloat)(M_PI / 2.0));

  } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
    return CGAffineTransformMakeRotation((CGFloat)(-M_PI));

  } else {
    return CGAffineTransformIdentity;
  }
}
