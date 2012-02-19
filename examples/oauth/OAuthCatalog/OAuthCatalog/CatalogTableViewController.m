//
// Copyright 2012 Jeff Verkoeyen
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

#import "CatalogTableViewController.h"

#import "SoundCloudController.h"
#import "TableViewText.h"

@interface CatalogTableViewController()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end

@implementation CatalogTableViewController

@synthesize model = _model;

- (void)dealloc {
  [_model release];

  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.title = @"OAuth Catalog";

    NSArray* objects = [NSArray arrayWithObjects:
                        @"Services",
                        [TableViewText objectWithText:@"SoundCloud"
                                               object:[SoundCloudController class]],
                        nil];
    self.model = [[[NITableViewModel alloc] initWithSectionedArray:objects
                                                          delegate:(id)[NICellFactory class]]autorelease];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = self.model;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TableViewText* object = [self.model objectAtIndexPath:indexPath];
  UIViewController* controller = [[[object.object alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
