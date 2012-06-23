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
@protocol NILauncherButtonView;

/**
 * Calculate the given field dynamically given the view and button dimensions.
 */
extern const NSInteger NILauncherViewGridBasedOnButtonSize;

/**
 * A launcher view that simulates iOS' home screen launcher functionality.
 *
 *      @ingroup NimbusLauncher
 */
@interface NILauncherView : UIView

@property (nonatomic, readwrite, assign) NSInteger maxNumberOfButtonsPerPage; // Default: NSIntegerMax
@property (nonatomic, readwrite, assign) UIEdgeInsets pageInsets; // Default: 10px on all sides
@property (nonatomic, readwrite, assign) CGSize buttonSize; // Default: 80x80
@property (nonatomic, readwrite, assign) NSInteger numberOfRows; // Default: NILauncherViewGridBasedOnButtonSize
@property (nonatomic, readwrite, assign) NSInteger numberOfColumns; // Default: NILauncherViewGridBasedOnButtonSize

- (void)reloadData;
@property (nonatomic, readwrite, assign) id<NILauncherDelegate> delegate;
@property (nonatomic, readwrite, assign) id<NILauncherDataSource> dataSource;

- (UIView<NILauncherButtonView> *)dequeueReusableViewWithIdentifier:(NSString *)identifier;

#pragma mark Rotating the Scroll View

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end

/**
 * The launcher data source used to populate the view.
 *
 * @ingroup NimbusLauncher
 */
@protocol NILauncherDataSource <NSObject>
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
 * Retrieve the button view to be displayed at a given page and index.
 */
- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)index;

@optional

/**
 * Override the default number of rows which is dynamically calculated.
 */
- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView;

/**
 * Override the default number of columns which is dynamically calculated.
 */
- (NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView;

@end


/**
 * The launcher delegate used to inform of state changes and user interactions.
 *
 * @ingroup NimbusLauncher
 */
@protocol NILauncherDelegate <NSObject>
@optional

/**
 * Called when the user taps and releases a launcher button.
 */
- (void)launcherView:(NILauncherView *)launcher didSelectButton:(UIButton *)button onPage:(NSInteger)page atIndex:(NSInteger)index;
@end

/**
 * The launcher delegate used to inform of state changes and user interactions.
 *
 * @ingroup NimbusLauncher
 */
@protocol NILauncherButtonView <NIRecyclableView>
@required

/**
 * The launcher button view must contain an accessible button subview.
 */
@property (nonatomic, readwrite, retain) UIButton* button;

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

/**
 * The size of each button.
 *
 * The default dimensions of 80x80 will fit the following grid:
 *
 * iPhone within a navigation controller
 *  Portrait: 3x4
 *  Landscape: 5x2
 *
 *      @fn NILauncherView::buttonSize
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

/** @name Rotating the Scroll View */

/**
 * Stores the current state of the launcher view in preparation for rotation.
 *
 * This must be called in conjunction with willAnimateRotationToInterfaceOrientation:duration:
 * in the methods by the same name from the view controller containing this view.
 *
 *      @fn NILauncherView::willRotateToInterfaceOrientation:duration:
 */

/**
 * Updates the frame of the launcher view while maintaining the current visible page's state.
 *
 *      @fn NILauncherView::willAnimateRotationToInterfaceOrientation:duration:
 */
