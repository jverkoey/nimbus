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

@interface NIPhotoScrollView : UIScrollView <
  UIScrollViewDelegate
> {
@private
  NSInteger     _photoIndex;

  UIImageView*  _imageView;

  BOOL _zoomingIsEnabled;

  UITapGestureRecognizer* _doubleTapGestureRecognizer;
}

/**
 * The index of this photo within a photo album.
 *
 * TODO: Can we avoid requiring this index to be stored in this view?
 */
@property (nonatomic, readwrite, assign) NSInteger photoIndex;

/**
 * The currently-displayed photo.
 */
@property (nonatomic, readwrite, retain) UIImage* image;

/**
 * Whether the photo is allowed to be zoomed.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL zoomingIsEnabled;

/**
 * Whether double-tapping zooms in and out of the image.
 *
 * Available on iOS 3.2 and later.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign, getter=isDoubleTapToZoomIsEnabled) BOOL doubleTapToZoomIsEnabled;


/**
 * Remove image and reset the zoom scale.
 */
- (void)prepareForReuse;


#pragma mark Saving/Restoring Offset and Scale

/**
 * Set the frame of the view while maintaining the zoom and center of the scroll view.
 */
- (void)setFrameAndMaintainZoomAndCenter:(CGRect)frame;

@end
