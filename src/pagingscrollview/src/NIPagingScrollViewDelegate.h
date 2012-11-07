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

@class NIPagingScrollView;

/**
 * The delegate for NIPagingScrollView.
 *
 *      @ingroup NimbusPagingScrollView
 */
@protocol NIPagingScrollViewDelegate <UIScrollViewDelegate>
@optional

#pragma mark Scrolling and Zooming /** @name [NIPhotoAlbumScrollViewDelegate] Scrolling and Zooming */

/**
 * The user is scrolling between two photos.
 */
- (void)pagingScrollViewDidScroll:(NIPagingScrollView *)pagingScrollView;

#pragma mark Changing Pages /** @name [NIPagingScrollViewDelegate] Changing Pages */

/**
 * The current page will change.
 *
 * pagingScrollView.centerPageIndex will reflect the old page index, not the new
 * page index.
 */
- (void)pagingScrollViewWillChangePages:(NIPagingScrollView *)pagingScrollView;

/**
 * The current page has changed.
 *
 * pagingScrollView.centerPageIndex will reflect the changed page index.
 */
- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView;

@end
