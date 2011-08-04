//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

@protocol NILauncherDelegate;
@protocol NILauncherDataSource;

/**
 * Calculate the given field dynamically given the view and button dimensions.
 */
extern const NSInteger NILauncherViewDynamic;

/**
 * A launcher view that simulates iOS' home screen launcher functionality.
 *
 *      @ingroup Launcher-User-Interface
 *
 *      @todo Implement tap-and-hold editing for the launcher button ordering. The Three20
 *            implementation can likely be learned from to implement this, though it's possible that
 *            I could improve on it by writing it from scratch. Care needs to be taken with the fact
 *            that launcher pages can scroll vertically now as well.
 */
@interface NILauncherView : UIView <
  UIScrollViewDelegate
> {
@private
  // Views
  UIScrollView*   _scrollView;
  UIPageControl*  _pager;

  // Presentation Information
  NSInteger       _maxNumberOfButtonsPerPage;

  // Display Information
  UIEdgeInsets    _padding;

  // Cached Data Source Information
  NSInteger       _numberOfPages;

  NSMutableArray* _pagesOfButtons;      // NSArray< NSArray< UIButton *> >
  NSMutableArray* _pagesOfScrollViews;  // NSArray< UIScrollView *>

  // Protocols
  id<NILauncherDelegate>    _delegate;
  id<NILauncherDataSource>  _dataSource;
}

#pragma mark Configurable Properties

@property (nonatomic, readwrite, assign) NSInteger maxNumberOfButtonsPerPage; // Default: NSIntegerMax
@property (nonatomic, readwrite, assign) UIEdgeInsets padding; // Default: 10px on all sides

#pragma mark Delegation

@property (nonatomic, readwrite, assign) id<NILauncherDelegate> delegate;

#pragma mark Data Source

@property (nonatomic, readwrite, assign) id<NILauncherDataSource> dataSource;

- (void)reloadData;

#pragma mark Subclassing

- (void)setFrame:(CGRect)frame;

@end


/**
 * The launcher delegate used to inform of state changes and user interactions.
 *
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDelegate <NSObject>

@optional

/**
 * Called when the user taps and releases a launcher button.
 */
- (void)launcherView: (NILauncherView *)launcher
     didSelectButton: (UIButton *)button
              onPage: (NSInteger)page
             atIndex: (NSInteger)index;

@end


/**
 * The launcher data source used to populate the view.
 *
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDataSource <NSObject>

@optional

/**
 * Override the default button dimensions 80x80.
 *
 * The default dimensions will fit the following grids:
 *
 * iPhone within a navigation controller
 *  Portrait: 3x4
 *  Landscape: 5x2
 *
 * The returned dimensions must be positive non-zero values.
 */
- (CGSize)buttonDimensionsInLauncherView:(NILauncherView *)launcherView;

/**
 * Override the default number of rows which is dynamically calculated.
 */
- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView;

/**
 * Override the default number of columns which is dynamically calculated.
 */
- (NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView;

@required

/**
 * The total number of pages to be shown in the launcher view.
 */
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView;

/**
 * The total number of buttons in a given page.
 */
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page;

/**
 * Retrieve the button to be displayed at a given page and index.
 */
- (UIButton *)launcherView: (NILauncherView *)launcherView
             buttonForPage: (NSInteger)page
                   atIndex: (NSInteger)index;

@end

/** @name Configurable Properties */

/**
 * The maximum number of buttons allowed on a given page.
 *
 * By default this value is NSIntegerMax.
 *
 *      @fn NILauncherView::maxNumberOfButtonsPerPage
 */

/**
 * The amount of padding on each side of the launcher view pages.
 *
 * The bottom padding is considered above the page control.
 *
 * Default values are 10 pixels of padding on all sides.
 *
 *      @fn NILauncherView::padding
 */


/** @name Delegation */

/**
 * The launcher view notifies the delegate of any user interaction or state changes.
 *
 *      @fn NILauncherView::delegate
 */


/** @name Data Source */

/**
 * The launcher view populates its pages with information from the data source.
 *
 *      @fn NILauncherView::dataSource
 */

/**
 * Reload the launcher data.
 *
 * This will release all of the launcher's buttons and call all necessary data source methods
 * again.
 *
 * Unlike the UITableView's reloadData, this is not a cheap method to call.
 *
 *      @fn NILauncherView::reloadData
 */


/** @name Subclassing */

/**
 * Lays out the subviews for this launcher view.
 *
 * If you subclass this view and implement setFrame, you should either replicate the
 * functionality found within or call [super setFrame:].
 *
 *      @note Subviews are laid out in this method instead of layoutSubviews due to the fact
 *            that the scroll view offset and content size are modified within this method.
 *            If we modify these values in layoutSubviews then we will end up breaking the
 *            scroll view because whenever the user drags their finger to scroll the scroll
 *            view, layoutSubviews is called on the launcher view.
 */
