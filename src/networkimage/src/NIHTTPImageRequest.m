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

#import "NIHTTPImageRequest.h"

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusCore/NimbusCore.h"
#else
#import "NimbusCore.h"
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIHTTPImageRequest

@synthesize imageCropRect       = _imageCropRect;
@synthesize imageDisplaySize    = _imageDisplaySize;
@synthesize cropImageForDisplay = _cropImageForDisplay;
@synthesize imageContentMode    = _imageContentMode;

@synthesize imageCroppedAndSizedForDisplay = _imageCroppedAndSizedForDisplay;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)showNetworkActivityIndicator {
  // Override the default implementation so that we use the Nimbus Network Activity feature found
  // in the core.
  NINetworkActivityTaskDidStart();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)hideNetworkActivityIndicator {
  NINetworkActivityTaskDidFinish();
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_imageCroppedAndSizedForDisplay);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)newURL {
  if ((self = [super initWithURL:newURL])) {
    self.imageCropRect = CGRectZero;
    self.imageDisplaySize = CGSizeZero;
    self.cropImageForDisplay = YES;
    self.imageContentMode = UIViewContentModeScaleToFill;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)copyWithZone:(NSZone *)zone {
  NIHTTPImageRequest* copy = [super copyWithZone:zone];

  [copy setImageCropRect:[self imageCropRect]];
  [copy setImageDisplaySize:[self imageDisplaySize]];
  [copy setCropImageForDisplay:[self cropImageForDisplay]];
  [copy setImageContentMode:[self imageContentMode]];
  [copy setImageCroppedAndSizedForDisplay:[self imageCroppedAndSizedForDisplay]];

  // Don't copy over the value of didStartNetworkRequest because if it's yes, we'd then call
  // stop twice, which is incorrect.

  return copy;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Calculate the source rect in the source image from which we'll extract the image before drawing
 * it in the destination image.
 */
+ (CGRect)sourceRectWithImageSize:(CGSize)imageSize
                      displaySize:(CGSize)displaySize
                      contentMode:(UIViewContentMode)contentMode {
  if (UIViewContentModeScaleToFill == contentMode) {
    // Scale to fill draws the original image by squashing it to fit the destination's
    // aspect ratio, so the source and destination rects aren't modified.
    return CGRectMake(0, 0, imageSize.width, imageSize.height);

  } else if (UIViewContentModeScaleAspectFill == contentMode) {
    // Aspect fill requires that we take the destination rectangle and "fit" it within the
    // source rectangle; this gives us the area of the source image we'll crop out to draw into
    // the destination image.
    CGFloat scale = MIN(imageSize.width / displaySize.width,
                        imageSize.height / displaySize.height);
    CGSize scaledDisplaySize = CGSizeMake(displaySize.width * scale, displaySize.height * scale);
    return CGRectMake(floorf((imageSize.width - scaledDisplaySize.width) / 2),
                      floorf((imageSize.height - scaledDisplaySize.height) / 2),
                      scaledDisplaySize.width,
                      scaledDisplaySize.height);

  } else if (UIViewContentModeScaleAspectFit == contentMode) {
    // Aspect fit grabs the entire original image and squashes it down to a frame that fits
    // the destination and leaves the unfilled space transparent.
    return CGRectMake(0, 0, imageSize.width, imageSize.height);

  } else {
    // Not implemented
    NIDERROR(@"This content mode has not been implemented in the threaded network image view: %d",
             contentMode);
    NIDASSERT(NO);
    return CGRectMake(0, 0, imageSize.width, imageSize.height);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Calculate the destination rect in the destination image where we will draw the cropped source
 * image.
 */
+ (CGRect)destinationRectWithImageSize:(CGSize)imageSize
                           displaySize:(CGSize)displaySize
                           contentMode:(UIViewContentMode)contentMode {
  if (UIViewContentModeScaleToFill == contentMode) {
    // Scale to fill draws the original image by squashing it to fit the destination's
    // aspect ratio, so the source and destination rects aren't modified.
    return CGRectMake(0, 0, displaySize.width, displaySize.height);

  } else if (UIViewContentModeScaleAspectFill == contentMode) {
    // We're filling the entire destination, so the destination rect is the display rect.
    return CGRectMake(0, 0, displaySize.width, displaySize.height);

  } else if (UIViewContentModeScaleAspectFit == contentMode) {
    // Fit the image right in the center of the source frame and maintain the aspect ratio.
    CGFloat scale = MIN(displaySize.width / imageSize.width,
                        displaySize.height / imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    return CGRectMake(floorf((displaySize.width - scaledImageSize.width) / 2),
                      floorf((displaySize.height - scaledImageSize.height) / 2),
                      scaledImageSize.width,
                      scaledImageSize.height);

  } else {
    // Not implemented
    NIDERROR(@"This content mode has not been implemented in the threaded network image view: %d",
             contentMode);
    return CGRectMake(0, 0, displaySize.width, displaySize.height);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIImage *)imageFromSource: (UIImage *)src
             withContentMode: (UIViewContentMode)contentMode
                    cropRect: (CGRect)cropRect
                 displaySize: (CGSize)displaySize
         cropImageForDisplay: (BOOL)cropImageForDisplay
        interpolationQuality: (CGInterpolationQuality)interpolationQuality {

  UIImage* resultImage = src;

  CGImageRef srcImageRef = src.CGImage;
  CGImageRef croppedImageRef = nil;
  CGImageRef trimmedImageRef = nil;

  CGRect srcRect = CGRectMake(0, 0, src.size.width, src.size.height);

  // Cropping
  if (!CGRectIsEmpty(cropRect)
      && !CGRectEqualToRect(cropRect, CGRectMake(0, 0, 1, 1))) {
    CGRect innerRect = CGRectMake(floorf(src.size.width * cropRect.origin.x),
                                  floorf(src.size.height * cropRect.origin.y),
                                  floorf(src.size.width * cropRect.size.width),
                                  floorf(src.size.height * cropRect.size.height));

    // Create a new image containing only the cropped inner rect.
    srcImageRef = CGImageCreateWithImageInRect(srcImageRef, innerRect);
    croppedImageRef = srcImageRef;

    // This new image will likely have a different width and height, so we have to update
    // the source rect as a result.
    srcRect = CGRectMake(0, 0,
                         CGRectGetWidth(innerRect),
                         CGRectGetHeight(innerRect));
  }

  // Display
  if (0 < displaySize.width
      && 0 < displaySize.height) {

    if (!cropImageForDisplay) {
      // Make the display size match the aspect ratio of the source image.
      // This will likely result in "overlap" of the destination image, so the UIImageView that
      // draws this image should probably have clipping on if this is not desired.
      CGFloat imageAspectRatio = srcRect.size.width / srcRect.size.height;
      CGFloat displayAspectRatio = displaySize.width / displaySize.height;
      if (imageAspectRatio > displayAspectRatio) {
        // The image has a wider aspect ratio than where it's intending to be displayed,
        // so let's change the display width to account for this.
        displaySize.width = displaySize.height * imageAspectRatio;

      } else if (imageAspectRatio < displayAspectRatio) {
        // The image has a narrower aspect ratio than where it's intending to be displayed,
        // so let's change the display height to account for this.
        displaySize.height = displaySize.width * (srcRect.size.height / srcRect.size.width);
      }
    }

    CGRect srcCropRect = [self sourceRectWithImageSize: srcRect.size
                                           displaySize: displaySize
                                           contentMode: contentMode];
    srcCropRect = CGRectIntegral(srcCropRect);

    // Do we need to crop the source?
    if (!CGRectEqualToRect(srcCropRect, srcRect)) {
      srcImageRef = CGImageCreateWithImageInRect(srcImageRef, srcCropRect);
      trimmedImageRef = srcImageRef;

      srcRect = CGRectMake(0, 0,
                           CGRectGetWidth(srcCropRect),
                           CGRectGetHeight(srcCropRect));

      // Release the cropped image source to reduce this thread's memory consumption.
      if (nil != croppedImageRef) {
        CGImageRelease(croppedImageRef);
        croppedImageRef = nil;
      }
    }

    // Calcuate the destination frame.
    CGRect dstBlitRect = [self destinationRectWithImageSize: srcRect.size
                                                displaySize: displaySize
                                                contentMode: contentMode];
    dstBlitRect = CGRectIntegral(dstBlitRect);

    CGBitmapInfo bmi = CGImageGetBitmapInfo(srcImageRef);

    // Clear the alpha bits.
    bmi &= ~(kCGBitmapAlphaInfoMask);

    // Set the RGBA alpha flag. We have no idea what sort of alpha the source image has.
    // We need to explicitly ensure that we have alpha in the composited image so that it
    // will have transparency when the content mode will result in not completely filling the
    // image.
    bmi |= kCGImageAlphaLast;

    // Create our final composite image.
    CGContextRef dstBmp = CGBitmapContextCreate(NULL,
                                                displaySize.width,
                                                displaySize.height,
                                                CGImageGetBitsPerComponent(srcImageRef),
                                                0,
                                                CGImageGetColorSpace(srcImageRef),
                                                bmi);

    CGRect dstRect = CGRectMake(0, 0, displaySize.width, displaySize.height);

    if (nil != dstBmp) {
      // Render the source image into the destination image.
      CGContextClearRect(dstBmp, dstRect);
      CGContextSetInterpolationQuality(dstBmp, interpolationQuality);
      CGContextDrawImage(dstBmp, dstBlitRect, srcImageRef);

      CGImageRef resultImageRef = CGBitmapContextCreateImage(dstBmp);

      if (nil != resultImageRef) {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
        CGImageRelease(resultImageRef);
      }

      CGContextRelease(dstBmp);
    }

  } else if (nil != croppedImageRef) {
    resultImage = [UIImage imageWithCGImage:srcImageRef];
  }

  // Memory cleanup.
  if (nil != trimmedImageRef) {
    CGImageRelease(trimmedImageRef);
  }
  if (nil != croppedImageRef) {
    CGImageRelease(croppedImageRef);
  }

  return resultImage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished {
  NSData* responseData = [self responseData];
  UIImage* image = [[UIImage alloc] initWithData:responseData];

  // Clear out the data as quickly as we can. We never use the response data in the
  // TTNetworkImageView object, so this avoids doubling our memory on every thread.
  [self setRawResponseData:nil];

  // Slice it, dice it!
  [self setImageCroppedAndSizedForDisplay:[[self class] imageFromSource: image
                                                        withContentMode: self.imageContentMode
                                                               cropRect: self.imageCropRect
                                                            displaySize: self.imageDisplaySize
                                                    cropImageForDisplay: self.cropImageForDisplay
                                                   interpolationQuality: kCGInterpolationMedium]];

  NI_RELEASE_SAFELY(image);

  [super requestFinished];
}


@end
