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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CatalogViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  // The model is a retained object in this controller, so we must release it when the controller
  // is deallocated.
  NI_RELEASE_SAFELY(_model);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = NSLocalizedString(@"Model Catalog", @"Controller Title: Model Catalog");

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"Table View Models",
     [NSDictionary dictionaryWithObjectsAndKeys:
      @"List", @"title", [StaticListTableViewController class], @"controllerClass", nil],
     [NSDictionary dictionaryWithObjectsAndKeys:
      @"Sectioned", @"title", [StaticSectionedTableViewController class], @"controllerClass", nil],
     nil];
    
    // This controller creates the table view cells.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:self];
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
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  // A pretty standard implementation of creating table view cells follows.
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
  
  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"]
            autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  cell.textLabel.text = [object objectForKey:@"title"];
  
  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // This is the stock UIKit didSelectRow method, provided here simply as an example of
  // fetching an object from the model.
  
  id object = [_model objectAtIndexPath:indexPath];
  Class cls = [object objectForKey:@"controllerClass"];
  UIViewController* controller = [[[cls alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


@end
