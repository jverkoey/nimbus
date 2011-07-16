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

#import "NIPhotoScrollView.h"

@protocol NIPhotoAlbumScrollViewDataSource;

@interface NIPhotoAlbumScrollView : UIView <UIScrollViewDelegate> {
@private
  UIScrollView* _pagingScrollView;

  NSMutableSet* _visiblePages;
  NSMutableSet* _recycledPages;

  UIImage* _loadingImage;

  CGFloat _pageHorizontalMargin;

  // State information when rotating.
  NSInteger _firstVisiblePageIndexBeforeRotation;
  CGFloat _percentScrolledIntoFirstVisiblePage;

  BOOL _zoomingIsEnabled;

  // Data source information.
  NSInteger _numberOfPages;

  id<NIPhotoAlbumScrollViewDataSource> _dataSource;
}

/**
 * An image that is displayed while the photo is loading.
 *
 * By default this is nil.
 */
@property (nonatomic, readwrite, retain) UIImage* loadingImage;

/**
 * The number of pixels on either side of each photo page. The space between each photo
 * will be double this.
 *
 * By default this is NIPhotoAlbumScrollViewDefaultPageHorizontalMargin.
 */
@property (nonatomic, readwrite, assign) CGFloat pageHorizontalMargin;

/**
 * Whether zooming is enabled or not.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL zoomingIsEnabled;


/**
 * The data source for this photo album view.
 */
@property (nonatomic, readwrite, assign) id<NIPhotoAlbumScrollViewDataSource> dataSource;

/**
 * Force the view to reload its data by asking the data source for information.
 */
- (void)reloadData;


#pragma mark Notifying the View of Loaded Photos

/**
 * Notify the scroll view that a photo has been loaded at a given index.
 */
- (void)didLoadPhoto: (UIImage *)image
             atIndex: (NSInteger)photoIndex
           photoSize: (NIPhotoScrollViewPhotoSize)photoSize;


#pragma mark Rotating the Scroll View

/**
 * Stores the current state of the scroll view.
 */
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration;

/**
 * Updates the frame of the scroll view while maintaining the current visible page's state.
 */
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration;

@end


@protocol NIPhotoAlbumScrollViewDataSource <NSObject>

@required

/**
 * The total number of photos in the scroll view.
 *
 * TODO: Do we need this?
 */
- (NSInteger)numberOfPhotosInPhotoScrollView:(NIPhotoAlbumScrollView *)photoScrollView;

/**
 * Fetch the highest quality available image for the photo at the given index.
 *
 * If the returned photo is a thumbnail, then photoSize should be assigned
 * NIPhotoScrollViewPhotoSizeThumbnail. The original image should be fetched asynchronously
 * when this method is called and if it is, isLoading should be assigned YES.
 *
 * In your implementation of the data source you should prioritize thumbnails being kept in
 * memory over full-size images. When a memory warning is received, the original photos
 * should be relinquished from memory first.
 *
 * This method will be called to prefetch the next and previous images in the scroll view as
 * well.
 *
 * The photo scroll view does not hold onto the UIImages for very long at all. It is up to
 * the owner of the scroll view to provide it with the necessary data when it requires it.
 *
 * TODO: How should the in-memory cache be implemented for this? Should the view controller
 * maintain its own in-memory cache that clears all original-sized photos when a memory warning
 * is received? Or should we use the global memory cache so that other images get pushed out
 * of memory while we're using a photo viewer? It's possible to imagine a case where we show
 * the photo viewer with a different in-memory cache, get a memory warning, but then don't
 * release much memory from the global image cache. If the in-memory cache is stored in the
 * photo viewer we also lose the ability to quickly load up the controller again.
 *
 * photoSize should be set accordingly if an image is returned.
 * If the image is not available yet you should set isLoading to YES.
 */
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading;

@optional

/**
 * Cancel any asynchronous loading requests for the given photo.
 *
 * When a photo is not immediately visible this method is called to allow the data
 * source to minimize the number of active asynchronous operations in place.
 *
 * This method is optional, though recommended because it focuses the device's processing
 * power on the most immediately accessible photos.
 */
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex;

@end

