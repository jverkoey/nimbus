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

#import <UIKit/UIKit.h>

#import "NIPreprocessorMacros.h" /* for NI_WEAK */
/**
 * A table view controller that has a loading state.
 *
 * This table controller mimics UITableViewController in its implementation and can be used as a
 * drop-in replacement where necessary.
 */
@interface NINetworkTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

// Designated initializer.
- (id)initWithStyle:(UITableViewStyle)style activityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle;

@property (nonatomic, readwrite, NI_STRONG) UITableView* tableView;
@property (nonatomic, readwrite, NI_STRONG) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear; // Default: YES

- (void)setIsLoading:(BOOL)isLoading;

@end

/**
 * Sets the loading state of the view controller.
 *
 *      @param isLoading When YES, the table view will be hidden and an activity indicator will be
 *                       shown centered in the view controller's view.
 *                       When NO, the table view will be shown and the activity indicator hidden.
 *      @fn NINetworkTableViewController::setIsLoading:
 */
