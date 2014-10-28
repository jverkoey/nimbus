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

#import <XCTest/XCTest.h>

#import "NimbusCore.h"
#import "NimbusModels.h"
#import "NITableViewModel+Private.h"

@interface NITableViewModelTests : XCTestCase {
}

@end


@implementation NITableViewModelTests


- (void)testEmptyTableViewModel {
  NITableViewModel* model = [[NITableViewModel alloc] init];

  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 0, @"There should not be any sections.");
  XCTAssertEqual(model.sections.count, 0U, @"Should have zero sections.");
  
  model = [[NITableViewModel alloc] initWithListArray:nil delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 0, @"There should not be any sections.");
  
  model = [[NITableViewModel alloc] initWithSectionedArray:nil delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 0, @"There should not be any sections.");
  
  model = [[NITableViewModel alloc] initWithListArray:[NSArray array] delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 1, @"There should be one empty section.");
  
  model = [[NITableViewModel alloc] initWithSectionedArray:[NSArray array] delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 0, @"The model should be empty.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 0, @"There should not be any sections.");
}

- (void)testInvalidAccess {
  NITableViewModel* model = [[NITableViewModel alloc] init];

  XCTAssertNil([model tableView:nil titleForHeaderInSection:0], @"There should not be a header title.");
  XCTAssertNil([model tableView:nil titleForFooterInSection:0], @"There should not be a footer title.");

  XCTAssertNil([model tableView:nil titleForHeaderInSection:1], @"There should not be a header title.");
  XCTAssertNil([model tableView:nil titleForFooterInSection:1], @"There should not be a footer title.");
  
  XCTAssertNil([model tableView:nil titleForHeaderInSection:-1], @"There should not be a header title.");
  XCTAssertNil([model tableView:nil titleForFooterInSection:-1], @"There should not be a footer title.");
}

- (void)testEditing {
  NITableViewModel* model = [[NITableViewModel alloc] init];

  XCTAssertFalse([model tableView:nil canEditRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]],
                @"Should not be able to edit anything.");
  XCTAssertFalse([model tableView:nil canEditRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]],
                @"Should not be able to edit anything.");
}

- (void)testListTableViewModel {
  NSArray* contents = [NSArray arrayWithObjects:
                       @"This is a string",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithListArray:contents delegate:nil];

  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 4, @"The model should have 4 rows.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 1, @"There should be 1 section.");
  XCTAssertNil([model tableView:nil titleForHeaderInSection:0], @"There should be no section title.");
}

- (void)testListTableViewModel_objectAtIndexPath {
  id object1 = [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"];
  id object2 = [NSArray array];
  id object3 = [NSSet set];
  NSArray* contents = [NSArray arrayWithObjects:
                       @"This is a string",
                       object1,
                       object2,
                       object3,
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithListArray:contents delegate:nil];
  
  XCTAssertEqual([model objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], @"This is a string", @"The first object should be the string.");
  XCTAssertEqual([model objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]], object1, @"Object mismatch.");
  XCTAssertEqual([model objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]], object2, @"Object mismatch.");
  XCTAssertEqual([model objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]], object3, @"Object mismatch.");

  XCTAssertNil([model objectAtIndexPath:nil], @"Should be nil.");

  NIDebugAssertionsShouldBreak = NO;
  XCTAssertNil([model objectAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]], @"Should be nil.");
  XCTAssertNil([model objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]], @"Should be nil.");
  NIDebugAssertionsShouldBreak = YES;
}

- (void)testListTableViewModel_indexPathOfObject {
  id object1 = [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"];
  id object2 = [NSArray array];
  id object3 = [NSSet set];
  NSArray* contents = [NSArray arrayWithObjects:
                       object1,
                       object2,
                       object3,
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithListArray:contents delegate:nil];

  XCTAssertEqualObjects([model indexPathForObject:object1], [NSIndexPath indexPathForRow:0 inSection:0], @"Object not found at expected index path.");
  XCTAssertEqualObjects([model indexPathForObject:object2], [NSIndexPath indexPathForRow:1 inSection:0], @"Object not found at expected index path.");
  XCTAssertEqualObjects([model indexPathForObject:object3], [NSIndexPath indexPathForRow:2 inSection:0], @"Object not found at expected index path.");

  XCTAssertNil([model indexPathForObject:nil], @"Should be nil.");

  NIDebugAssertionsShouldBreak = NO;
  XCTAssertNil([model indexPathForObject:@"Random string"], @"Should be nil.");
  NIDebugAssertionsShouldBreak = YES;
}

- (void)testSectionedTableViewModel {
  NSArray* contents = [NSArray arrayWithObjects:
                       @"Section 1",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       @"Section 2",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       @"Section 3",
                       @"Section 4",
                       @"Section 5",
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithSectionedArray:contents delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 3, @"The first section should have 3 rows.");
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:1], 2, @"The second section should have 2 rows.");
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:2], 0, @"The third section should have 0 rows.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 5, @"There should be 5 sections.");
}

- (void)testSectionedTableViewModelWithFooters {
  NSArray* contents = [NSArray arrayWithObjects:
                       @"Section 1",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 1"],
                       @"Section 2",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 2"],
                       @"Section 3",
                       [NITableViewModelFooter footerWithTitle:@"Footer 3"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 4"],
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 5"],
                       @"Section 6",
                       @"Section 7",
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithSectionedArray:contents delegate:nil];
  
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:0], 3, @"The first section should have 3 rows.");
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:1], 2, @"The second section should have 2 rows.");
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:2], 0, @"The third section should have 0 rows.");
  XCTAssertEqual([model tableView:nil numberOfRowsInSection:3], 0, @"The fourth section should have 0 rows.");
  XCTAssertEqual([model numberOfSectionsInTableView:nil], 7, @"There should be 7 sections.");
  XCTAssertEqual([model tableView:nil titleForHeaderInSection:0], @"Section 1", @"The titles should match.");
  XCTAssertEqual([model tableView:nil titleForHeaderInSection:1], @"Section 2", @"The titles should match.");
  XCTAssertEqual([model tableView:nil titleForFooterInSection:0], @"Footer 1", @"The titles should match.");
  XCTAssertEqual([model tableView:nil titleForFooterInSection:1], @"Footer 2", @"The titles should match.");
  XCTAssertNil([model tableView:nil titleForFooterInSection:6], @"There should not be a title.");
}

- (void)testDynamicSectionedIndex {
  NSArray* contents = [NSArray arrayWithObjects:
                       @"A",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 1"],
                       @"C",
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 2"],
                       @"D",
                       [NITableViewModelFooter footerWithTitle:@"Footer 3"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 4"],
                       [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
                       [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
                       [NITableViewModelFooter footerWithTitle:@"Footer 5"],
                       nil];
  NITableViewModel* model = [[NITableViewModel alloc] initWithSectionedArray:contents delegate:nil];
  [model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:YES showsSummary:YES];

  XCTAssertEqual(model.sectionIndexType, NITableViewModelSectionIndexDynamic, @"Section index type should have been set.");
  NSArray* sectionIndexTitles = [model sectionIndexTitlesForTableView:nil];
  NSArray* expectedTitle = [NSArray arrayWithObjects:UITableViewIndexSearch, @"A", @"C", @"D", @"#", nil];
  XCTAssertEqual(sectionIndexTitles.count, expectedTitle.count, @"Arrays should be the same size.");
  for (NSInteger ix = 0; ix < sectionIndexTitles.count; ++ix) {
    XCTAssertEqual([sectionIndexTitles objectAtIndex:ix], [expectedTitle objectAtIndex:ix], @"Objects should match.");
  }

  [model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:YES];

  XCTAssertEqual(model.sectionIndexType, NITableViewModelSectionIndexDynamic, @"Section index type should have been set.");
  sectionIndexTitles = [model sectionIndexTitlesForTableView:nil];
  expectedTitle = [NSArray arrayWithObjects:@"A", @"C", @"D", @"#", nil];
  XCTAssertEqual(sectionIndexTitles.count, expectedTitle.count, @"Arrays should be the same size.");
  for (NSInteger ix = 0; ix < sectionIndexTitles.count; ++ix) {
    XCTAssertEqual([sectionIndexTitles objectAtIndex:ix], [expectedTitle objectAtIndex:ix], @"Objects should match.");
  }

  [model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:YES showsSummary:NO];

  XCTAssertEqual(model.sectionIndexType, NITableViewModelSectionIndexDynamic, @"Section index type should have been set.");
  sectionIndexTitles = [model sectionIndexTitlesForTableView:nil];
  expectedTitle = [NSArray arrayWithObjects:UITableViewIndexSearch, @"A", @"C", @"D", nil];
  XCTAssertEqual(sectionIndexTitles.count, expectedTitle.count, @"Arrays should be the same size.");
  for (NSInteger ix = 0; ix < sectionIndexTitles.count; ++ix) {
    XCTAssertEqual([sectionIndexTitles objectAtIndex:ix], [expectedTitle objectAtIndex:ix], @"Objects should match.");
  }

  [model setSectionIndexType:NITableViewModelSectionIndexDynamic showsSearch:NO showsSummary:NO];

  XCTAssertEqual(model.sectionIndexType, NITableViewModelSectionIndexDynamic, @"Section index type should have been set.");
  sectionIndexTitles = [model sectionIndexTitlesForTableView:nil];
  expectedTitle = [NSArray arrayWithObjects:@"A", @"C", @"D", nil];
  XCTAssertEqual(sectionIndexTitles.count, expectedTitle.count, @"Arrays should be the same size.");
  for (NSInteger ix = 0; ix < sectionIndexTitles.count; ++ix) {
    XCTAssertEqual([sectionIndexTitles objectAtIndex:ix], [expectedTitle objectAtIndex:ix], @"Objects should match.");
  }
}

@end
