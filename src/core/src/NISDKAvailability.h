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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * For checking SDK feature availibility.
 *
 * @ingroup NimbusCore
 * @defgroup SDK-Availability SDK Availability
 * @{
 *
 * NIIOS macros are defined in parallel to their __IPHONE_ counterparts as a consistently-defined
 * means of checking __IPHONE_OS_VERSION_MAX_ALLOWED.
 *
 * For example:
 *
 * @htmlonly
 * <pre>
 *     #if __IPHONE_OS_VERSION_MAX_ALLOWED >= NIIOS_3_2
 *       // This code will only compile on versions >= iOS 3.2
 *     #endif
 * </pre>
 * @endhtmlonly
 */

/**
 * Released on July 11, 2008
 */
#define NIIOS_2_0     20000

/**
 * Released on September 9, 2008
 */
#define NIIOS_2_1     20100

/**
 * Released on November 21, 2008
 */
#define NIIOS_2_2     20200

/**
 * Released on June 17, 2009
 */
#define NIIOS_3_0     30000

/**
 * Released on September 9, 2009
 */
#define NIIOS_3_1     30100

/**
 * Released on April 3, 2010
 */
#define NIIOS_3_2     30200

/**
 * Released on June 21, 2010
 */
#define NIIOS_4_0     40000

/**
 * Released on September 8, 2010
 */
#define NIIOS_4_1     40100

/**
 * Released on November 22, 2010
 */
#define NIIOS_4_2     40200

/**
 * Released on March 9, 2011
 */
#define NIIOS_4_3     40300

/**
 * Released on October 12, 2011.
 */
#define NIIOS_5_0     50000

/**
 * Released on March 7, 2012.
 */
#define NIIOS_5_1     50100

/**
 * Release TBD. Should be sometime between September and October.
 */
#define NIIOS_6_0     60000

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0 478.23
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_4_0
#define kCFCoreFoundationVersionNumber_iOS_4_0 550.32
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_4_1
#define kCFCoreFoundationVersionNumber_iOS_4_1 550.38
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_4_2
#define kCFCoreFoundationVersionNumber_iOS_4_2 550.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_4_3
#define kCFCoreFoundationVersionNumber_iOS_4_3 550.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 675
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_5_1
#define kCFCoreFoundationVersionNumber_iOS_5_1 690.1
#endif

#if __cplusplus
extern "C" {
#endif

/**
 * Checks whether the device the app is currently running on is an iPad or not.
 *
 *      @returns YES if the device is an iPad.
 */
BOOL NIIsPad(void);

/**
 * Checks whether the device's OS version is at least the given version number.
 *
 * Useful for runtime checks of the device's version number.
 *
 *      @param versionNumber  Any value of kCFCoreFoundationVersionNumber.
 *
 *      @attention Apple recommends using respondsToSelector where possible to check for
 *                 feature support. Use this method as a last resort.
 */
BOOL NIDeviceOSVersionIsAtLeast(double versionNumber);

/**
 * Fetch the screen's scale in an SDK-agnostic way. This will work on any pre-iOS 4.0 SDK.
 *
 * Pre-iOS 4.0: will always return 1.
 *     iOS 4.0: returns the device's screen scale.
 */
CGFloat NIScreenScale(void);

/**
 * Safely fetch the UIPopoverController class if it is available.
 *
 * The class is cached to avoid repeated lookups.
 *
 * Uses NSClassFromString to fetch the popover controller class.
 *
 * This class was first introduced in iOS 3.2 April 3, 2010.
 *
 *      @attention If you wish to maintain pre-iOS 3.2 support then you <b>must</b> use this method
 *                 instead of directly referring to UIPopoverController anywhere within your code.
 *                 Failure to do so will cause your app to crash on startup on pre-iOS 3.2 devices.
 */
Class NIUIPopoverControllerClass(void);

/**
 * Safely fetch the UITapGestureRecognizer class if it is available.
 *
 * The class is cached to avoid repeated lookups.
 *
 * Uses NSClassFromString to fetch the tap gesture recognizer class.
 *
 * This class was first introduced in iOS 3.2 April 3, 2010.
 *
 *      @attention If you wish to maintain pre-iOS 3.2 support then you <b>must</b> use this method
 *                 instead of directly referring to UIPopoverController anywhere within your code.
 *                 Failure to do so will cause your app to crash on startup on pre-iOS 3.2 devices.
 */
Class NIUITapGestureRecognizerClass(void);

#if __cplusplus
} // extern "C"
#endif


#pragma mark Building with Old SDKs

// Define classes that were introduced in iOS 3.2.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_3_2

@class UIPopoverController;
@class UITapGestureRecognizer;

#endif


// Define methods that were introduced in iOS 4.0.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_4_0

@interface UIImage (Nimbus4SDKAvailability)

+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef scale:(CGFloat)scale orientation:(UIImageOrientation)orientation;

- (CGFloat)scale;

@end

@interface UIScreen (Nimbus4SDKAvailability)

- (CGFloat)scale;

@end

#endif


// Define methods that were introduced in iOS 6.0.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_6_0

@interface UIImage (Nimbus6SDKAvailability)

typedef NSInteger UIImageResizingMode;
extern const UIImageResizingMode UIImageResizingModeStretch;
- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode;

@end

#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of SDK Availability /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
