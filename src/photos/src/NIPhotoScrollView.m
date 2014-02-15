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

#import "NIPhotoScrollView.h"

#import "NIPhotoScrollViewDelegate.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

/**
 * A UIScrollView that centers the zooming view's frame as the user zooms.
 *
 * We must update the zooming view's frame within the scroll view's layoutSubviews,
 * thus why we've subclassed UIScrollView.
 */
@interface NICenteringScrollView : UIScrollView
@end


@implementation NICenteringScrollView


#pragma mark - UIView


- (void)layoutSubviews {
  [super layoutSubviews];

  // Center the image as it becomes smaller than the size of the screen.

  UIView* zoomingSubview = [self.delegate viewForZoomingInScrollView:self];
  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = zoomingSubview.frame;
  
  // Center horizontally.
  if (frameToCenter.size.width < boundsSize.width) {
    frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2);

  } else {
    frameToCenter.origin.x = 0;
  }

  // Center vertically.
  if (frameToCenter.size.height < boundsSize.height) {
    frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2);

  } else {
    frameToCenter.origin.y = 0;
  }

  zoomingSubview.frame = frameToCenter;
}

@end

@interface NIPhotoScrollView ()
@property (nonatomic, assign) NIPhotoScrollViewPhotoSize photoSize;
- (void)setMaxMinZoomScalesForCurrentBounds;
@end

@implementation NIPhotoScrollView {
  // The photo view to be zoomed.
  UIImageView* _imageView;
  // The scroll view.
  NICenteringScrollView* _scrollView;
  UIActivityIndicatorView* _loadingView;

  // Photo Information
  NIPhotoScrollViewPhotoSize _photoSize;
  CGSize _photoDimensions;

  // Configurable State
  BOOL _zoomingIsEnabled;
  BOOL _zoomingAboveOriginalSizeIsEnabled;

  UITapGestureRecognizer* _doubleTapGestureRecognizer;
}

@synthesize reuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Default configuration.
    self.zoomingIsEnabled = YES;
    self.zoomingAboveOriginalSizeIsEnabled = YES;
    self.doubleTapToZoomIsEnabled = YES;

    // Autorelease so that we don't have to worry about releasing the subviews in dealloc.
    _scrollView = [[NICenteringScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight);

    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_loadingView sizeToFit];
    _loadingView.frame = NIFrameOfCenteredViewWithinView(_loadingView, self);
    _loadingView.autoresizingMask = UIViewAutoresizingFlexibleMargins;

    // We implement viewForZoomingInScrollView: and return the image view for zooming.
    _scrollView.delegate = self;

    // Disable the scroll indicators.
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;

    // Photo viewers should feel sticky when you're panning around, not smooth and slippery
    // like a UITableView.
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

    // Ensure that empty areas of the scroll view are draggable.
    self.backgroundColor = [UIColor blackColor];
    _scrollView.backgroundColor = self.backgroundColor;

    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];

    [_scrollView addSubview:_imageView];
    [self addSubview:_scrollView];
    [self addSubview:_loadingView];
  }
  return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];

  _scrollView.backgroundColor = backgroundColor;
}

#pragma mark - UIScrollView


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _imageView;
}

#pragma mark - Gesture Recognizers


- (CGRect)rectAroundPoint:(CGPoint)point atZoomScale:(CGFloat)zoomScale {
  NIDASSERT(zoomScale > 0);

  // Define the shape of the zoom rect.
  CGSize boundsSize = self.bounds.size;

  // Modify the size according to the requested zoom level.
  // For example, if we're zooming in to 0.5 zoom, then this will increase the bounds size
  // by a factor of two.
  CGSize scaledBoundsSize = CGSizeMake(boundsSize.width / zoomScale,
                                       boundsSize.height / zoomScale);

  CGRect rect = CGRectMake(point.x - scaledBoundsSize.width / 2,
                           point.y - scaledBoundsSize.height / 2,
                           scaledBoundsSize.width,
                           scaledBoundsSize.height);

  // When the image is zoomed out there is a bit of empty space around the image due
  // to the fact that it's centered on the screen. When we created the rect around the
  // point we need to take this "space" into account.

  // 1: get the frame of the image in this view's coordinates.
  CGRect imageScaledFrame = [self convertRect:_imageView.frame toView:self];

  // 2: Offset the frame by the excess amount. This will ensure that the zoomed location
  //    is always centered on the tap location. We only allow positive values because a
  //    negative value implies that there isn't actually any offset.
  rect = CGRectOffset(rect, -MAX(0, imageScaledFrame.origin.x), -MAX(0, imageScaledFrame.origin.y));

  return rect;
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tapGesture {
  BOOL isCompletelyZoomedIn = (_scrollView.maximumZoomScale <= _scrollView.zoomScale + FLT_EPSILON);

  BOOL didZoomIn;

  if (isCompletelyZoomedIn) {
    // Zoom the photo back out.
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];

    didZoomIn = NO;

  } else {
    // Zoom into the tap point.
    CGPoint tapCenter = [tapGesture locationInView:_imageView];

    CGRect maxZoomRect = [self rectAroundPoint:tapCenter atZoomScale:_scrollView.maximumZoomScale];
    [_scrollView zoomToRect:maxZoomRect animated:YES];

    didZoomIn = YES;
  }

  if ([self.photoScrollViewDelegate respondsToSelector:
       @selector(photoScrollViewDidDoubleTapToZoom:didZoomIn:)]) {
    [self.photoScrollViewDelegate photoScrollViewDidDoubleTapToZoom:self didZoomIn:didZoomIn];
  }
}

#pragma mark - NIPagingScrollViewPage


- (void)prepareForReuse {
  _imageView.image = nil;
  self.photoSize = NIPhotoScrollViewPhotoSizeUnknown;
  _scrollView.zoomScale = 1;
  _scrollView.contentSize = self.bounds.size;
}

- (void)pageDidDisappear {
  _scrollView.zoomScale = _scrollView.minimumZoomScale;
}

#pragma mark - Public


- (void)setImage:(UIImage *)image photoSize:(NIPhotoScrollViewPhotoSize)photoSize {
  _imageView.image = image;
  [_imageView sizeToFit];

  if (nil == image) {
    self.photoSize = NIPhotoScrollViewPhotoSizeUnknown;

  } else {
    self.photoSize = photoSize;
  }

  // The min/max zoom values assume that the content size is the image size. The max zoom will
  // be a value that allows the image to be seen at a 1-to-1 pixel resolution, while the min
  // zoom will be small enough to fit the image on the screen perfectly.
  if (nil != image) {
    _scrollView.contentSize = image.size;

  } else {
    _scrollView.contentSize = self.bounds.size;
  }

  [self setMaxMinZoomScalesForCurrentBounds];

  // Start off with the image fully-visible on the screen.
  _scrollView.zoomScale = _scrollView.minimumZoomScale;

  [self setNeedsLayout];
}

- (void)setLoading:(BOOL)loading {
  _loading = loading;

  if (loading) {
    [_loadingView startAnimating];
  } else {
    [_loadingView stopAnimating];
  }
}

- (UIImage *)image {
  return _imageView.image;
}

- (void)setZoomingIsEnabled:(BOOL)enabled {
  _zoomingIsEnabled = enabled;

  if (nil != _imageView.image) {
    [self setMaxMinZoomScalesForCurrentBounds];

    // Fit the image on screen.
    _scrollView.zoomScale = _scrollView.minimumZoomScale;

    // Disable zoom bouncing if zooming is disabled, otherwise the view will allow pinching.
    _scrollView.bouncesZoom = enabled;

  } else {
    // Reset to the defaults if there is no set image yet.
    _scrollView.zoomScale = 1;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = 1;
    _scrollView.bouncesZoom = NO;
  }
}

- (void)setDoubleTapToZoomIsEnabled:(BOOL)enabled {
  if (enabled && nil == _doubleTapGestureRecognizer) {
    _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapGestureRecognizer];
  }

  _doubleTapGestureRecognizer.enabled = enabled;
}

- (BOOL)isDoubleTapToZoomEnabled {
  return [_doubleTapGestureRecognizer isEnabled];
}

- (CGFloat)scaleForSize:(CGSize)size boundsSize:(CGSize)boundsSize useMinimalScale:(BOOL)minimalScale {
  CGFloat xScale = boundsSize.width / size.width;   // The scale needed to perfectly fit the image width-wise.
  CGFloat yScale = boundsSize.height / size.height; // The scale needed to perfectly fit the image height-wise.
  CGFloat minScale = minimalScale ? MIN(xScale, yScale) : MAX(xScale, yScale); // Use the minimum of these to allow the image to become fully visible, or the maximum to get fullscreen size
  
  return minScale;
}

/**
 * Calculate the min and max scale for the given dimensions and photo size.
 *
 * minScale will fit the photo to the bounds, unless it is too small in which case it will
 * show the image at a 1-to-1 resolution.
 *
 * maxScale will be whatever value shows the image at a 1-to-1 resolution, UNLESS
 * isZoomingAboveOriginalSizeEnabled is enabled, in which case maxScale will be calculated
 * such that the image completely fills the bounds.
 *
 * Exception:  If the photo size is unknown (this is a loading image, for example) then
 * the minimum scale will be set without considering the screen scale. This allows the
 * loading image to draw with its own image scale if it's a high-res @2x image.
 */
- (void)minAndMaxScaleForDimensions: (CGSize)dimensions
                         boundsSize: (CGSize)boundsSize
                          photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                           minScale: (CGFloat *)pMinScale
                           maxScale: (CGFloat *)pMaxScale {
  NIDASSERT(nil != pMinScale);
  NIDASSERT(nil != pMaxScale);
  if (nil == pMinScale
      || nil == pMaxScale) {
    return;
  }

  CGFloat minScale = [self scaleForSize: dimensions
                             boundsSize: boundsSize
                        useMinimalScale: YES];

  // On high resolution screens we have double the pixel density, so we will be seeing
  // every pixel if we limit the maximum zoom scale to 0.5.
  // If the photo size is unknown, it's likely that we're showing the loading image and
  // don't want to shrink it down with the zoom because it should be a scaled image.
  CGFloat maxScale = ((NIPhotoScrollViewPhotoSizeUnknown == photoSize)
                      ? 1
                      : (1.0f / NIScreenScale()));

  if (NIPhotoScrollViewPhotoSizeThumbnail != photoSize) {
    // Don't let minScale exceed maxScale. (If the image is smaller than the screen, we
    // don't want to force it to be zoomed.)
    minScale = MIN(minScale, maxScale);
  }

  // At this point if the image is small, then minScale and maxScale will be the same because
  // we don't want to allow the photo to be zoomed.

  // If zooming above the original size IS enabled, however, expand the max zoom to
  // whatever value would make the image fit the view perfectly.
  if ([self isZoomingAboveOriginalSizeEnabled]) {
    CGFloat idealMaxScale = [self scaleForSize: dimensions
                                    boundsSize: boundsSize
                               useMinimalScale: NO];
    maxScale = MAX(maxScale, idealMaxScale);
  }

  *pMinScale = minScale;
  *pMaxScale = maxScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
  CGSize imageSize = _imageView.bounds.size;
  
  // Avoid crashing if the image has no dimensions.
  if (imageSize.width <= 0 || imageSize.height <= 0) {
    _scrollView.maximumZoomScale = 1;
    _scrollView.minimumZoomScale = 1;
    return;
  }
  
  // The following code is from Apple's ImageScrollView example application and has been used
  // here because it is well-documented and concise.
  
  CGSize boundsSize = _scrollView.bounds.size;
  
  CGFloat minScale = 0;
  CGFloat maxScale = 0;
  
  // Calculate the min/max scale for the image to be presented.
  [self minAndMaxScaleForDimensions: imageSize
                         boundsSize: boundsSize
                          photoSize: self.photoSize
                           minScale: &minScale
                           maxScale: &maxScale];
  
  // When we show thumbnails for images that are too small for the bounds, we try to use
  // the known photo dimensions to scale the minimum scale to match what the final image
  // would be. This avoids any "snapping" effects from stretching the thumbnail too large.
  if ((NIPhotoScrollViewPhotoSizeThumbnail == self.photoSize)
      && !CGSizeEqualToSize(self.photoDimensions, CGSizeZero)) {
    CGFloat scaleToFitOriginal = 0;
    CGFloat originalMaxScale = 0;
    // Calculate the original-sized image's min/max scale.
    [self minAndMaxScaleForDimensions: self.photoDimensions
                           boundsSize: boundsSize
                            photoSize: NIPhotoScrollViewPhotoSizeOriginal
                             minScale: &scaleToFitOriginal
                             maxScale: &originalMaxScale];
    
    if (scaleToFitOriginal + FLT_EPSILON >= (1.0 / NIScreenScale())) {
      // If the final image will be smaller than the view then we want to use that
      // scale as the "true" scale and adjust it relatively to the thumbnail's dimensions.
      // This ensures that the thumbnail will always be the same visual size as the original
      // image, giving us that sexy "crisping" effect when the thumbnail is loaded.
      CGFloat relativeSize = self.photoDimensions.width / imageSize.width;
      minScale = scaleToFitOriginal * relativeSize;
    }
  }
  
  // If zooming is disabled then we flatten the range for zooming to only allow the min zoom.
  if (self.isZoomingEnabled && NIPhotoScrollViewPhotoSizeOriginal == self.photoSize && self.maximumScale > 0) {
    _scrollView.maximumZoomScale = self.maximumScale;
  } else {
    _scrollView.maximumZoomScale = self.isZoomingEnabled ? maxScale : minScale;
  }
  _scrollView.minimumZoomScale = minScale;
}

#pragma mark Saving/Restoring Offset and Scale

// Parts of the following code are from Apple's ImageScrollView example application and
// have been used here because they are well-documented and concise.


// Fetch the visual center point of this view in the image view's coordinate space.
- (CGPoint)pointToCenterAfterRotation {
  CGRect bounds = _scrollView.bounds;
  CGPoint boundsCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  return [self convertPoint:boundsCenter toView:_imageView];
}

- (CGFloat)scaleToRestoreAfterRotation {
  CGFloat contentScale = _scrollView.zoomScale;
  
  // If we're at the minimum zoom scale, preserve that by returning 0, which
  // will be converted to the minimum allowable scale when the scale is restored.
  if (contentScale <= _scrollView.minimumZoomScale + FLT_EPSILON) {
    contentScale = 0;
  }
  
  return contentScale;
}

- (CGPoint)maximumContentOffset {
  CGSize contentSize = _scrollView.contentSize;
  CGSize boundsSize = _scrollView.bounds.size;
  return CGPointMake(contentSize.width - boundsSize.width,
                     contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
  return CGPointZero;
}

- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale {
  // Step 1: restore zoom scale, making sure it is within the allowable range.
  _scrollView.zoomScale = NIBoundf(oldScale,
                                 _scrollView.minimumZoomScale, _scrollView.maximumZoomScale);

  // Step 2: restore center point, making sure it is within the allowable range.

  // 2a: convert our desired center point back to the scroll view's coordinate space from the
  //     image's coordinate space.
  CGPoint boundsCenter = [self convertPoint:oldCenter fromView:_imageView];

  // 2b: calculate the content offset that would yield that center point
  CGPoint offset = CGPointMake(boundsCenter.x - _scrollView.bounds.size.width / 2.0f,
                               boundsCenter.y - _scrollView.bounds.size.height / 2.0f);

  // 2c: restore offset, adjusted to be within the allowable range
  CGPoint maxOffset = [self maximumContentOffset];
  CGPoint minOffset = [self minimumContentOffset];
  offset.x = NIBoundf(offset.x, minOffset.x, maxOffset.x);
  offset.y = NIBoundf(offset.y, minOffset.y, maxOffset.y);
  _scrollView.contentOffset = offset;
}

#pragma mark Saving/Restoring Offset and Scale


- (void)setFrameAndMaintainState:(CGRect)frame {
  CGPoint restorePoint = [self pointToCenterAfterRotation];
  CGFloat restoreScale = [self scaleToRestoreAfterRotation];
  self.frame = frame;
  [self setMaxMinZoomScalesForCurrentBounds];
  [self restoreCenterPoint:restorePoint scale:restoreScale];

  [_scrollView setNeedsLayout];
}

@end
