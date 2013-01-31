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

#if defined __cplusplus
extern "C" {
#endif

/**
 * For dealing with device orientations.
 *
 * <h2>Examples</h2>
 *
 * <h3>Use NIIsSupportedOrientation to Enable Autorotation</h3>
 *
 * @code
 *  - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
 *    return NIIsSupportedOrientation(toInterfaceOrientation);
 *  }
 * @endcode
 *
 *      @ingroup NimbusCore
 *      @defgroup Device-Orientation Device Orientation
 *      @{
 */

/**
 * For use in shouldAutorotateToInterfaceOrientation:
 *
 * On iPhone/iPod touch:
 *
 *      Returns YES if the orientation is portrait, landscape left, or landscape right.
 *      This helps to ignore upside down and flat orientations.
 *
 * On iPad:
 *
 *      Always returns YES.
 */
BOOL NIIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * Returns the application's current interface orientation.
 *
 * This is simply a convenience method for [UIApplication sharedApplication].statusBarOrientation.
 *
 *      @returns The current interface orientation.
 */
UIInterfaceOrientation NIInterfaceOrientation(void);

/**
 * Returns YES if the device is a phone and the orientation is landscape.
 *
 * This is a useful check for phone landscape mode which often requires
 * additional logic to handle the smaller vertical real estate.
 *
 *      @returns YES if the device is a phone and orientation is landscape.
 */
BOOL NIIsLandscapePhoneOrientation(UIInterfaceOrientation orientation);

/**
 * Creates an affine transform for the given device orientation.
 *
 * This is useful for creating a transformation matrix for a view that has been added
 * directly to the window and doesn't automatically have its transformation modified.
 */
CGAffineTransform NIRotateTransformForOrientation(UIInterfaceOrientation orientation);

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Device Orientation ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

