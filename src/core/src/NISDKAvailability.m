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

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_6_0
const UIImageResizingMode UIImageResizingModeStretch = -1;
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsPad(void) {
  static NSInteger isPad = -1;
  if (isPad < 0) {
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 1 : 0;
  }
  return isPad > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsPhone(void) {
  static NSInteger isPhone = -1;
  if (isPhone < 0) {
    isPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 1 : 0;
  }
  return isPhone > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIDeviceOSVersionIsAtLeast(double versionNumber) {
  return kCFCoreFoundationVersionNumber >= versionNumber;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat NIScreenScale(void) {
  static int respondsToScale = -1;
  if (respondsToScale == -1) {
    // Avoid calling this anymore than we need to.
    respondsToScale = !!([[UIScreen mainScreen] respondsToSelector:@selector(scale)]);
  }

  if (respondsToScale) {
    return [[UIScreen mainScreen] scale];

  } else {
    return 1;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsRetina(void) {
  return NIScreenScale() == 2.f;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
Class NIUIPopoverControllerClass(void) {
  static Class sClass = nil;
  static BOOL hasChecked = NO;
  if (!hasChecked) {
    hasChecked = YES;
    sClass = NSClassFromString(@"UIPopoverController");
  }
  return sClass;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
Class NIUITapGestureRecognizerClass(void) {
  static Class sClass = nil;
  static BOOL hasChecked = NO;
  if (!hasChecked) {
    hasChecked = YES;

    // An interesting gotcha: UITapGestureRecognizer actually *does* exist in iOS 3.0, but does
    // not conform to all of the same methods that the 3.2 implementation does. This can be
    // really confusing, so instead of returning the class, we'll always return nil on
    // pre-iOS 3.2 devices.
    if (NIDeviceOSVersionIsAtLeast(kCFCoreFoundationVersionNumber_iPhoneOS_3_2)) {
      sClass = NSClassFromString(@"UITapGestureRecognizer");
    }
  }
  return sClass;
}
