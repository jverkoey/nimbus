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

/**
 * @example ExampleStaticTableModel.m
 *
 * <h2>Overview</h2>
 *
 * This example shows how to create a standard UITableViewController using a static Nimbus
 * NITableViewModel instead of implementing the data source methods by hand.
 *
 * Part of the @link NimbusModels Nimbus Models@endlink feature.
 */

@interface ExampleTableViewController : UITableViewController <
  // We must implement the model delegate in order to create table view rows.
  NITableViewModelDelegate> {
@private
  NITableViewModel* _model;
}

@end

@implementation CatalogTableViewController

- (void)dealloc {
  // The model is a retained object in this controller, so we must release it when the controller
  // is deallocated.
  NI_RELEASE_SAFELY(_model);

  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"Section 1",
     [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],

     @"Section 2",
     [NSDictionary dictionaryWithObject:@"Row 4" forKey:@"title"],
     [NITableViewModelFooter footerWithTitle:@"Footer"],
     nil];
    
    // This controller creates the table view cells.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Only assign the table view's data source after the view has loaded.
  // You must be careful when you call self.tableView in general because it will call loadView
  // if the view has not been loaded yet. You do not need to clear the data source when the
  // view is unloaded (more importantly: you shouldn't, due to the reason just outlined
  // regarding loadView).
  self.tableView.dataSource = _model;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // This is the stock UIKit didSelectRow method, provided here simply as an example of
  // fetching an object from the model.

  id object = [_model objectAtIndexPath:indexPath];
}

@end
