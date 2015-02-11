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

#import "NIPreprocessorMacros.h"

#if defined __cplusplus
extern "C" {
#endif

/**
 * For common system metrics.
 *
 * If you work with system metrics in any way it can be a pain in the ass to figure out what the
 * exact metrics are. Figuring out how long it takes the status bar to animate is not something you
 * should be spending your time on. The metrics in this file are provided as a means of unifying a
 * number of system metrics for use in your applications.
 *
 * <h2>What Qualifies as a Common Metric</h2>
 *
 * Common metrics are system components, such as the dimensions of a toolbar in
 * a particular orientation or the duration of a standard animation. This is
 * not the place to put feature-specific metrics, such as the height of a photo scrubber
 * view.
 *
 * <h2>Examples</h2>
 *
 * <h3>Positioning a Toolbar</h3>
 *
 * The following example updates the position and height of a toolbar when the device
 * orientation is changing. This ensures that, in landscape mode on the iPhone, the toolbar
 * is slightly shorter to accomodate the smaller height of the screen.
 *
 * @code
 * - (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
 *                                          duration:(NSTimeInterval)duration {
 *   [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
 * 
 *   CGRect toolbarFrame = self.toolbar.frame;
 *   toolbarFrame.size.height = NIToolbarHeightForOrientation(toInterfaceOrientation);
 *   toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
 *   self.toolbar.frame = toolbarFrame;
 * }
 * @endcode
 *
 * @ingroup NimbusCore
 * @defgroup Common-Metrics Common Metrics
 * @{
 */

#ifndef UIViewAutoresizingFlexibleMargins
#define UIViewAutoresizingFlexibleMargins (UIViewAutoresizingFlexibleLeftMargin \
                                           | UIViewAutoresizingFlexibleTopMargin \
                                           | UIViewAutoresizingFlexibleRightMargin \
                                           | UIViewAutoresizingFlexibleBottomMargin)
#endif

#ifndef UIViewAutoresizingFlexibleDimensions
#define UIViewAutoresizingFlexibleDimensions (UIViewAutoresizingFlexibleWidth \
                                              | UIViewAutoresizingFlexibleHeight)
#endif

#ifndef UIViewAutoresizingNavigationBar
#define UIViewAutoresizingNavigationBar (UIViewAutoresizingFlexibleWidth \
                                         | UIViewAutoresizingFlexibleBottomMargin)
#endif

#ifndef UIViewAutoresizingToolbar
#define UIViewAutoresizingToolbar (UIViewAutoresizingFlexibleWidth \
                                   | UIViewAutoresizingFlexibleTopMargin)
#endif

/**
 * The recommended number of points for a minimum tappable area.
 *
 * Value: 44
 */
CGFloat NIMinimumTapDimension(void);

/**
 * Fetch the height of a toolbar in a given orientation.
 *
 * On the iPhone:
 * - Portrait: 44
 * - Landscape: 33
 *
 * On the iPad: always 44
 */
CGFloat NIToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * The animation curve used when changing the status bar's visibility.
 *
 * This is the curve of the animation used by
 * <code>-[[UIApplication sharedApplication] setStatusBarHidden:withAnimation:].</code>
 *
 * Value: UIViewAnimationCurveEaseIn
 */
UIViewAnimationCurve NIStatusBarAnimationCurve(void);

/**
 * The animation duration used when changing the status bar's visibility.
 *
 * This is the duration of the animation used by
 * <code>-[[UIApplication sharedApplication] setStatusBarHidden:withAnimation:].</code>
 *
 * Value: 0.3 seconds
 */
NSTimeInterval NIStatusBarAnimationDuration(void);

/**
 * The animation curve used when the status bar's bounds change (when a call is received,
 * for example).
 *
 * Value: UIViewAnimationCurveEaseInOut
 */
UIViewAnimationCurve NIStatusBarBoundsChangeAnimationCurve(void);

/**
 * The animation duration used when the status bar's bounds change (when a call is received,
 * for example).
 *
 * Value: 0.35 seconds
 */
NSTimeInterval NIStatusBarBoundsChangeAnimationDuration(void);

/**
 * Get the status bar's current height.
 *
 * If the status bar is hidden this will return 0.
 *
 * This is generally 20 when the status bar is its normal height.
 */
CGFloat NIStatusBarHeight(void) NI_EXTENSION_UNAVAILABLE_IOS("");

/**
 * The animation duration when the device is rotating to a new orientation.
 *
 * Value: 0.4 seconds if the device is being rotated 90 degrees.
 *        0.8 seconds if the device is being rotated 180 degrees.
 *
 * @param isFlippingUpsideDown YES if the device is being flipped upside down.
 */
NSTimeInterval NIDeviceRotationDuration(BOOL isFlippingUpsideDown);

/**
 * The padding around a standard cell in a table view.
 *
 * Value: 10 pixels on all sides.
 */
UIEdgeInsets NICellContentPadding(void);

#if defined __cplusplus
};
#endif

/**@}*/// End of Common Metrics ///////////////////////////////////////////////////////////////////
