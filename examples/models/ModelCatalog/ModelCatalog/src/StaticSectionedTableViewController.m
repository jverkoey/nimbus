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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StaticSectionedTableViewController


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
    self.title = NSLocalizedString(@"Sectioned Model", @"Controller Title: Sectioned Model");

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     // This is here to test creating sections without a header.
     [NITableViewModelFooter footerWithTitle:@"Footer only"],

     // This as well.
     [NSDictionary dictionaryWithObject:@"Row only" forKey:@"title"],

     // In practice most of your models will use some form of the following groups:

     @"Section with header + rows + footer",
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],
     [NITableViewModelFooter footerWithTitle:@"Footer"],

     @"Header + row",
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],

     @"Header only",

     @"",
     [NSDictionary dictionaryWithObject:@"Rows only" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Rows only" forKey:@"title"],

     @"",
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],
     [NSDictionary dictionaryWithObject:@"Row" forKey:@"title"],
     [NITableViewModelFooter footerWithTitle:@"Footer"],

     [NITableViewModelFooter footerWithTitle:@"Footer only"],
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
    cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"]
            autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  cell.textLabel.text = [object objectForKey:@"title"];
  
  return cell;
}


@end
