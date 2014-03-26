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

#import "NINetworkImageView.h"  // For NINetworkImageViewScaleOptions

#import "NimbusCore.h"

@interface NIImageProcessing : NSObject

/** @name Image Modifications */

/**
 * Takes a source image and resizes/crops it according to a set of display properties.
 *
 * On devices with retina displays, the resulting image will be returned at the correct
 * resolution for the device.
 *
 * @param src                  The source image.
 * @param contentMode          The content mode to use when cropping and resizing the image.
 * @param cropRect             An initial crop rect to apply to the src image.
 * @param displaySize          The requested display size for the image. The resulting image
 *                                  may or may not match these dimensions depending on the scale
 *                                  options being used.
 * @param scaleOptions         See the NINetworkImageViewScaleOptions documentation for more
 *                                  details.
 * @param interpolationQuality The interpolation quality to use when resizing the image.
 *
 * @returns The resized and cropped image.
 */
+ (UIImage *)imageFromSource:(UIImage *)src
             withContentMode:(UIViewContentMode)contentMode
                    cropRect:(CGRect)cropRect
                 displaySize:(CGSize)displaySize
                scaleOptions:(NINetworkImageViewScaleOptions)scaleOptions
        interpolationQuality:(CGInterpolationQuality)interpolationQuality;

@end
