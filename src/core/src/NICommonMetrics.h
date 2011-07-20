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
#import <UIKit/UIKit.h>

/**
 * For common system metrics.
 *
 * Definitions of common view dimensions on the iPhone and iPad touch taking into account any
 * applicable context.
 *
 *      @ingroup NimbusCore
 *      @defgroup Common-Metrics Common Metrics
 *      @{
 */

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
 * The animation curve used when animating the status bar.
 *
 * Value: UIViewAnimationCurveEaseIn
 */
UIViewAnimationCurve NIStatusBarAnimationCurve();

/**
 * The animation duration for animating the status bar.
 *
 * Value: 0.3 seconds
 */
NSTimeInterval NIStatusBarAnimationDuration();

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Common Metrics ///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
