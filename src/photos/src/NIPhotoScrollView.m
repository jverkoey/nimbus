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

#import "NIPhotoScrollView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoScrollView

@synthesize photoIndex  = _photoIndex;
@synthesize photoSize   = _photoSize;
@synthesize photoDimensions = _photoDimensions;
@synthesize zoomingIsEnabled = _zoomingIsEnabled;
@synthesize zoomingAboveOriginalSizeEnabled = _zoomingAboveOriginalSizeEnabled;
@synthesize photoScrollViewDelegate = _photoScrollViewDelegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_doubleTapGestureRecognizer);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Disable the scroll indicators.
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    // Photo viewers should feel sticky when you're panning around, not smooth and slippery
    // like a UITableView.
    self.decelerationRate = UIScrollViewDecelerationRateFast;

    // Ensure that empty areas of the scroll view are draggable.
    self.backgroundColor = [UIColor blackColor];

    // We implement viewForZoomingInScrollView: and return the image view for zooming.
    self.delegate = self;


    // Set up this view's default configuration.
    self.zoomingIsEnabled = YES;
    self.zoomingAboveOriginalSizeEnabled = YES;
    self.doubleTapToZoomIsEnabled = YES;


    // Autorelease so that we don't have to worry about releasing it in dealloc.
    _imageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];

    // Increases the retain count to 1. The image view will be released when this view
    // is released.
    [self addSubview:_imageView];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)scaleForSize:(CGSize)size boundsSize:(CGSize)boundsSize useMinimalScale:(BOOL)minimalScale {
  CGFloat xScale = boundsSize.width / size.width;   // The scale needed to perfectly fit the image width-wise.
  CGFloat yScale = boundsSize.height / size.height; // The scale needed to perfectly fit the image height-wise.
  CGFloat minScale = minimalScale ? MIN(xScale, yScale) : MAX(xScale, yScale); // Use the minimum of these to allow the image to become fully visible, or the maximum to get fullscreen size

  return minScale;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setMaxMinZoomScalesForCurrentBounds {
  CGSize imageSize = _imageView.bounds.size;

  // Avoid crashing if the image has no dimensions.
  NIDASSERT(imageSize.width > 0 && imageSize.height > 0);
  if (imageSize.width <= 0 || imageSize.height <= 0) {
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    return;
  }

  // The following code is from Apple's ImageScrollView example application and has been used
  // here because it is well-documented and concise.

  CGSize boundsSize = self.bounds.size;

  CGFloat minScale = [self scaleForSize:imageSize boundsSize:boundsSize useMinimalScale:YES];

  // When we show thumbnails for images that are too small for the bounds, we try to use
  // the known photo dimensions to scale the minimum scale to match what the final image
  // will be. This avoids any "snapping" effects from stretching the thumbnail too large.
  if ((NIPhotoScrollViewPhotoSizeThumbnail == self.photoSize)
      && !CGSizeEqualToSize(self.photoDimensions, CGSizeZero)) {
    // Modify the scale according to the final image's minScale.
      CGFloat minIdealScale = [self scaleForSize:self.photoDimensions boundsSize:boundsSize useMinimalScale:YES];
    if (minIdealScale > 1) {
      // Only modify the scale if the final image is smaller than the photo frame.
      minScale = (minScale / minIdealScale);
    }
  }

  // On high resolution screens we have double the pixel density, so we will be seeing
  // every pixel if we limit the maximum zoom scale to 0.5.
  // If zooming disabled we always want to show the image at a 1-to-1 ratio if the image too small.
  // This primarily applies to the loading image on retina displays. If we use the screen scale
  // to calculate the max scale then the loading image will end up being half the size it should
  // be.
  CGFloat maxScale = (self.isZoomingEnabled ? (1.0 / NIScreenScale()) : 1);

  if (self.isZoomingAboveOriginalSizeEnabled) {
    CGFloat idealMaxScale = [self scaleForSize:imageSize boundsSize:boundsSize useMinimalScale:NO];
    maxScale = MAX(maxScale, idealMaxScale);
  }

  if (self.photoSize != NIPhotoScrollViewPhotoSizeThumbnail) {
    // Don't let minScale exceed maxScale. (If the image is smaller than the screen, we
    // don't want to force it to be zoomed.)
    minScale = MIN(minScale, maxScale);
  }

  // If zooming is disabled then we flatten the range for zooming to only allow the min zoom.
  self.maximumZoomScale = [self isZoomingEnabled] ? maxScale : minScale;
  self.minimumZoomScale = minScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  // Center the image as it becomes smaller than the size of the screen.

  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = _imageView.frame;

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

  _imageView.frame = frameToCenter;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _imageView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture Recognizers


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didDoubleTap:(UITapGestureRecognizer *)tapGesture {
  BOOL isCompletelyZoomedIn = (self.maximumZoomScale <= self.zoomScale + FLT_EPSILON);

  BOOL didZoomIn;

  if (isCompletelyZoomedIn) {
    // Zoom the photo back out.
    [self setZoomScale:self.minimumZoomScale animated:YES];

    didZoomIn = NO;

  } else {
    // Zoom into the tap point.
    CGPoint tapCenter = [tapGesture locationInView:_imageView];

    CGRect maxZoomRect = [self rectAroundPoint:tapCenter atZoomScale:self.maximumZoomScale];
    [self zoomToRect:maxZoomRect animated:YES];

    didZoomIn = YES;
  }

  if ([self.photoScrollViewDelegate respondsToSelector:
       @selector(photoScrollViewDidDoubleTapToZoom:didZoomIn:)]) {
    [self.photoScrollViewDelegate photoScrollViewDidDoubleTapToZoom:self didZoomIn:didZoomIn];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
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
  self.contentSize = image.size;

  [self setMaxMinZoomScalesForCurrentBounds];

  // Start off with the image fully-visible on the screen.
  self.zoomScale = self.minimumZoomScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)image {
  return _imageView.image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  _imageView.image = nil;

  self.photoSize = NIPhotoScrollViewPhotoSizeUnknown;

  self.zoomScale = 1;

  self.contentSize = self.bounds.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setZoomingIsEnabled:(BOOL)enabled {
  _zoomingIsEnabled = enabled;

  [self setMaxMinZoomScalesForCurrentBounds];

  // Fit the image on screen.
  self.zoomScale = self.minimumZoomScale;

  // Disable zoom bouncing if zooming is disabled, otherwise the view will allow pinching.
  self.bouncesZoom = enabled;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDoubleTapToZoomIsEnabled:(BOOL)enabled {
  // Only enable double-tap to zoom if the SDK supports it. This feature only works on
  // iOS 3.2 and above.
  if (enabled && nil == _doubleTapGestureRecognizer
      && (nil != NIUITapGestureRecognizerClass()
          && [self respondsToSelector:@selector(addGestureRecognizer:)])) {
    _doubleTapGestureRecognizer =
    [[NIUITapGestureRecognizerClass() alloc] initWithTarget: self
                                                     action: @selector(didDoubleTap:)];

    // I freaking love gesture recognizers.
    [_doubleTapGestureRecognizer setNumberOfTapsRequired:2];

    [self addGestureRecognizer:_doubleTapGestureRecognizer];
  }

  // If the recognizer hasn't been initialized then this will fire on nil and do nothing.
  [_doubleTapGestureRecognizer setEnabled:enabled];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isDoubleTapToZoomIsEnabled {
  // If the gesture recognizer hasn't been created, then _doubleTapGestureRecognizer will be
  // nil and so calling isEnabled will return 0.
  return [_doubleTapGestureRecognizer isEnabled];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Saving/Restoring Offset and Scale

// The following code is from Apple's ImageScrollView example application and has been used
// here because it is well-documented and concise.


///////////////////////////////////////////////////////////////////////////////////////////////////
// Fetch the visual center point of this view in the image view's coordinate space.
- (CGPoint)pointToCenterAfterRotation {
  CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  return [self convertPoint:boundsCenter toView:_imageView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)scaleToRestoreAfterRotation {
  CGFloat contentScale = self.zoomScale;

  // If we're at the minimum zoom scale, preserve that by returning 0, which
  // will be converted to the minimum allowable scale when the scale is restored.
  if (contentScale <= self.minimumZoomScale + FLT_EPSILON) {
    contentScale = 0;
  }

  return contentScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)maximumContentOffset {
  CGSize contentSize = self.contentSize;
  CGSize boundsSize = self.bounds.size;
  return CGPointMake(contentSize.width - boundsSize.width,
                     contentSize.height - boundsSize.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)minimumContentOffset {
  return CGPointZero;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale {
  // Step 1: restore zoom scale, making sure it is within the allowable range.
  self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));

  // Step 2: restore center point, making sure it is within the allowable range.

  // 2a: convert our desired center point back to the scroll view's coordinate space from the
  //     image's coordinate space.
  CGPoint boundsCenter = [self convertPoint:oldCenter fromView:_imageView];

  // 2b: calculate the content offset that would yield that center point
  CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                               boundsCenter.y - self.bounds.size.height / 2.0);

  // 2c: restore offset, adjusted to be within the allowable range
  CGPoint maxOffset = [self maximumContentOffset];
  CGPoint minOffset = [self minimumContentOffset];
  offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
  offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
  self.contentOffset = offset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrameAndMaintainZoomAndCenter:(CGRect)frame {
  CGPoint restorePoint = [self pointToCenterAfterRotation];
  CGFloat restoreScale = [self scaleToRestoreAfterRotation];
  self.frame = frame;
  [self setMaxMinZoomScalesForCurrentBounds];
  [self restoreCenterPoint:restorePoint scale:restoreScale];
}


@end
