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

#pragma mark -
#pragma mark Device Orientation

/**
 * For dealing with device orientations.
 *
 * @ingroup NimbusCore
 * @defgroup Device-Orientation Device Orientation
 * @{
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
 *      @returns The current interface orientation.
 */
UIInterfaceOrientation NIInterfaceOrientation();


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Device Orientation ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

