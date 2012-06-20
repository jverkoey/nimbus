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

#import "CatalogViewController.h"

#import "StaticListTableViewController.h"
#import "StaticSectionedTableViewController.h"
#import "StaticIndexedTableViewController.h"
#import "FormCellCatalogTableViewController.h"

@interface CatalogViewController()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CatalogViewController

@synthesize model = _model;
@synthesize actions = _actions;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = NSLocalizedString(@"Model Catalog", @"Controller Title: Model Catalog");
    
    _actions = [[NITableViewActions alloc] initWithController:self];

    NSMutableArray* tableContents =
    [NSMutableArray arrayWithObjects:
     @"Table View Models",
     [_actions attachNavigationAction:NIPushControllerAction([StaticListTableViewController class])
                             toObject:[NITitleCellObject objectWithTitle:@"List"]],
     [_actions attachNavigationAction:NIPushControllerAction([StaticSectionedTableViewController class])
                             toObject:[NITitleCellObject objectWithTitle:@"Sectioned"]],
     [_actions attachNavigationAction:NIPushControllerAction([StaticIndexedTableViewController class])
                             toObject:[NITitleCellObject objectWithTitle:@"Indexed"]],
     @"Table Cell Factory",
     [_actions attachNavigationAction:NIPushControllerAction([FormCellCatalogTableViewController class])
                             toObject:[NITitleCellObject objectWithTitle:@"Form Cells"]],
     nil];

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
  self.tableView.delegate = [self.actions forwardingTo:self.tableView.delegate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


@end
