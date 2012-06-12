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

#import "StaticListTableViewController.h"

@interface StaticListTableViewController()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StaticListTableViewController

@synthesize model = _model;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = NSLocalizedString(@"List Model", @"Controller Title: List Model");

    // Each of the cell objects below is mapped to the NITextCell class.
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     [NITitleCellObject objectWithTitle:@"Row 1"],
     [NITitleCellObject objectWithTitle:@"Row 2"],
     [NISubtitleCellObject objectWithTitle:@"Row 3" subtitle:@"Subtitle"],
     nil];

    // We use NICellFactory to create the cell views.
    _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                delegate:(id)[NICellFactory class]];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Only assign the table view's data source after the view has loaded.
  // You must be careful when you call self.tableView in general because it will call loadView
  // if the view has not been loaded yet. You do not need to clear the data source when the
  // view is unloaded (more importantly: you shouldn't, due to the reason just outlined
  // regarding loadView).
  self.tableView.dataSource = _model;
  
  // Show that entering the "edit" mode does not allow modifications to this static model.
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


@end
