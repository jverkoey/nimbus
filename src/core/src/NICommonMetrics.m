//
// Copyright 2011-2014 NimbusKit
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

#import "NICommonMetrics.h"

#import "NISDKAvailability.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

CGFloat NIMinimumTapDimension(void) {
  return 44;
}

CGFloat NIToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
  return (NIIsPad()
          ? 44
          : (UIInterfaceOrientationIsPortrait(orientation)
             ? 44
             : 33));
}

UIViewAnimationCurve NIStatusBarAnimationCurve(void) {
  return UIViewAnimationCurveEaseIn;
}

NSTimeInterval NIStatusBarAnimationDuration(void) {
  return 0.3;
}

UIViewAnimationCurve NIStatusBarBoundsChangeAnimationCurve(void) {
  return UIViewAnimationCurveEaseInOut;
}

NSTimeInterval NIStatusBarBoundsChangeAnimationDuration(void) {
  return 0.35;
}

CGFloat NIStatusBarHeight(void) {
  CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];

  // We take advantage of the fact that the status bar will always be wider than it is tall
  // in order to avoid having to check the status bar orientation.
  CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);

  return statusBarHeight;
}

NSTimeInterval NIDeviceRotationDuration(BOOL isFlippingUpsideDown) {
  return isFlippingUpsideDown ? 0.8 : 0.4;
}

UIEdgeInsets NICellContentPadding(void) {
  return UIEdgeInsetsMake(10, 10, 10, 10);
}
