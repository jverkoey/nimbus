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

@synthesize photoIndex = _photoIndex;
@synthesize zoomingIsEnabled = _zoomingIsEnabled;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_doubleTapGestureRecognizer);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;

    self.backgroundColor = [UIColor blackColor];

    // We implement viewForZoomingInScrollView: and return the image view for zooming.
    self.delegate = self;


    // Set up this view's default configuration.
    self.zoomingIsEnabled = YES;
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  // center the image as it becomes smaller than the size of the screen

  CGSize boundsSize = self.bounds.size;
  CGRect frameToCenter = _imageView.frame;

  // center horizontally
  if (frameToCenter.size.width < boundsSize.width) {
    frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2);

  } else {
    frameToCenter.origin.x = 0;
  }

  // center vertically
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
  return self.zoomingIsEnabled ? _imageView : nil;
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

  // When the image is zoomed out there is a bit of empty space around the image due
  // to the fact that it's centered on the screen. When we created the rect around the
  // point we need to take this "space" into account.
  // 1: get the frame of the image in this view's coordinates.
  CGRect imageScaledFrame = [self convertRect:_imageView.frame toView:self];

  // 2: Shift the frame by the excess amount. This will ensure that the zoomed location
  //    is always centered on the tap location. We only allow positive values because a
  //    negative value implies that there isn't actually any offset.
  return CGRectMake(point.x - scaledBoundsSize.width / 2 - MAX(0, imageScaledFrame.origin.x),
                    point.y - scaledBoundsSize.height / 2 - MAX(0, imageScaledFrame.origin.y),
                    scaledBoundsSize.width,
                    scaledBoundsSize.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didDoubleTap:(UITapGestureRecognizer *)tapGesture {
  BOOL isCompletelyZoomedIn = (self.maximumZoomScale <= self.zoomScale + FLT_EPSILON);

  if (isCompletelyZoomedIn) {
    // Zoom the photo back out.
    [self setZoomScale:self.minimumZoomScale animated:YES];

  } else {
    // Zoom into the tap point.
    CGPoint tapCenter = [tapGesture locationInView:_imageView];

    CGRect maxZoomRect = [self rectAroundPoint:tapCenter atZoomScale:self.maximumZoomScale];
    [self zoomToRect:maxZoomRect animated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage *)image {
  // prepareForReuse has not been called on this view and it must be.
  NIDASSERT(nil == _imageView.image);

  _imageView.image = image;
  [_imageView sizeToFit];

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

  self.zoomScale = 1;

  self.contentSize = self.bounds.size;
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

    [_doubleTapGestureRecognizer setNumberOfTapsRequired:2];

    [self addGestureRecognizer:_doubleTapGestureRecognizer];
  }

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

  CGFloat xScale = boundsSize.width / imageSize.width;   // The scale needed to perfectly fit the image width-wise.
  CGFloat yScale = boundsSize.height / imageSize.height; // The scale needed to perfectly fit the image height-wise.
  CGFloat minScale = MIN(xScale, yScale);                // Use the minimum of these to allow the image to become fully visible.

  // On high resolution screens we have double the pixel density, so we will be seeing
  // every pixel if we limit the maximum zoom scale to 0.5.
  CGFloat maxScale = 1.0 / NIScreenScale();

  // Don't let minScale exceed maxScale. (If the image is smaller than the screen, we
  // don't want to force it to be zoomed.)
  minScale = MIN(minScale, maxScale);

  self.maximumZoomScale = maxScale;
  self.minimumZoomScale = minScale;
}


@end
