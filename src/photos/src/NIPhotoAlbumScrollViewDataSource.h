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

#import "NIPhotoScrollViewPhotoSize.h"

#import "NimbusPagingScrollView.h"

#import <Foundation/Foundation.h>

@class NIPhotoAlbumScrollView;

/**
 * The photo album scroll data source.
 *
 *      @ingroup NimbusPhotos
 *
 * This data source emphasizes speed and memory efficiency by requesting images only when
 * they're needed and encouraging immediate responses from the data source implementation.
 *
 *      @see NIPhotoAlbumScrollView
 */
@protocol NIPhotoAlbumScrollViewDataSource <NIPagingScrollViewDataSource>

@required

#pragma mark Fetching Required Album Information /** @name [NIPhotoAlbumScrollViewDataSource] Fetching Required Album Information */

/**
 * Fetches the highest-quality image available for the photo at the given index.
 *
 * Your goal should be to make this implementation return as fast as possible. Avoid
 * hitting the disk or blocking on a network request. Aim to load images asynchronously.
 *
 * If you already have the highest-quality image in memory (like in an NIImageMemoryCache),
 * then you can simply return the image and set photoSize to be
 * NIPhotoScrollViewPhotoSizeOriginal.
 *
 * If the highest-quality image is not available when this method is called then you should
 * spin off an asynchronous operation to load the image and set isLoading to YES.
 *
 * If you have a thumbnail in memory but not the full-size image yet, then you should return
 * the thumbnail, set isLoading to YES, and set photoSize to NIPhotoScrollViewPhotoSizeThumbnail.
 *
 * Once the high-quality image finishes loading, call didLoadPhoto:atIndex:photoSize: with
 * the image.
 *
 * This method will be called to prefetch the next and previous photos in the scroll view.
 * The currently displayed photo will always be requested first.
 *
 *      @attention The photo scroll view does not hold onto the UIImages for very long at all.
 *                 It is up to the controller to decide on an adequate caching policy to ensure
 *                 that images are kept in memory through the life of the photo album.
 *                 In your implementation of the data source you should prioritize thumbnails
 *                 being kept in memory over full-size images. When a memory warning is received,
 *                 the original photos should be relinquished from memory first.
 */
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions;

@optional

#pragma mark Optimizing Data Retrieval /** @name [NIPhotoAlbumScrollViewDataSource] Optimizing Data Retrieval */

/**
 * Called when you should cancel any asynchronous loading requests for the given photo.
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

