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

#import "NINetworkImageView.h"  // For NINetworkImageViewScaleOptions

#import "NimbusCore.h"

/**
 * A threaded network request for an image that chops up and resizes the image before returning
 * to the UI thread.
 *
 *      @ingroup Network-Image-Requests
 */
@interface NINetworkImageRequest : NINetworkRequestOperation <NINetworkImageOperation> {
@private
  CGRect _imageCropRect;
  CGSize _imageDisplaySize;

  NINetworkImageViewScaleOptions _scaleOptions;
  CGInterpolationQuality         _interpolationQuality;

  UIViewContentMode _imageContentMode;

  UIImage* _imageCroppedAndSizedForDisplay;
}

#pragma mark Configurable Properties

@property (assign) CGRect imageCropRect; // Default: CGRectZero
@property (assign) CGSize imageDisplaySize; // Default: CGSizeZero
@property (assign) NINetworkImageViewScaleOptions scaleOptions; // Default: NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess
@property (assign) CGInterpolationQuality interpolationQuality; // Default: kCGInterpolationDefault
@property (assign) UIViewContentMode imageContentMode; // Default: UIViewContentModeScaleToFill

#pragma mark Results

@property (retain) UIImage* imageCroppedAndSizedForDisplay;

@end


@interface NINetworkImageRequest (ImageModifications)

/** @name Image Modifications */

/**
 * Take a source image and resize and crop it according to a set of display properties.
 *
 * On devices with retina displays, the resulting image will be returned at the correct
 * resolution for the device.
 *
 * This method is exposed to allow other image operations to generate cropped and resized
 * images as well.
 *
 *      @param src                  The source image.
 *      @param contentMode          The content mode to use when cropping and resizing the image.
 *      @param cropRect             An initial crop rect to apply to the src image.
 *      @param displaySize          The requested display size for the image. The resulting image
 *                                  may or may not match these dimensions depending on the scale
 *                                  options being used.
 *      @param scaleOptions         See the NINetworkImageViewScaleOptions documentation for more
 *                                  details.
 *      @param interpolationQuality The interpolation quality to use when resizing the image.
 *
 *      @returns The resized and cropped image.
 */
+ (UIImage *)imageFromSource: (UIImage *)src
             withContentMode: (UIViewContentMode)contentMode
                    cropRect: (CGRect)cropRect
                 displaySize: (CGSize)displaySize
                scaleOptions: (NINetworkImageViewScaleOptions)scaleOptions
        interpolationQuality: (CGInterpolationQuality)interpolationQuality;

@end

/** @name Configurable Properties **/

/**
 * x/y, width/height are in percent coordinates.
 * Valid range is [0..1] for all values.
 *
 * Examples:
 *
 * CGRectZero - Do not crop this image.
 * CGRect(0, 0, 1, 1) - Do not crop this image.
 *
 * The default value is CGRectZero.
 *
 *      @fn NINetworkImageRequest::imageCropRect
 */

/**
 * The size of the image to be displayed on the screen. This is the final size that
 * imageCroppedAndSizedForDisplay will be, unless cropImageForDisplay is NO.
 *
 * If this is CGSizeZero, the image will not be resized. It will bereturned at its original size.
 *
 * The default value is CGSizeZero.
 *
 *      @fn NINetworkImageRequest::imageDisplaySize
 */

/**
 * Options for modifying the way images are cropped when scaling.
 *
 * The default value is NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess.
 *
 *      @see NINetworkImageViewScaleOptions
 *      @fn NINetworkImageRequest::scaleOptions
 */

/**
 * The interpolation quality to use when resizing the image.
 *
 * The default value is kCGInterpolationDefault.
 *
 *      @fn NINetworkImageRequest::interpolationQuality
 */

/**
 * Determines how to resize and crop the image.
 *
 * Supported content modes:
 *
 *  - UIViewContentModeScaleToFill
 *  - UIViewContentModeScaleAspectFill
 *
 * The default value is UIViewContentModeScaleToFill.
 *
 *      @fn NINetworkImageRequest::imageContentMode
 */


/** @name Results */

/**
 * Upon completion of the request, this is the chopped and sized result image that should be
 * used for display.
 *
 *      @fn NINetworkImageRequest::imageCroppedAndSizedForDisplay
 */
