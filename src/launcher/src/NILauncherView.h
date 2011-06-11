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

@class NILauncherItemDetails;
@class NILauncherButton;

@protocol NILauncherDelegate;
@protocol NILauncherDataSource;

/**
 * @brief Calculate the given field dynamically given the view and button dimensions.
 */
extern const NSInteger NILauncherViewDynamicCalculations;

/**
 * @brief A launcher view that simulates iOS' home screen launcher functionality.
 * @ingroup Launcher-User-Interface
 */
@interface NILauncherView : UIView {
@private
  // Views
  UIScrollView*   _scrollView;
  UIPageControl*  _pager;

  // Presentation Information
  NSInteger       _maxNumberOfButtonsPerPage;

  // Display Information
  NSInteger       _columnCount;
  NSInteger       _rowCount;

  // Protocols
  id<NILauncherDelegate>    _delegate;
  id<NILauncherDataSource>  _dataSource;
}

/**
 * @brief The maximum number of buttons allowed on a given page.
 *
 * By default this value is NILauncherViewDynamicCalculations.
 */
@property (nonatomic, readwrite, assign) NSInteger maxNumberOfButtonsPerPage;

/**
 * @brief The launcher view notifies the delegate of any user interaction or state changes.
 */
@property (nonatomic, readwrite, assign) id<NILauncherDelegate> delegate;

/**
 * @brief The launcher view populates its pages with information from the data source.
 */
@property (nonatomic, readwrite, assign) id<NILauncherDataSource> dataSource;

/**
 * @brief Reload the launcher data.
 *
 * This will release all of the launcher's buttons and call all necessary data source methods
 * again.
 */
- (void)reloadData;

@end


/**
 * @brief The launcher delegate used to inform of state changes and user interactions.
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDelegate

@optional

/**
 * @brief Called when the user taps and releases a launcher button.
 */
- (void)launcherView: (NILauncherView *)launcher
       didSelectItem: (NILauncherItemDetails *)item
              onPage: (NSInteger)page
             atIndex: (NSInteger)index;

@end


/**
 * @brief The launcher data source used to populate the view.
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDataSource

@optional

/**
 * @brief Override the default button dimensions 100x100.
 */
- (CGSize)buttonDimensionsInLauncherView:(NILauncherView *)launcherView;

/**
 * @brief Override the default number of rows which is dynamically calculated.
 */
- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView;

/**
 * @brief Override the default number of columns which is dynamically calculated.
 */
- (NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView;

@required

/**
 * @brief The total number of pages to be shown in the launcher view.
 */
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView;

/**
 * @brief The total number of buttons in a given page.
 */
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page;

/**
 * @brief Retrieve the button to be displayed at a given page and index.
 */
- (NILauncherButton *)launcherView: (NILauncherView *)launcherView
                     buttonForPage: (NSInteger)page
                           atIndex: (NSInteger)index;

@end

/**
 * @brief A convenience class for managing the data used to create an NILauncherButton.
 * @ingroup Launcher-Presentation-Information
 */
@interface NILauncherItemDetails : NSObject {
@private
}

@end

/**
 * @brief The individual button view that the user taps.
 * @ingroup Launcher-User-Interface
 */
@interface NILauncherButton : UIButton {
@private
}

@end
