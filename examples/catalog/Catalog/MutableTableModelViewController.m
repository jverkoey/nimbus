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
// This is a demo of using a NIMutableTableViewModel to modify the contents of a table model. This
// demo shows how to add a section of objects to the model, inform the table view that the section
// has been added, and then recompile the section index.
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

    // In order to be able to modify a model we must create an instance of NIMutableTableViewModel.
    // This object differs from NITableViewModel in that it exposes methods for modifying the
    // contents of the model, similarly to the differences between NSArray and NSMutableArray.
    _model = [[NIMutableTableViewModel alloc] initWithDelegate:(id)[NICellFactory class]];

    // We are going to show how to recompile the section index so we provide the settings here.
    [_model setSectionIndexType:NITableViewModelSectionIndexDynamic
                    showsSearch:NO
                   showsSummary:NO];

    // By tapping this button we'll add a new section to the model.
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

- (NSString *)randomName {
  NSMutableString *name = [[NSMutableString alloc] init];
  for (NSInteger ix = 0; ix < arc4random_uniform(10) + 5; ++ix) {
    [name appendFormat:@"%c", arc4random_uniform('z'-'a')+'a'];
  }
  return [name capitalizedString];
}

- (void)didTapAddButton:(UIBarButtonItem *)buttonItem {
  // We first create a new section in the model.
  NSIndexSet* indexSet = [self.model addSectionWithTitle:[self randomName]];

  // Then we create an array of objects that we want to add to this section.
  NSMutableArray *objects = [NSMutableArray array];
  for (NSInteger ix = 0; ix < arc4random_uniform(10) + 1; ++ix) {
    [objects addObject:[NITitleCellObject objectWithTitle:[self randomName]]];
  }

  // The result of adding these objects is an array of index paths that can be used to ensure the
  // visibility of the new objects.
  NSArray* indexPaths = [self.model addObjectsFromArray:objects];

  // Now that we've modified the model, we want to recompile the section index before notifying the
  // table view of changes to the model.
  [self.model updateSectionIndex];

  // Tell the table view that we've added a new section and that it should use the default
  // animation.
  [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

  // Scroll the table view such that the last object is in view.
  [self.tableView scrollToRowAtIndexPath:indexPaths.lastObject atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
