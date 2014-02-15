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

#import <UIKit/UIKit.h>

/**
 * The NINetworkTableViewController class provides a similar implementation to UITableViewController
 * but with a more structured view hierarchy.
 *
 * UITableViewController's self.view \em is its self.tableView. This can be problematic if you want
 * to introduce any sibling views that have a higher or lower z-index. This class provides an
 * implementation that, to the best of its abilities, mimics the functionality of
 * UITableViewController in every way but one: self.tableView is a subview of self.view. This simple
 * difference allows us to add new views above the tableView in the z-index.
 *
 * In this particular implementation we include an activity indicator component which may be used
 * to show that data is currently being loaded.
 *
 * @ingroup NimbusNetworkControllers
 */
@interface NINetworkTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// Designated initializer.
- (id)initWithStyle:(UITableViewStyle)style activityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear; // Default: YES

- (void)setIsLoading:(BOOL)isLoading;

@end

/**
 * Sets the loading state of the view controller.
 *
 * @param isLoading When YES, the table view will be hidden and an activity indicator will be
 *                       shown centered in the view controller's view.
 *                       When NO, the table view will be shown and the activity indicator hidden.
 * @fn NINetworkTableViewController::setIsLoading:
 */
