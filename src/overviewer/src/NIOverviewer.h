//
// Copyright 2011 Jeff Verkoeyen
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

@class NIOverviewerView;
@class NIOverviewerLogger;

/**
 * The global overviewer state.
 *
 * None of these methods will do anything unless you have the DEBUG preprocessor macro defined.
 * This is by design.
 *
 *            DO *NOT* SUBMIT YOUR APP TO THE APP STORE WITH DEBUG DEFINED.
 *
 * If you submit your app to the App Store with DEBUG defined, you *will* be rejected.
 * Overviewer works only because it hacks the shit out of the device using private APIs
 * and method swizzling. Apple will not look too kindly to the Overviewer being included
 * in production code and it's totally fair. If Apple ever changes any of the APIs that
 * the Overviewer depends on then the Overviewer will break.
 */
@interface NIOverviewer : NSObject

/**
 * To be called immediately in application:didFinishLaunchingWithOptions:.
 *
 * Swizzles the necessary methods for adding the overviewer to the view hierarchy.
 */
+ (void)applicationDidFinishLaunching;

/**
 * Adds the overviewer to the given window.
 *
 * The overviewer will always be fixed at the top of the device's screen directly
 * underneath the status bar (if it is visible).
 */
+ (void)addOverviewerToWindow:(UIWindow *)window;

+ (NIOverviewerLogger *)logger;


#pragma mark State Information

/**
 * The height of the overviewer.
 */
+ (CGFloat)height;

/**
 * The frame of the overviewer.
 */
+ (CGRect)frame;

/**
 * The overviewer view.
 */
+ (NIOverviewerView *)view;

@end
