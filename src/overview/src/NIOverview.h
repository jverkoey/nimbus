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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NIOverviewView;
@class NIOverviewLogger;

/**
 * The Overview state management class.
 *
 * @ingroup Overview
 *
 * <h2>What is the Overview?</h2>
 *
 * The Overview is a paged view that sits directly below the status bar and presents information
 * about the device and the currently running application. The Overview is extensible, in that
 * you can write your own pages and add them to the Overview. The included pages allow you to
 * see the current and historical state of memory and disk use, the console logs, and important
 * events that have occurred (such as memory warnings).
 *
 *
 * <h2>Before Using the Overview</h2>
 *
 * None of the Overview methods will do anything unless you have the DEBUG preprocessor
 * macro defined. This is by design. The Overview swizzles private API methods in order to
 * trick the device into showing the Overview as part of the status bar.
 *
 *            DO *NOT* SUBMIT YOUR APP TO THE APP STORE WITH DEBUG DEFINED.
 *
 * If you submit your app to the App Store with DEBUG defined, you *will* be rejected.
 * Overview works only because it hacks certain aspects of the device using private APIs
 * and method swizzling. For good reason, Apple will not look too kindly to the Overview
 * being included in production code. If Apple ever changes any of the APIs that
 * the Overview depends on then the Overview would break.
 */
@interface NIOverview : NSObject

#pragma mark Initializing the Overview /** @name Initializing the Overview */

/**
 * Call this immediately in application:didFinishLaunchingWithOptions:.
 *
 * This method calls applicationDidFinishLaunchingWithStatusBarHeightOverride: with
 * |overrideStatusBarHeight| set to NO.
 */
+ (void)applicationDidFinishLaunching;

/**
 * Call this immediately in application:didFinishLaunchingWithOptions:.
 *
 * Swizzles the necessary methods for adding the Overview to the view hierarchy and registers
 * notifications for device state changes if |overrideStatusBarHeight| is true.
 */
+ (void)applicationDidFinishLaunchingWithStatusBarHeightOverride:(BOOL)overrideStatusBarHeight;

/**
 * Adds the Overview to the given window.
 *
 * This methods calls addOverviewToWindow:enableDraggingVertically: with |enableDraggingVertically|
 * set to NO.
 */
+ (void)addOverviewToWindow:(UIWindow *)window;

/**
 * Adds the Overview to the given window.
 *
 * The Overview will always be fixed at the top of the device's screen directly
 * beneath the status bar (if it is visible) if enableDraggingVertically is false. Otherwise,
 * the overview can be drag vertically.
 */
+ (void)addOverviewToWindow:(UIWindow *)window
   enableDraggingVertically:(BOOL)enableDraggingVertically;

#pragma mark Accessing State Information /** @name Accessing State Information */

/**
 * The height of the Overview.
 */
+ (CGFloat)height;

/**
 * The frame of the Overview.
 */
+ (CGRect)frame;

/**
 * The Overview view.
 */
+ (NIOverviewView *)view;

/**
 * The Overview logger.
 *
 * This is the logger that all of the Overview pages use to present their information.
 */
+ (NIOverviewLogger *)logger;

@end
