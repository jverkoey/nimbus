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

#import <Foundation/Foundation.h>

#import "NimbusPagingScrollView.h"

@class NIPhotoAlbumScrollView;

/**
 * The photo album scroll view delegate.
 *
 * @ingroup Photos-Protocols
 * @see NIPhotoAlbumScrollView
 */
@protocol NIPhotoAlbumScrollViewDelegate <NIPagingScrollViewDelegate>

@optional

#pragma mark Scrolling and Zooming /** @name [NIPhotoAlbumScrollViewDelegate] Scrolling and Zooming */

/**
 * The user double-tapped to zoom in or out.
 */
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                   didZoomIn: (BOOL)didZoomIn;


#pragma mark Data Availability /** @name [NIPhotoAlbumScrollViewDelegate] Data Availability */

/**
 * The next photo in the album has been loaded and is ready to be displayed.
 */
- (void)photoAlbumScrollViewDidLoadNextPhoto:(NIPhotoAlbumScrollView *)photoAlbumScrollView;

/**
 * The previous photo in the album has been loaded and is ready to be displayed.
 */
- (void)photoAlbumScrollViewDidLoadPreviousPhoto:(NIPhotoAlbumScrollView *)photoAlbumScrollView;

@end

