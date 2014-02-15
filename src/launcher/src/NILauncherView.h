//
// Copyright 2011-2014 NimbusKit
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

#import "NimbusCore.h"

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
 * @ingroup NimbusLauncher
 */
@interface NILauncherView : UIView

@property (nonatomic, assign) NSInteger maxNumberOfButtonsPerPage; // Default: NSIntegerMax
@property (nonatomic, assign) UIEdgeInsets contentInsetForPages; // Default: 10px on all sides
@property (nonatomic, assign) CGSize buttonSize; // Default: 80x80
@property (nonatomic, assign) NSInteger numberOfRows; // Default: NILauncherViewGridBasedOnButtonSize
@property (nonatomic, assign) NSInteger numberOfColumns; // Default: NILauncherViewGridBasedOnButtonSize

- (void)reloadData;
@property (nonatomic, weak) id<NILauncherDelegate> delegate;
@property (nonatomic, weak) id<NILauncherDataSource> dataSource;

- (UIView<NILauncherButtonView> *)dequeueReusableViewWithIdentifier:(NSString *)identifier;

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

/** @name Configuring a Launcher View */

/**
 * Tells the receiver to return the number of rows in a given section of a table view (required).
 *
 * @param launcherView The launcher-view object requesting this information.
 * @param page The index locating a page in @c launcherView.
 * @returns The number of buttons in @c page.
 */
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page;

/**
 * Tells the receiver to return a button view for inserting into a particular location of a given
 * page in the launcher view (required).
 *
 * @param launcherView The launcher-view object requesting this information.
 * @param page The index locating a page in @c launcherView.
 * @param index The index locating a button in a page.
 * @returns A UIView that conforms to NILauncherButtonView that the launcher will display on
                the given page. An assertion is raised if you return nil.
 */
- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)index;

@optional

/**
 * Asks the receiver to return the number of pages in the launcher view.
 *
 * It is assumed that the launcher view has one page if this method is not implemented.
 *
 * @param launcherView The launcher-view object requesting this information.
 * @returns The number of pages in @c launcherView. The default value is 1.
 * @sa NILauncherDataSource::launcherView:numberOfButtonsInPage:
 */
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView;

/**
 * Asks the receiver to return the number of rows of buttons each page can display in the
 * launcher view.
 *
 * This method will be called each time the frame of the launcher view changes. Notably, this will
 * be called when the launcher view has been rotated as a result of a device rotation.
 *
 * @param launcherView The launcher-view object requesting this information.
 * @returns The number of rows of buttons each page can display.
 * @sa NILauncherDataSource::numberOfColumnsPerPageInLauncherView:
 */
- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView;

/**
 * Asks the receiver to return the number of columns of buttons each page can display in the
 * launcher view.
 *
 * This method will be called each time the frame of the launcher view changes. Notably, this will
 * be called when the launcher view has been rotated as a result of a device rotation.
 *
 * @param launcherView The launcher-view object requesting this information.
 * @returns The number of columns of buttons each page can display.
 * @sa NILauncherDataSource::numberOfRowsPerPageInLauncherView:
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

/** @name Managing Selections */

/**
 * Informs the receiver that the specified item on the specified page has been selected.
 *
 * @param launcherView A launcher-view object informing the delegate about the new item
 *                          selection.
 * @param page A page index locating the selected item in @c launcher.
 * @param index An index locating the selected item in the given page.
 */
- (void)launcherView:(NILauncherView *)launcherView didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index;

@end

/**
 * The launcher delegate used to inform of state changes and user interactions.
 *
 * @ingroup NimbusLauncher
 */
@protocol NILauncherButtonView <NIRecyclableView>
@required

/**
 * Requires the view to contain a button subview.
 */
@property (nonatomic, strong) UIButton* button;

@end

/** @name Configuring a Launcher View */

/**
 * The maximum number of buttons allowed on a given page.
 *
 * By default this value is NSIntegerMax.
 *
 * @fn NILauncherView::maxNumberOfButtonsPerPage
 */

/**
 * The distance that each page view insets its contents.
 *
 * Use this property to add to the area around the content of each page. The unit of size is points.
 * The default value is 10 points on all sides.
 *
 * @fn NILauncherView::contentInsetForPages
 */

/**
 * The size of each launcher button.
 *
 * @fn NILauncherView::buttonSize
 */

/**
 * The number of rows to display on each page.
 *
 * @fn NILauncherView::numberOfRows
 */

/**
 * The number of columns to display on each page.
 *
 * @fn NILauncherView::numberOfColumns
 */

/**
 * Returns a reusable launcher button view object located by its identifier.
 *
 * @param identifier A string identifying the launcher button view object to be reused. By
 *                        default, a reusable view's identifier is its class name, but you can
 *                        change it to any arbitrary value.
 * @returns A UIView object with the associated identifier that conforms to the
 *               NILauncherButtonView protocol, or nil if no such object exists in the reusable-cell
 *               queue.
 * @fn NILauncherView::dequeueReusableViewWithIdentifier:
 */

/** @name Managing the Delegate and the Data Source */

/**
 * The object that acts as the delegate of the receiving launcher view.
 *
 * The delegate must adopt the NILauncherDelegate protocol. The delegate is not retained.
 *
 * @fn NILauncherView::delegate
 */

/**
 * The object that acts as the data source of the receiving table view.
 *
 * The data source must adopt the NILauncherDataSource protocol. The data source is not retained.
 *
 * @fn NILauncherView::dataSource
 */

/** @name Reloading the Table View */

/**
 * Reloads the pages of the receiver.
 *
 * Call this method to reload all the data that is used to construct the launcher, including pages
 * and buttons. For efficiency, the launcher redisplays only those pages that are visible or nearly
 * visible.
 *
 * @fn NILauncherView::reloadData
 */

/** @name Rotating the Launcher View */

/**
 * Stores the current state of the launcher view in preparation for rotation.
 *
 * This must be called in conjunction with willAnimateRotationToInterfaceOrientation:duration:
 * in the methods by the same name from the view controller containing this view.
 *
 * @fn NILauncherView::willRotateToInterfaceOrientation:duration:
 */

/**
 * Updates the frame of the launcher view while maintaining the current visible page's state.
 *
 * @fn NILauncherView::willAnimateRotationToInterfaceOrientation:duration:
 */
