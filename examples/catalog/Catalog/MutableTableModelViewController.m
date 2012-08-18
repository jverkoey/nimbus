//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "MutableTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of using a NIMutableTableViewModel to modify the contents of a table model.
//
// You will find the following Nimbus features used:
//
// [models]
// NIMutableTableViewModel
// NICellFactory
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface MutableTableModelViewController ()
@property (nonatomic, strong) NIMutableTableViewModel* model;
@property (nonatomic, strong) NIMutableTableViewModel* actions;
@end

@implementation MutableTableModelViewController

@synthesize model = _model;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Mutable Models";

    _model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton:)];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

- (void)didTapAddButton:(UIBarButtonItem *)buttonItem {
  NSIndexSet* indexSet = [self.model addSectionWithTitle:@"New section"];
  NSArray* indexPaths = [self.model addObject:[NITitleCellObject objectWithTitle:@"A cell"]];
  [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
  [self.tableView scrollToRowAtIndexPath:indexPaths.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
