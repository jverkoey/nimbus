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

@interface NINetworkTableViewController : UIViewController

// Designated initializer.
- (id)initWithTableViewStyle:(UITableViewStyle)tableViewStyle activityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle;

@property (nonatomic, readwrite, retain) UITableView* tableView;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnViewWillAppear; // Default: YES

@end
