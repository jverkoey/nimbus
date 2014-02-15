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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore.h"
#import "NimbusModels.h"
#import "NITableViewModel+Private.h"

@interface NIMutableTableViewModelTests : SenTestCase {
}

@end


@implementation NIMutableTableViewModelTests


- (void)testInitialization {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 0, @"There should not be any sections.");

  STAssertEquals(model.sections.count, 0U, @"Should have zero sections.");
}

- (void)testAddingObject {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];
  
  [model addObject:[NSNumber numberWithBool:YES]];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 1, @"The model should have one row.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should only be one section.");
  STAssertEquals(model.sections.count, 1U, @"Should have one section.");

  [model addObject:[NSNumber numberWithBool:NO]];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 2, @"The model should have two rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should only be one section.");
  STAssertEquals(model.sections.count, 1U, @"Should have one section.");
}

- (void)testAddingObjectToSection {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];

  [model addObject:[NSNumber numberWithBool:YES]];
  [model addSectionWithTitle:@""];
  [model addObject:[NSNumber numberWithBool:NO] toSection:0];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 2, @"The section should have two rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 2, @"There should be two sections.");
  STAssertEquals(model.sections.count, 2U, @"Should have two sections.");
}

- (void)testAddingObjects {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];

  [model addObjectsFromArray:[NSArray arrayWithObjects:
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:NO],
                              nil]];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 2, @"The model should have two rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should only be one section.");
  STAssertEquals(model.sections.count, 1U, @"Should have one section.");

  [model addObjectsFromArray:[NSArray arrayWithObjects:
                              [NSNumber numberWithBool:YES],
                              [NSNumber numberWithBool:NO],
                              nil]];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 4, @"The model should have four rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should only be one section.");
  STAssertEquals(model.sections.count, 1U, @"Should have one section.");
}

- (void)testRemovingObject {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];
  
  [model addObject:[NSNumber numberWithBool:YES]];
  [model addObject:[NSNumber numberWithBool:YES]];
  [model addObject:[NSNumber numberWithBool:YES]];
  
  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 3, @"The model should have three rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should only be one section.");
  
  [model removeObjectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 2, @"The model should have two rows.");

  [model removeObjectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [model removeObjectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 0, @"The model should have zero rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 1, @"There should still be one section.");
  STAssertEquals(model.sections.count, 1U, @"Should have one section.");
}

- (void)testAddingSection {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];

  [model addObject:[NSNumber numberWithBool:YES]];
  [model addSectionWithTitle:@"Section 2"];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 1, @"The first section should have one row.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 2, @"There should be two sections.");
  STAssertEquals(model.sections.count, 2U, @"Should have two sections.");
  STAssertEquals([model tableView:nil numberOfRowsInSection:1], 0, @"The second section should have no rows.");

  [model addObject:[NSNumber numberWithBool:YES]];

  STAssertEquals([model tableView:nil numberOfRowsInSection:1], 1, @"The second section should have one row.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 2, @"There should be two sections.");
  STAssertEquals(model.sections.count, 2U, @"Should have two sections.");
}

- (void)testInsertingSection {
  NIMutableTableViewModel* model = [[NIMutableTableViewModel alloc] initWithDelegate:nil];

  [model addObject:[NSNumber numberWithBool:YES]];
  [model insertSectionWithTitle:@"Section 0" atIndex:0];

  STAssertEquals([model tableView:nil numberOfRowsInSection:0], 0, @"The first section should have zero rows.");
  STAssertEquals([model numberOfSectionsInTableView:nil], 2, @"There should be two sections.");
  STAssertEquals(model.sections.count, 2U, @"Should have two sections.");
  STAssertEquals([model tableView:nil numberOfRowsInSection:1], 1, @"The second section should have one row.");
  STAssertTrue([[model tableView:nil titleForHeaderInSection:0] isEqual:@"Section 0"], @"The section title should have been set.");
}

@end
