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
- (void)dealloc {
  // The model is a retained object in this controller, so we must release it when the controller
  // is deallocated.
  [_model release];
  [_actions release];
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = NSLocalizedString(@"Model Catalog", @"Controller Title: Model Catalog");

    NSMutableArray* tableContents = [NSMutableArray array];
    [tableContents addObject:@"Table View Models"];
    NITitleCellObject* list = [NITitleCellObject cellWithTitle:@"List"];
    NITitleCellObject* sectioned = [NITitleCellObject cellWithTitle:@"Sectioned"];
    NITitleCellObject* indexed = [NITitleCellObject cellWithTitle:@"Indexed"];
    NITitleCellObject* forms = [NITitleCellObject cellWithTitle:@"Form Cells"];
    [tableContents addObjectsFromArray:[NSArray arrayWithObjects:
                                        list, sectioned, indexed, nil]];
    [tableContents addObject:@"Table Cell Factory"];
    [tableContents addObject:forms];

    _actions = [[NITableViewActions alloc] init];
    [_actions mapObject:list
       toNavigateAction:NIPushControllerAction([StaticListTableViewController class])];
    [_actions mapObject:sectioned
       toNavigateAction:NIPushControllerAction([StaticSectionedTableViewController class])];
    [_actions mapObject:indexed
       toNavigateAction:NIPushControllerAction([StaticIndexedTableViewController class])];
    [_actions mapObject:forms
       toNavigateAction:NIPushControllerAction([FormCellCatalogTableViewController class])];

    // This controller creates the table view cells.
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
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self.model objectAtIndexPath:indexPath];
  [self.actions willDisplayCell:cell forObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self.model objectAtIndexPath:indexPath];
  [self.actions controller:self didSelectObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


@end
