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

#import "StaticSectionedTableViewController.h"

@interface StaticSectionedTableViewController()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StaticSectionedTableViewController

@synthesize model = _model;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = NSLocalizedString(@"Sectioned Model", @"Controller Title: Sectioned Model");

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     // This is here to test creating sections without a header.
     [NITableViewModelFooter footerWithTitle:@"Footer only"],
     
     // This as well.
     [NITitleCellObject objectWithTitle:@"Row only"],
     
     // In practice most of your models will use some form of the following groups:
     
     @"Section with header + rows + footer",
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITableViewModelFooter footerWithTitle:@"Footer"],
     
     @"Header + row",
     [NITitleCellObject objectWithTitle:@"Row"],
     
     @"Header only",
     
     @"",
     [NITitleCellObject objectWithTitle:@"Rows only"],
     [NITitleCellObject objectWithTitle:@"Rows only"],
     
     @"",
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITableViewModelFooter footerWithTitle:@"Footer"],
     
     [NITableViewModelFooter footerWithTitle:@"Footer only"],
     nil];

    // We use NICellFactory to create the cell views.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
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
