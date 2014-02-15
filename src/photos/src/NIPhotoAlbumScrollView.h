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

#import "NIPhotoScrollViewDelegate.h"
#import "NIPhotoAlbumScrollViewDataSource.h"
#import "NIPhotoAlbumScrollViewDelegate.h"

#import "NimbusPagingScrollView.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * A paged scroll view that shows a collection of photos.
 *
 * @ingroup NimbusPhotos
 *
 * This view provides a light-weight implementation of a photo viewer, complete with
 * pinch-to-zoom and swiping to change photos. It is designed to perform well with
 * large sets of photos and large images that are loaded from either the network or
 * disk.
 *
 * It is intended for this view to be used in conjunction with a view controller that
 * implements the data source protocol and presents any required chrome.
 *
 * @see NIToolbarPhotoViewController
 */
@interface NIPhotoAlbumScrollView : NIPagingScrollView <NIPhotoScrollViewDelegate>

#pragma mark Data Source

// For use in your pagingScrollView:pageForIndex: data source implementation.
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex;

@property (nonatomic, weak) id<NIPhotoAlbumScrollViewDataSource> dataSource;
@property (nonatomic, weak) id<NIPhotoAlbumScrollViewDelegate> delegate;

#pragma mark Configuring Functionality

@property (nonatomic, assign, getter=isZoomingEnabled) BOOL zoomingIsEnabled;
@property (nonatomic, assign, getter=isZoomingAboveOriginalSizeEnabled) BOOL zoomingAboveOriginalSizeIsEnabled;
@property (nonatomic, strong) UIColor* photoViewBackgroundColor;

#pragma mark Configuring Presentation

@property (nonatomic, strong) UIImage* loadingImage;

#pragma mark Notifying the View of Loaded Photos

- (void)didLoadPhoto: (UIImage *)image
             atIndex: (NSInteger)photoIndex
           photoSize: (NIPhotoScrollViewPhotoSize)photoSize;

@end


/** @name Data Source */

/**
 * The data source for this photo album view.
 *
 * This is the only means by which this photo album view acquires any information about the
 * album to be displayed.
 *
 * @fn NIPhotoAlbumScrollView::dataSource
 */

/**
 * Use this method in your implementation of NIPhotoAlbumScrollViewDataSource's
 * pagingScrollView:pageForIndex:.
 *
 * Example:
 *
@code
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageForIndex:(NSInteger)pageIndex {
  return [self.photoAlbumView pagingScrollView:pagingScrollView pageForIndex:pageIndex];
}
@endcode
 *
 * Automatically uses the paging scroll view's page recycling methods and creates
 * NIPhotoScrollViews as needed.
 *
 * @fn NIPhotoAlbumScrollView::pagingScrollView:pageForIndex:
 */

/**
 * The delegate for this photo album view.
 *
 * Any user interactions or state changes are sent to the delegate through this property.
 *
 * @fn NIPhotoAlbumScrollView::delegate
 */


/** @name Configuring Functionality */

/**
 * Whether zooming is enabled or not.
 *
 * Regardless of whether this is enabled, only original-sized images will be zoomable.
 * This is because we often don't know how large the final image is so we can't
 * calculate min and max zoom amounts correctly.
 *
 * By default this is YES.
 *
 * @fn NIPhotoAlbumScrollView::zoomingIsEnabled
 */

/**
 * Whether small photos can be zoomed at least until they fit the screen.
 *
 * @see NIPhotoScrollView::zoomingAboveOriginalSizeIsEnabled
 *
 * By default this is YES.
 *
 * @fn NIPhotoAlbumScrollView::zoomingAboveOriginalSizeIsEnabled
 */

/**
 * The background color of each photo's view.
 *
 * By default this is [UIColor blackColor].
 *
 * @fn NIPhotoAlbumScrollView::photoViewBackgroundColor
 */


/** @name Configuring Presentation */

/**
 * An image that is displayed while the photo is loading.
 *
 * This photo will be presented if no image is returned in the data source's implementation
 * of photoAlbumScrollView:photoAtIndex:photoSize:isLoading:.
 *
 * Zooming is disabled when showing a loading image, regardless of the state of zoomingIsEnabled.
 *
 * By default this is nil.
 *
 * @fn NIPhotoAlbumScrollView::loadingImage
 */


/** @name Notifying the View of Loaded Photos */

/**
 * Notify the scroll view that a photo has been loaded at a given index.
 *
 * You should notify the completed loading of thumbnails as well. Calling this method
 * is fairly lightweight and will only update the images of the visible pages. Err on the
 * side of calling this method too much rather than too little.
 *
 * The photo at the given index will only be replaced with the given image if photoSize
 * is of a higher quality than the currently-displayed photo's size.
 *
 * @fn NIPhotoAlbumScrollView::didLoadPhoto:atIndex:photoSize:
 */
