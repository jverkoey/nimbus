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
 * Contextual information about the size of the photo.
 */
typedef enum {
  // Unknown photo size.
  NIPhotoScrollViewPhotoSizeUnknown,

  // A smaller version of the image.
  NIPhotoScrollViewPhotoSizeThumbnail,

  // The full-size image.
  NIPhotoScrollViewPhotoSizeOriginal,
} NIPhotoScrollViewPhotoSize;

@protocol NIPhotoScrollViewDelegate;

/**
 * A single photo view that supports zooming and rotation.
 *
 *      @ingroup Photos-Views
 */
@interface NIPhotoScrollView : UIScrollView <
  UIScrollViewDelegate
> {
@private
  // The photo view to be zoomed.
  UIImageView*  _imageView;

  // Photo Album State
  NSInteger _photoIndex;

  // Photo Information
  NIPhotoScrollViewPhotoSize  _photoSize;
  CGSize                      _photoDimensions;

  // Configurable State
  BOOL _zoomingIsEnabled;

  UITapGestureRecognizer* _doubleTapGestureRecognizer;

  id<NIPhotoScrollViewDelegate> _photoScrollViewDelegate;
}

/**
 * The index of this photo within a photo album.
 *
 * TODO: Can we avoid requiring this index to be stored in this view?
 */
@property (nonatomic, readwrite, assign) NSInteger photoIndex;

/**
 * The current size of the photo.
 *
 * This is used to replace the photo only with successively higher-quality versions.
 */
@property (nonatomic, readwrite, assign) NIPhotoScrollViewPhotoSize photoSize;

/**
 * The largest dimensions of the photo.
 *
 * This is used to show the thumbnail at the final image size in case the final image size
 * is smaller than the album's frame. Without this value we have to assume that the thumbnail
 * will take up the full screen. If the final image doesn't take up the full screen, then
 * the photo view will appear to "snap" to the smaller full-size image when the final image
 * does load.
 *
 * CGSizeZero is used to signify an unknown final photo dimension.
 */
@property (nonatomic, readwrite, assign) CGSize photoDimensions;

/**
 * Whether the photo is allowed to be zoomed.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign, getter=isZoomingEnabled) BOOL zoomingIsEnabled;

/**
 * Whether double-tapping zooms in and out of the image.
 *
 * Available on iOS 3.2 and later.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign, getter=isDoubleTapToZoomEnabled) BOOL doubleTapToZoomIsEnabled;

/**
 * The photo scroll view delegate.
 */
@property (nonatomic, readwrite, assign) id<NIPhotoScrollViewDelegate> photoScrollViewDelegate;

/**
 * Remove image and reset the zoom scale.
 */
- (void)prepareForReuse;

/**
 * The currently-displayed photo.
 */
- (UIImage *)image;

/**
 * Set a new photo with a specific size.
 *
 * If image is nil then the photoSize will be overridden as NIPhotoScrollViewPhotoSizeUnknown.
 *
 * Resets the current zoom levels and zooms to fit the image.
 */
- (void)setImage:(UIImage *)image photoSize:(NIPhotoScrollViewPhotoSize)photoSize;


#pragma mark Saving/Restoring Offset and Scale

/**
 * Set the frame of the view while maintaining the zoom and center of the scroll view.
 */
- (void)setFrameAndMaintainZoomAndCenter:(CGRect)frame;

@end


/**
 * The photo scroll view delegate.
 *
 *      @ingroup Photos-Views
 */
@protocol NIPhotoScrollViewDelegate <NSObject>

@optional

/**
 * @name [Delegate] Zooming
 * @{
 */
#pragma mark Zooming

/**
 * The user has double-tapped the photo to zoom either in or out.
 *
 *      @param photoScrollView  The photo scroll view that was tapped.
 *      @param didZoomIn        YES if the photo was zoomed in. NO if the photo was zoomed out.
 */
- (void)photoScrollViewDidDoubleTapToZoom: (NIPhotoScrollView *)photoScrollView
                                didZoomIn: (BOOL)didZoomIn;

/**@}*/// End of Zooming

@end
