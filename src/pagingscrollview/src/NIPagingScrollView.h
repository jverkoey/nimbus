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

#import "NimbusCore.h"

/**
 * numberOfPages will be this value until reloadData is called.
 */
extern const NSInteger NIPagingScrollViewUnknownNumberOfPages;

/**
 * The default number of pixels on the side of each page.
 *
 * Value: 10
 */
extern const CGFloat NIPagingScrollViewDefaultPageHorizontalMargin;

@protocol NIPagingScrollViewDataSource;
@protocol NIPagingScrollViewDelegate;
@protocol NIPagingScrollViewPage;
@class NIViewRecycler;

/**
 * A paged scroll view that shows a series of pages.
 *
 *      @ingroup NimbusPagingScrollView
 */
@interface NIPagingScrollView : UIView <UIScrollViewDelegate> {
@private
  // Views
  UIScrollView* _pagingScrollView;

  // Pages
  NSMutableSet* _visiblePages;
  NIViewRecycler* _viewRecycler;

  // Configurable Properties
  CGFloat _pageHorizontalMargin;

  // State Information
  NSInteger _firstVisiblePageIndexBeforeRotation;
  CGFloat _percentScrolledIntoFirstVisiblePage;
  BOOL _isModifyingContentOffset;
  BOOL _isAnimatingToPage;
  NSInteger _centerPageIndex;

  // Cached Data Source Information
  NSInteger _numberOfPages;

  id<NIPagingScrollViewDataSource> _dataSource;
  id<NIPagingScrollViewDelegate> _delegate;
}

#pragma mark Data Source

- (void)reloadData;
@property (nonatomic, readwrite, assign) id<NIPagingScrollViewDataSource> dataSource;
@property (nonatomic, readwrite, assign) id<NIPagingScrollViewDelegate> delegate;

// It is highly recommended that you use this method to manage view recycling.
- (UIView<NIPagingScrollViewPage> *)dequeueReusablePageWithIdentifier:(NSString *)identifier;

#pragma mark State

@property (nonatomic, readwrite, assign) NSInteger centerPageIndex; // Use moveToPageAtIndex:animated: to animate to a given page.
- (void)setCenterPageIndex:(NSInteger)centerPageIndex animated:(BOOL)animated __NI_DEPRECATED_METHOD;

@property (nonatomic, readonly, assign) NSInteger numberOfPages;

#pragma mark Configuring Presentation

@property (nonatomic, readwrite, assign) CGFloat pageHorizontalMargin;

#pragma mark Changing the Visible Page

- (BOOL)hasNext;
- (BOOL)hasPrevious;
- (void)moveToNextAnimated:(BOOL)animated;
- (void)moveToPreviousAnimated:(BOOL)animated;
- (void)moveToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated;

#pragma mark Rotating the Scroll View

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

#pragma mark Subclassing

@property (nonatomic, readonly, retain) UIScrollView* pagingScrollView;
@property (nonatomic, readonly, copy) NSMutableSet* visiblePages;

- (void)willDisplayPage:(UIView<NIPagingScrollViewPage> *)pageView;
- (void)didRecyclePage:(UIView<NIPagingScrollViewPage> *)pageView;

@end

/** @name Data Source */

/**
 * The data source for this page album view.
 *
 * This is the only means by which this paging view acquires any information about the
 * album to be displayed.
 *
 *      @fn NIPagingScrollView::dataSource
 */

/**
 * Force the view to reload its data by asking the data source for information.
 *
 * This must be called at least once after dataSource has been set in order for the view
 * to gather any presentable information.
 *
 * This method is cheap because we only fetch new information about the currently displayed
 * pages. If the number of pages shrinks then the current center page index will be decreased
 * accordingly.
 *
 *      @fn NIPagingScrollView::reloadData
 */

/**
 * Dequeues a reusable page from the set of recycled pages.
 *
 * If no pages have been recycled for the given identifier then this will return nil.
 * In this case it is your responsibility to create a new page.
 *
 *      @fn NIPagingScrollView::dequeueReusablePageWithIdentifier:
 */

/**
 * The delegate for this paging view.
 *
 * Any user interactions or state changes are sent to the delegate through this property.
 *
 *      @fn NIPagingScrollView::delegate
 */


/** @name Configuring Presentation */

/**
 * The number of pixels on either side of each page.
 *
 * The space between each page will be 2x this value.
 *
 * By default this is NIPagingScrollViewDefaultPageHorizontalMargin.
 *
 *      @fn NIPagingScrollView::pageHorizontalMargin
 */


/** @name State */

/**
 * The current center page index.
 *
 * This is a zero-based value. If you intend to use this in a label such as "page ## of n" be
 * sure to add one to this value.
 *
 * Setting this value directly will center the new page without any animation.
 *
 *      @fn NIPagingScrollView::centerPageIndex
 */

/**
 * Change the center page index with optional animation.
 *
 * This method is deprecated in favor of
 * @link NIPagingScrollView::moveToPageAtIndex:animated: moveToPageAtIndex:animated:@endlink
 *
 *      @fn NIPagingScrollView::setCenterPageIndex:animated:
 */

/**
 * The total number of pages in this paging view, as gathered from the data source.
 *
 * This value is cached after reloadData has been called.
 *
 * Until reloadData is called the first time, numberOfPages will be
 * NIPagingScrollViewUnknownNumberOfPages.
 *
 *      @fn NIPagingScrollView::numberOfPages
 */


/** @name Changing the Visible Page */

/**
 * Returns YES if there is a next page.
 *
 *      @fn NIPagingScrollView::hasNext
 */

/**
 * Returns YES if there is a previous page.
 *
 *      @fn NIPagingScrollView::hasPrevious
 */

/**
 * Move to the next page if there is one.
 *
 *      @fn NIPagingScrollView::moveToNextAnimated:
 */

/**
 * Move to the previous page if there is one.
 *
 *      @fn NIPagingScrollView::moveToPreviousAnimated:
 */

/**
 * Move to the given page index with optional animation.
 *
 *      @fn NIPagingScrollView::moveToPageAtIndex:animated:
 */


/** @name Rotating the Scroll View */

/**
 * Stores the current state of the scroll view in preparation for rotation.
 *
 * This must be called in conjunction with willAnimateRotationToInterfaceOrientation:duration:
 * in the methods by the same name from the view controller containing this view.
 *
 *      @fn NIPagingScrollView::willRotateToInterfaceOrientation:duration:
 */

/**
 * Updates the frame of the scroll view while maintaining the current visible page's state.
 *
 *      @fn NIPagingScrollView::willAnimateRotationToInterfaceOrientation:duration:
 */


/** @name Subclassing */

/**
 * The internal scroll view.
 *
 * Meant to be used by subclasses only.
 *
 *      @fn NIPagingScrollView::pagingScrollView
 */

/**
 * The set of currently visible pages.
 *
 * Meant to be used by subclasses only.
 *
 *      @fn NIPagingScrollView::visiblePages
 */

/**
 * Called before the page is about to be shown and after its frame has been set.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 *      @fn NIPagingScrollView::willDisplayPage:
 */

/**
 * Called immediately after the page is removed from the paging scroll view.
 *
 * Meant to be subclassed. By default this method does nothing.
 *
 *      @fn NIPagingScrollView::didRecyclePage:
 */
