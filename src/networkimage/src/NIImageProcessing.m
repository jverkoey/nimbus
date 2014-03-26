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

#import "NIImageProcessing.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@implementation NIImageProcessing

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

  } else if (UIViewContentModeScaleAspectFit == contentMode) {
    // Aspect fit grabs the entire original image and squashes it down to a frame that fits
    // the destination and leaves the unfilled space transparent.
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

  } else if (UIViewContentModeCenter == contentMode) {
    // We need to cut out a hole the size of the display in the center of the source image.
    return CGRectMake(floorf((imageSize.width - displaySize.width) / 2),
                      floorf((imageSize.width - displaySize.width) / 2),
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeTop == contentMode) {
    // We need to cut out a hole the size of the display in the top center of the source image.
    return CGRectMake(floorf((imageSize.width - displaySize.width) / 2),
                      0,
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeBottom == contentMode) {
    // We need to cut out a hole the size of the display in the bottom center of the source image.
    return CGRectMake(floorf((imageSize.width - displaySize.width) / 2),
                      imageSize.height - displaySize.height,
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeLeft == contentMode) {
    // We need to cut out a hole the size of the display in the left center of the source image.
    return CGRectMake(0,
                      floorf((imageSize.width - displaySize.width) / 2),
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeRight == contentMode) {
    // We need to cut out a hole the size of the display in the right center of the source image.
    return CGRectMake(imageSize.width - displaySize.width,
                      floorf((imageSize.width - displaySize.width) / 2),
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeTopLeft == contentMode) {
    // We need to cut out a hole the size of the display in the top left of the source image.
    return CGRectMake(0,
                      0,
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeTopRight == contentMode) {
    // We need to cut out a hole the size of the display in the top right of the source image.
    return CGRectMake(imageSize.width - displaySize.width,
                      0,
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeBottomLeft == contentMode) {
    // We need to cut out a hole the size of the display in the bottom left of the source image.
    return CGRectMake(0,
                      imageSize.height - displaySize.height,
                      displaySize.width, displaySize.height);

  } else if (UIViewContentModeBottomRight == contentMode) {
    // We need to cut out a hole the size of the display in the bottom right of the source image.
    return CGRectMake(imageSize.width - displaySize.width,
                      imageSize.height - displaySize.height,
                      displaySize.width, displaySize.height);

  } else {
    // Not implemented
    NIDERROR(@"The following content mode has not been implemented: %d", contentMode);
    return CGRectMake(0, 0, imageSize.width, imageSize.height);
  }
}

/**
 * Calculate the destination rect in the destination image where we will draw the cropped source
 * image.
 */
+ (CGRect)destinationRectWithImageSize:(CGSize)imageSize
                           displaySize:(CGSize)displaySize
                           contentMode:(UIViewContentMode)contentMode {
  if (UIViewContentModeScaleAspectFit == contentMode) {
    // Fit the image right in the center of the source frame and maintain the aspect ratio.
    CGFloat scale = MIN(displaySize.width / imageSize.width,
                        displaySize.height / imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    return CGRectMake(floorf((displaySize.width - scaledImageSize.width) / 2),
                      floorf((displaySize.height - scaledImageSize.height) / 2),
                      scaledImageSize.width,
                      scaledImageSize.height);

  } else if (UIViewContentModeScaleToFill == contentMode
             || UIViewContentModeScaleAspectFill == contentMode
             || UIViewContentModeCenter == contentMode
             || UIViewContentModeTop == contentMode
             || UIViewContentModeBottom == contentMode
             || UIViewContentModeLeft == contentMode
             || UIViewContentModeRight == contentMode
             || UIViewContentModeTopLeft == contentMode
             || UIViewContentModeTopRight == contentMode
             || UIViewContentModeBottomLeft == contentMode
             || UIViewContentModeBottomRight == contentMode) {
    // We're filling the entire destination, so the destination rect is the display rect.
    return CGRectMake(0, 0, displaySize.width, displaySize.height);

  } else {
    // Not implemented
    NIDERROR(@"The following content mode has not been implemented: %d", contentMode);
    return CGRectMake(0, 0, displaySize.width, displaySize.height);
  }
}

+ (UIImage *)imageFromSource:(UIImage *)src
             withContentMode:(UIViewContentMode)contentMode
                    cropRect:(CGRect)cropRect
                 displaySize:(CGSize)displaySize
                scaleOptions:(NINetworkImageViewScaleOptions)scaleOptions
        interpolationQuality:(CGInterpolationQuality)interpolationQuality {

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
    srcRect = CGRectMake(0, 0, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect));
  }

  // Display
  if (0 < displaySize.width
      && 0 < displaySize.height) {

    if ((NINetworkImageViewScaleToFillLeavesExcess
         == (NINetworkImageViewScaleToFillLeavesExcess & scaleOptions))
        && UIViewContentModeScaleAspectFill == contentMode) {
      // Make the display size match the aspect ratio of the source image by growing the
      // display size.
      CGFloat imageAspectRatio = srcRect.size.width / srcRect.size.height;
      CGFloat displayAspectRatio = displaySize.width / displaySize.height;

      if (imageAspectRatio > displayAspectRatio) {
        // The image is wider than the display, so let's increase the width.
        displaySize.width = displaySize.height * imageAspectRatio;

      } else if (imageAspectRatio < displayAspectRatio) {
        // The image is taller than the display, so let's increase the height.
        displaySize.height = displaySize.width * (srcRect.size.height / srcRect.size.width);
      }

    } else if ((NINetworkImageViewScaleToFitCropsExcess
                == (NINetworkImageViewScaleToFitCropsExcess & scaleOptions))
               && UIViewContentModeScaleAspectFit == contentMode) {
      // Make the display size match the aspect ratio of the source image by shrinking the
      // display size.
      CGFloat imageAspectRatio = srcRect.size.width / srcRect.size.height;
      CGFloat displayAspectRatio = displaySize.width / displaySize.height;

      if (imageAspectRatio > displayAspectRatio) {
        // The image is wider than the display, so let's decrease the height.
        displaySize.height = displaySize.width * (srcRect.size.height / srcRect.size.width);

      } else if (imageAspectRatio < displayAspectRatio) {
        // The image is taller than the display, so let's decrease the width.
        displaySize.width = displaySize.height * imageAspectRatio;
      }
    }

    CGRect srcCropRect = [self sourceRectWithImageSize: srcRect.size
                                           displaySize: displaySize
                                           contentMode: contentMode];
    srcCropRect = CGRectMake(floorf(srcCropRect.origin.x),
                             floorf(srcCropRect.origin.y),
                             roundf(srcCropRect.size.width),
                             roundf(srcCropRect.size.height));

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
    dstBlitRect = CGRectMake(floorf(dstBlitRect.origin.x),
                             floorf(dstBlitRect.origin.y),
                             roundf(dstBlitRect.size.width),
                             roundf(dstBlitRect.size.height));

    // Round any remainder on the display size dimensions.
    displaySize = CGSizeMake(roundf(displaySize.width), roundf(displaySize.height));

    // See table "Supported Pixel Formats" in the following guide for support iOS bitmap formats:
    // http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bmi = kCGImageAlphaPremultipliedLast;

    // For screen sizes with higher resolutions, we create a larger image with a scale value
    // so that it appears crisper on the screen.
    CGFloat screenScale = NIScreenScale();

    // Create our final composite image.
    CGContextRef dstBmp = CGBitmapContextCreate(NULL,
                                                displaySize.width * screenScale,
                                                displaySize.height * screenScale,
                                                8,
                                                0,
                                                colorSpace,
                                                bmi);

    // If this fails then we're likely creating an invalid bitmap and shit's about to go down.
    // In production this will fail somewhat gracefully, in that we'll end up just using the
    // source image instead of the cropped and resized image.
    NIDASSERT(nil != dstBmp);

    if (nil != dstBmp) {
      CGRect dstRect = CGRectMake(0, 0,
                                  displaySize.width * screenScale,
                                  displaySize.height * screenScale);

      // Render the source image into the destination image.
      CGContextClearRect(dstBmp, dstRect);
      CGContextSetInterpolationQuality(dstBmp, interpolationQuality);

      CGRect scaledBlitRect = CGRectMake(dstBlitRect.origin.x * screenScale,
                                         dstBlitRect.origin.y * screenScale,
                                         dstBlitRect.size.width * screenScale,
                                         dstBlitRect.size.height * screenScale);
      CGContextDrawImage(dstBmp, scaledBlitRect, srcImageRef);

      CGImageRef resultImageRef = CGBitmapContextCreateImage(dstBmp);

      if (nil != resultImageRef) {
        resultImage = [UIImage imageWithCGImage:resultImageRef
                                          scale:screenScale
                                    orientation:src.imageOrientation];
        CGImageRelease(resultImageRef);
      }

      CGContextRelease(dstBmp);
    }

    CGColorSpaceRelease(colorSpace);

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

@end
