//
// Copyright 2011 Roger Chapman
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

#import "RootViewController.h"

#import "MashupViewController.h"
#import "UnderlineViewController.h"

@interface RootViewController()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController

@synthesize model = _model;
@synthesize actions = _actions;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"NIAttributedLabel Demo";

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];

    _actions = [[NITableViewActions alloc] initWithController:self];
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"",
     [self.actions attachNavigationAction:NIPushControllerAction([MashupViewController class])
                                 toObject:[NITitleCellObject objectWithTitle:@"Mashup"]], 
     @"",
     [self.actions attachNavigationAction:NIPushControllerAction([UnderlineViewController class])
                                 toObject:[NITitleCellObject objectWithTitle:@"Underline"]],
     nil];

    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.actions forwardingTo:self];

  [super viewDidLoad];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


@end
