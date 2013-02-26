//
// Copyright 2011-2013 Jeff Verkoeyen
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
 * For manipulating UIImage objects.
 *
 * @ingroup NimbusCore
 * @defgroup Image-Utilities Image Utilities
 * @{
 */

/**
 * Returns an image that is stretchable from the center.
 *
 * A common use of this method is to create an image that has rounded corners for a button
 * and then assign a stretchable version of that image to a UIButton.
 *
 * This stretches the middle vertical and horizontal line of pixels, so use care when
 * stretching images that have gradients. For example, an image with a vertical gradient
 * can be stretched horizontally, but will look odd if stretched vertically.
 */
UIImage* NIStretchableImageFromImage(UIImage* image);

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Image Utilities //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#if defined __cplusplus
};
#endif
