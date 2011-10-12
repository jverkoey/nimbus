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

/**
 * numberOfPages will be this value until reloadData is called.
 */
extern const NSInteger NIPagingScrollViewUnknownNumberOfPages;

/**
 * The default number of pixels on the side of each page.
 */
extern const CGFloat NIPagingScrollViewDefaultPageHorizontalMargin;

@protocol NIPagingScrollViewDataSource;
@protocol NIPagingScrollViewDelegate;
@protocol NIPagingScrollViewPage;

/**
 * A paged scroll view that shows a collection of pages.
 */
@interface NIPagingScrollView : UIView <UIScrollViewDelegate> {
@private
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

#pragma mark Configuration /** @name Configuration */

/**
 * A UIView class that implements the NIPagingScrollViewPage protocol.
 */
@property (nonatomic, readwrite, assign) Class pageClass;


#pragma mark Data Source /** @name Data Source */

/**
 * The data source for this page album view.
 *
 * This is the only means by which this paging view acquires any information about the
 * album to be displayed.
 */
@property (nonatomic, readwrite, assign) id<NIPagingScrollViewDataSource> dataSource;

/**
 * Force the view to reload its data by asking the data source for information.
 *
 * This must be called at least once after dataSource has been set in order for the view
 * to gather any presentable information.
 *
 * This method is expensive. It will reset the state of the view and remove all existing
 * pages before requesting the new information from the data source.
 */
- (void)reloadData;


#pragma mark Delegate /** @name Delegate */

/**
 * The delegate for this paging view.
 *
 * Any user interactions or state changes are sent to the delegate through this property.
 */
@property (nonatomic, readwrite, assign) id<NIPagingScrollViewDelegate> delegate;


#pragma mark Configuring Presentation /** @name Configuring Presentation */

/**
 * The number of pixels on either side of each page.
 *
 * The space between each page will be 2x this value.
 *
 * By default this is NIPagingScrollViewDefaultPageHorizontalMargin.
 */
@property (nonatomic, readwrite, assign) CGFloat pageHorizontalMargin;


#pragma mark State /** @name State */

/**
 * The current center page index.
 *
 * This is a zero-based value. If you intend to use this in a label such as "page ## of n" be
 * sure to add one to this value.
 *
 * Setting this value directly will center the new page without any animation.
 */
@property (nonatomic, readwrite, assign) NSInteger centerPageIndex;

/**
 * Change the center page index with optional animation.
 */
- (void)setCenterPageIndex:(NSInteger)centerPageIndex animated:(BOOL)animated;

/**
 * The total number of pages in this paging view, as gathered from the data source.
 *
 * This value is cached after reloadData has been called.
 *
 * Until reloadData is called the first time, numberOfPages will be
 * NIPagingScrollViewUnknownNumberOfPages.
 */
@property (nonatomic, readonly, assign) NSInteger numberOfPages;


#pragma mark Changing the Visible Page /** @name Changing the Visible Page */

/**
 * Returns YES if there is a next page.
 */
- (BOOL)hasNext;

/**
 * Returns YES if there is a previous page.
 */
- (BOOL)hasPrevious;

/**
 * Move to the next page if there is one.
 */
- (void)moveToNextAnimated:(BOOL)animated;

/**
 * Move to the previous page if there is one.
 */
- (void)moveToPreviousAnimated:(BOOL)animated;


#pragma mark Rotating the Scroll View /** @name Rotating the Scroll View */

/**
 * Stores the current state of the scroll view in preparation for rotation.
 *
 * This must be called in conjunction with willAnimateRotationToInterfaceOrientation:duration:
 * in the methods by the same name from the view controller containing this view.
 */
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration;

/**
 * Updates the frame of the scroll view while maintaining the current visible page's state.
 */
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration;


#pragma mark Subclassing /** @name Subclassing */

/**
 * The internal scroll view.
 *
 * Meant to be used by subclasses only.
 */
@property (nonatomic, readonly, retain) UIScrollView* pagingScrollView;

/**
 * The set of currently visible pages.
 *
 * Meant to be used by subclasses only.
 */
@property (nonatomic, readonly, copy) NSMutableSet* visiblePages;

/**
 * The set of inactive pages that are ready to be reused.
 *
 * Meant to be used by subclasses only.
 */
@property (nonatomic, readonly, copy) NSMutableSet* recycledPages;

/**
 * Called before the page is about to be shown and after its frame has been set.
 *
 * Meant to be subclassed. By default this method does nothing.
 */
- (void)willConfigurePage:(id<NIPagingScrollViewPage>)page forIndex:(NSInteger)pageIndex;

/**
 * Called immediately after the page is allocated.
 *
 * Meant to be subclassed. By default this method does nothing.
 */
- (void)didCreatePage:(id<NIPagingScrollViewPage>)page;

/**
 * Called immediately after the page is removed from the paging scroll view.
 *
 * Meant to be subclassed. By default this method does nothing.
 */
- (void)didRecyclePage:(id<NIPagingScrollViewPage>)page;

@end
