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
@interface NITableViewModelSection : NSObject {
@private
  NSString* _headerTitle;
  NSString* _footerTitle;
  NSArray* _rows;
}

+ (id)section;

@property (nonatomic, readwrite, copy) NSString* headerTitle;
@property (nonatomic, readwrite, copy) NSString* footerTitle;
@property (nonatomic, readwrite, copy) NSArray* rows;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewModel()

- (void)_resetCompiledData;
- (void)_compileDataWithListArray:(NSArray *)listArray;
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
  NI_RELEASE_SAFELY(_sections);

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
- (id)initWithListArray:(NSArray *)listArray delegate:(id<NITableViewModelDelegate>)delegate {
  if ((self = [self initWithDelegate:delegate])) {
    [self _compileDataWithListArray:listArray];
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
  NI_RELEASE_SAFELY(_sections);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_compileDataWithListArray:(NSArray *)listArray {
  [self _resetCompiledData];

  NITableViewModelSection* section = [NITableViewModelSection section];
  section.rows = listArray;
  _sections = [[NSArray arrayWithObject:section] retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_compileDataWithSectionedArray:(NSArray *)sectionedArray {
  [self _resetCompiledData];

  NSMutableArray* sections = [NSMutableArray array];

  NSString* currentSectionHeaderTitle = nil;
  NSString* currentSectionFooterTitle = nil;
  NSMutableArray* currentSectionRows = nil;

  for (id object in sectionedArray) {
    BOOL isSection = [object isKindOfClass:[NSString class]];
    BOOL isSectionFooter = [object isKindOfClass:[NITableViewModelFooter class]];

    NSString* nextSectionHeaderTitle = nil;

    if (isSection) {
      nextSectionHeaderTitle = object;

    } else if (isSectionFooter) {
      NITableViewModelFooter* footer = object;
      currentSectionFooterTitle = footer.title;

    } else {
      if (nil == currentSectionRows) {
        currentSectionRows = [[NSMutableArray alloc] init];
      }
      [currentSectionRows addObject:object];
    }

    // A section footer or title has been encountered,
    if (nil != nextSectionHeaderTitle || nil != currentSectionFooterTitle) {
      if (nil != currentSectionFooterTitle
          || nil != currentSectionFooterTitle
          || nil != currentSectionRows) {
        NITableViewModelSection* section = [NITableViewModelSection section];
        section.headerTitle = currentSectionHeaderTitle;
        section.footerTitle = currentSectionFooterTitle;
        section.rows = currentSectionRows;
        [sections addObject:section];
      }

      NI_RELEASE_SAFELY(currentSectionRows);
      currentSectionHeaderTitle = nextSectionHeaderTitle;
      currentSectionFooterTitle = nil;
    }
  }
  
  // Commit any unfinished sections.
  if (NIIsArrayWithObjects(currentSectionRows)) {
    NITableViewModelSection* section = [NITableViewModelSection section];
    section.headerTitle = currentSectionHeaderTitle;
    section.footerTitle = currentSectionFooterTitle;
    section.rows = currentSectionRows;
    [sections addObject:section];
  }
  NI_RELEASE_SAFELY(currentSectionRows);

  // Update the compiled information for this data source.
  _sections = [sections copy];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // We don't use [_sectionTitles count] because if there are no sections we should still return 1.
  return MAX(1, [_sections count]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NIDASSERT(section < [_sections count] || 0 == [_sections count]);
  if (section < [_sections count]) {
    return [[_sections objectAtIndex:section] headerTitle];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  NIDASSERT(section < [_sections count] || 0 == [_sections count]);
  if (section < [_sections count]) {
    return [[_sections objectAtIndex:section] footerTitle];
    
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // This is a static model; nothing can be edited.
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NIDASSERT(section < [_sections count] || 0 == [_sections count]);
  if (section < [_sections count]) {
    return [[[_sections objectAtIndex:section] rows] count];

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

  NIDASSERT(section < [_sections count]);
  if (section < [_sections count]) {
    NSArray* rows = [[_sections objectAtIndex:section] rows];

    NIDASSERT(row < [rows count]);
    if (row < [rows count]) {
      object = [rows objectAtIndex:row];
    }
  }

  return object;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModelFooter

@synthesize title = _title;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NITableViewModelFooter *)footerWithTitle:(NSString *)title {
  return [[[self alloc] initWithTitle:title] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_title);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title {
  if ((self = [super init])) {
    self.title = title;
  }
  return self;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModelSection

@synthesize headerTitle = _headerTitle;
@synthesize footerTitle = _footerTitle;
@synthesize rows = _rows;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_headerTitle);
  NI_RELEASE_SAFELY(_footerTitle);
  NI_RELEASE_SAFELY(_rows);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)section {
  return [[[self alloc] init] autorelease];
}


@end
