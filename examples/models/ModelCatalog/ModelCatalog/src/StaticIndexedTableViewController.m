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

#import "StaticIndexedTableViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StaticIndexedTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = NSLocalizedString(@"Indexed Model", @"Controller Title: Indexed Model");
    
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"A",
     [NSDictionary dictionaryWithObject:@"Jon Abrams" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Crystal Arbor" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Mike Axiom" forKey:@"title"],
     
     @"B",
     [NSDictionary dictionaryWithObject:@"Joey Bannister" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Ray Bowl" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Jane Byte" forKey:@"title"],
     
     @"C",
     [NSDictionary dictionaryWithObject:@"JJ Cranilly" forKey:@"title"],
     
     @"K",
     [NSDictionary dictionaryWithObject:@"Jake Klark" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Viktor Krum" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Abraham Kyle" forKey:@"title"],
     
     @"L",
     [NSDictionary dictionaryWithObject:@"Mr Larry" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Mo Lundlum" forKey:@"title"],
     
     @"N",
     [NSDictionary dictionaryWithObject:@"Carl Nolly" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Jeremy Nym" forKey:@"title"],

     @"O",
     [NSDictionary dictionaryWithObject:@"Number 1 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 2 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 3 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 4 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 5 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 6 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 7 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 8 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 9 Otter" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Number 10 Otter" forKey:@"title"],
     
     @"X",
     [NSDictionary dictionaryWithObject:@"Charles Xavier" forKey:@"title"],

     nil];
    
    // This controller creates the table view cells.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:self];
    [_model setSectionIndexType:NITableViewModelSectionIndexAlphabetical showsSearch:YES showsSummary:NO];
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

  // Create a dummy search display controller just to show the use of a search bar.
  UISearchBar* searchBar = [[UISearchBar alloc] init];
  [searchBar sizeToFit];
  _searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
  self.tableView.tableHeaderView = _searchController.searchBar;

  // Show that entering the "edit" mode does not allow modifications to this static model.
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  // A pretty standard implementation of creating table view cells follows.
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];

  if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  cell.textLabel.text = [object objectForKey:@"title"];

  return cell;
}


@end
