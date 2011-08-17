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

#import "NITableViewModel.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewModel()

- (void)_resetCompiledData;
- (void)_compileDataWithSectionedArray:(NSArray *)sectionedArray;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModel

@synthesize delegate = _delegate;
#if NS_BLOCKS_AVAILABLE
@synthesize createCellBlock = _createCellBlock;
#endif // #if NS_BLOCKS_AVAILABLE


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_sectionTitles);
  NI_RELEASE_SAFELY(_sectionsOfRows);

#if NS_BLOCKS_AVAILABLE
  NI_RELEASE_SAFELY(_createCellBlock);
#endif // #if NS_BLOCKS_AVAILABLE

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<NITableViewModelDelegate>)delegate {
  if ((self = [super init])) {
    self.delegate = delegate;

    [self _resetCompiledData];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NITableViewModelDelegate>)delegate {
  if ((self = [self initWithDelegate:delegate])) {
    [self _compileDataWithSectionedArray:sectionedArray];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Compiling Data


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_resetCompiledData {
  _numberOfSections = 1;
  NI_RELEASE_SAFELY(_sectionTitles);
  NI_RELEASE_SAFELY(_sectionsOfRows);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_compileDataWithSectionedArray:(NSArray *)sectionedArray {
  [self _resetCompiledData];

  NSInteger numberOfSections = 0;
  NSMutableArray* sectionTitles = [NSMutableArray array];
  NSMutableArray* sectionsOfRows = [NSMutableArray array];
  NSMutableArray* currentSection = nil;

  for (id object in sectionedArray) {
    BOOL isSection = [object isKindOfClass:[NSString class]];
    if (isSection) {
      ++numberOfSections;
      [sectionTitles addObject:object];

      // Add a new section of rows.
      currentSection = [NSMutableArray array];
      [sectionsOfRows addObject:currentSection];

    } else {
      // If this asserts then you forgot to add an initial section title.
      // Your first section will be missing until you fix this.
      NIDASSERT(nil != currentSection);

      [currentSection addObject:object];
    }
  }

  // There is always at least one section.
  numberOfSections = MAX(1, numberOfSections);

  // Update the compiled information for this data source.
  _numberOfSections = numberOfSections;
  _sectionTitles = [sectionTitles copy];
  _sectionsOfRows = [sectionsOfRows copy];

  // Sanity check. If this asserts then it's likely that either the above code is broken or
  // you forgot to provide a title for the first section.
  NIDASSERT([_sectionTitles count] == [_sectionsOfRows count]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // We don't use [_sectionTitles count] because if there are no sections we should still return 1.
  return _numberOfSections;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NIDASSERT(section < [_sectionTitles count]);
  if (section < [_sectionTitles count]) {
    return [_sectionTitles objectAtIndex:section];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NIDASSERT(section < [_sectionsOfRows count]);
  if (section < [_sectionsOfRows count]) {
    return [[_sectionsOfRows objectAtIndex:section] count];

  } else {
    return 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath {
  id object = [self objectAtIndexPath:indexPath];

  UITableViewCell* cell = nil;

#if NS_BLOCKS_AVAILABLE
  if (nil != self.createCellBlock) {
    cell = self.createCellBlock(tableView, indexPath, object);
  }
#endif

  if (nil == cell) {
    cell = [self.delegate tableViewModel: self
                        cellForTableView: tableView
                             atIndexPath: indexPath
                              withObject: object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger section = [indexPath section];
  NSInteger row = [indexPath row];

  id object = nil;

  NIDASSERT(section < [_sectionsOfRows count]);
  if (section < [_sectionsOfRows count]) {
    NSArray* rows = [_sectionsOfRows objectAtIndex:section];

    NIDASSERT(row < [rows count]);
    if (row < [rows count]) {
      object = [rows objectAtIndex:row];
    }
  }

  return object;
}


@end
