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

#ifdef NIMBUS_STATIC_LIBRARY
#import "ASIHTTPRequest/NIHTTPRequest.h"
#import "NimbusNetworkImage/NINetworkImageView.h"
#else
#import "NIHTTPRequest.h"
#import "NINetworkImageView.h"  // For NINetworkImageViewScaleOptions
#endif

/**
 * A threaded network request for an image that chops up and resizes the image before returning
 * to the UI thread.
 *
 *      @ingroup Network-Image-Requests
 */
@interface NIHTTPImageRequest : NIHTTPRequest {
@private
  CGRect _imageCropRect;
  CGSize _imageDisplaySize;

  NINetworkImageViewScaleOptions _scaleOptions;

  UIViewContentMode _imageContentMode;

  UIImage* _imageCroppedAndSizedForDisplay;
}

#pragma mark Before request is sent to the queue

/**
 * x/y, width/height are in percent coordinates.
 * Valid range is [0..1] for all values.
 *
 * Examples:
 *
 * CGRectZero - Do not crop this image.
 * CGRect(0, 0, 1, 1) - Do not crop this image.
 *
 * The default value is CGRectZero
 */
@property (assign) CGRect imageCropRect;

/**
 * The size of the image to be displayed on the screen. This is the final size that
 * imageCroppedAndSizedForDisplay will be, unless cropImageForDisplay is NO.
 *
 * If this is CGSizeZero, the image will not be resized. It will bereturned at its original size.
 *
 * The default value is CGSizeZero
 */
@property (assign) CGSize imageDisplaySize;

/**
 * Options for modifying the way images are cropped when scaling.
 *
 *      @see NINetworkImageViewScaleOptions
 *
 * By default this is NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess.
 */
@property (assign) NINetworkImageViewScaleOptions scaleOptions;

/**
 * Determines how to resize and crop the image.
 *
 * Supported content modes:
 *
 *  - UIViewContentModeScaleToFill
 *  - UIViewContentModeScaleAspectFill
 *
 * The default value is UIViewContentModeScaleToFill
 */
@property (assign) UIViewContentMode imageContentMode;


/**
 * @name After request completion
 * @{
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */
#pragma mark After request completion

/**
 * Upon completion of the request, this is the chopped and sized result image that should be
 * used for display.
 */
@property (retain) UIImage* imageCroppedAndSizedForDisplay;


/**@}*/// End of After request completion


@end
