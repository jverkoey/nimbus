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
@protocol NIPagingScrollViewPage;

/**
 * The data source for NIPagingScrollView.
 *
 *      @ingroup NimbusPagingScrollView
 */
@protocol NIPagingScrollViewDataSource <NSObject>
@required

#pragma mark Fetching Required Album Information /** @name [NIPagingScrollViewDataSource] Fetching Required Album Information */

/**
 * Fetches the total number of pages in the scroll view.
 *
 * The value returned in this method will be cached by the scroll view until reloadData
 * is called again.
 */
- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView;

/**
 * Fetches a page that will be displayed at the given page index.
 *
 * You should always try to reuse pages by calling dequeueReusablePageWithIdentifier: on the
 * paging scroll view before allocating a new page.
 */
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex;

@end
