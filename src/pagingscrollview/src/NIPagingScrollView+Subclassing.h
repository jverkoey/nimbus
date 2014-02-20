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

#import "NIPagingScrollView.h"

// Methods that are meant to be subclassed.
@interface NIPagingScrollView (Subclassing)

// Meant to be subclassed. Default implementations are stubs.
- (void)willDisplayPage:(UIView<NIPagingScrollViewPage> *)pageView;
- (void)didRecyclePage:(UIView<NIPagingScrollViewPage> *)pageView;
- (void)didReloadNumberOfPages;
- (void)didChangeCenterPageIndexFrom:(NSInteger)from to:(NSInteger)to;

// Meant to be subclassed.
- (UIView<NIPagingScrollViewPage> *)loadPageAtIndex:(NSInteger)pageIndex;

#pragma mark Accessing Child Views

- (UIScrollView *)scrollView;
- (NSMutableSet *)visiblePages; // Set of UIView<NIPagingScrollViewPage>*

@end

// Methods that are not meant to be subclassed.
@interface NIPagingScrollView (ProtectedMethods)

- (void)setCenterPageIndexIvar:(NSInteger)centerPageIndex;
- (void)recyclePageAtIndex:(NSInteger)pageIndex;
- (void)displayPageAtIndex:(NSInteger)pageIndex;
- (CGFloat)pageScrollableDimension;
- (void)layoutVisiblePages;

@end

// Deprecated methods formerly used by subclasses.
// This category will be removed on February 28, 2014.
@interface NIPagingScrollView (DeprecatedSubclassingMethods)

// Use -[NIPagingScrollView scrollView] instead.
- (UIScrollView *)pagingScrollView __NI_DEPRECATED_METHOD;

@end

/**
 * Called before the page is about to be shown and after its frame has been set.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 * @fn NIPagingScrollView::willDisplayPage:
 */

/**
 * Called immediately after the page is removed from the paging scroll view.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 * @fn NIPagingScrollView::didRecyclePage:
 */

/**
 * Called immediately after the data source has been queried for its number of
 * pages.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 * @fn NIPagingScrollView::didReloadNumberOfPages
 */

/**
 * Called when the visible page has changed.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 * @fn NIPagingScrollView::didChangeCenterPageIndexFrom:to:
 */

/**
 * Called when a page needs to be loaded before it is displayed.
 *
 * By default this method asks the data source for the page at the given index.
 * A subclass may chose to modify the page index using a transformation method
 * before calling super.
 *
 * @fn NIPagingScrollView::loadPageAtIndex:
 */

/**
 * Sets the centerPageIndex ivar without side effects.
 *
 * @fn NIPagingScrollView::setCenterPageIndexIvar:
 */

/**
 * Recycles the page at the given index.
 *
 * @fn NIPagingScrollView::recyclePageAtIndex:
 */

/**
 * Displays the page at the given index.
 *
 * @fn NIPagingScrollView::displayPageAtIndex:
 */

/**
 * Returns the page's scrollable dimension.
 *
 * This is the width of the paging scroll view for horizontal scroll views, or
 * the height of the paging scroll view for vertical scroll views.
 *
 * @fn NIPagingScrollView::pageScrollableDimension
 */

/**
 * Updates the frames of all visible pages based on their page indices.
 *
 * @fn NIPagingScrollView::layoutVisiblePages
 */
