//
// Copyright 2011-2014 NimbusKit
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

BOOL NIIsPad(void) {
  static NSInteger isPad = -1;
  if (isPad < 0) {
    isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 1 : 0;
  }
  return isPad > 0;
}

BOOL NIIsPhone(void) {
  static NSInteger isPhone = -1;
  if (isPhone < 0) {
    isPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 1 : 0;
  }
  return isPhone > 0;
}

BOOL NIIsTintColorGloballySupported(void) {
  static NSInteger isTintColorGloballySupported = -1;
  if (isTintColorGloballySupported < 0) {
    UIView* view = [[UIView alloc] init];
    isTintColorGloballySupported = [view respondsToSelector:@selector(tintColor)];
  }
  return isTintColorGloballySupported > 0;
}

BOOL NIDeviceOSVersionIsAtLeast(double versionNumber) {
  return kCFCoreFoundationVersionNumber >= versionNumber;
}

CGFloat NIScreenScale(void) {
  return [[UIScreen mainScreen] scale];
}

BOOL NIIsRetina(void) {
  return NIScreenScale() > 1.f;
}

Class NIUIPopoverControllerClass(void) {
  return [UIPopoverController class];
}

Class NIUITapGestureRecognizerClass(void) {
  return [UITapGestureRecognizer class];
}
