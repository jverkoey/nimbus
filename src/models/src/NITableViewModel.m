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

#import "NITableViewModel+Private.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModel

@synthesize sections = _sections;
@synthesize sectionIndexTitles = _sectionIndexTitles;
@synthesize sectionPrefixToSectionIndex = _sectionPrefixToSectionIndex;
@synthesize sectionIndexType = _sectionIndexType;
@synthesize sectionIndexShowsSearch = _sectionIndexShowsSearch;
@synthesize sectionIndexShowsSummary = _sectionIndexShowsSummary;
@synthesize delegate = _delegate;
#if NS_BLOCKS_AVAILABLE
@synthesize createCellBlock = _createCellBlock;
#endif // #if NS_BLOCKS_AVAILABLE


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<NITableViewModelDelegate>)delegate {
  if ((self = [super init])) {
    self.delegate = delegate;

    _sectionIndexType = NITableViewModelSectionIndexNone;
    _sectionIndexShowsSearch = NO;
    _sectionIndexShowsSummary = NO;

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
- (id)init {
  return [self initWithDelegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Compiling Data


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_resetCompiledData {
  self.sections = nil;
  self.sectionIndexTitles = nil;
  self.sectionPrefixToSectionIndex = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_compileDataWithListArray:(NSArray *)listArray {
  [self _resetCompiledData];

  if (nil != listArray) {
    NITableViewModelSection* section = [NITableViewModelSection section];
    section.rows = listArray;
    self.sections = [NSArray arrayWithObject:section];
  }
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
      if (nil != currentSectionHeaderTitle
          || nil != currentSectionFooterTitle
          || nil != currentSectionRows) {
        NITableViewModelSection* section = [NITableViewModelSection section];
        section.headerTitle = currentSectionHeaderTitle;
        section.footerTitle = currentSectionFooterTitle;
        section.rows = currentSectionRows;
        [sections addObject:section];
      }

      currentSectionRows = nil;
      currentSectionHeaderTitle = nextSectionHeaderTitle;
      currentSectionFooterTitle = nil;
    }
  }

  // Commit any unfinished sections.
  if ([currentSectionRows count] > 0 || nil != currentSectionHeaderTitle) {
    NITableViewModelSection* section = [NITableViewModelSection section];
    section.headerTitle = currentSectionHeaderTitle;
    section.footerTitle = currentSectionFooterTitle;
    section.rows = currentSectionRows;
    [sections addObject:section];
  }
  currentSectionRows = nil;

  // Update the compiled information for this data source.
  self.sections = sections;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_compileSectionIndex {
  _sectionIndexTitles = nil;

  // Prime the section index and the map
  NSMutableArray* titles = nil;
  NSMutableDictionary* sectionPrefixToSectionIndex = nil;
  if (NITableViewModelSectionIndexNone != _sectionIndexType) {
    titles = [NSMutableArray array];
    sectionPrefixToSectionIndex = [NSMutableDictionary dictionary];

    // The search symbol is always first in the index.
    if (_sectionIndexShowsSearch) {
      [titles addObject:UITableViewIndexSearch];
    }
  }

  // A dynamic index shows the first letter of every section in the index in whatever order the
  // sections are ordered (this may not be alphabetical).
  if (NITableViewModelSectionIndexDynamic == _sectionIndexType) {
    for (NITableViewModelSection* section in _sections) {
      NSString* headerTitle = section.headerTitle;
      if ([headerTitle length] > 0) {
        NSString* prefix = [headerTitle substringToIndex:1];
        [titles addObject:prefix];
      }
    }

  } else if (NITableViewModelSectionIndexAlphabetical == _sectionIndexType) {
    // Use the localized indexed collation to create the index. In English, this will always be
    // the entire alphabet.
    NSArray* sectionIndexTitles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];

    // The localized indexed collection sometimes includes a # for summaries, but we might
    // not want to show a summary in the index, so prune it out. It's not guaranteed that
    // a # will actually be included in the section index titles, so we always attempt to
    // remove it for consistency's sake and then add it back down below if it is requested.
    for (NSString* letter in sectionIndexTitles) {
      if (![letter isEqualToString:@"#"]) {
        [titles addObject:letter];
      }
    }
  }

  // Add the section summary symbol if it was requested.
  if (_sectionIndexShowsSummary) {
    [titles addObject:@"#"];
  }

  // Build the prefix => section index map.
  if (NITableViewModelSectionIndexNone != _sectionIndexType) {

    // Map all of the sections to indices.
    NSInteger sectionIndex = 0;
    for (NITableViewModelSection* section in _sections) {
      NSString* headerTitle = section.headerTitle;
      if ([headerTitle length] > 0) {
        NSString* prefix = [headerTitle substringToIndex:1];
        if (nil == [sectionPrefixToSectionIndex objectForKey:prefix]) {
          [sectionPrefixToSectionIndex setObject:[NSNumber numberWithInt:sectionIndex] forKey:prefix];
        }
      }
      ++sectionIndex;
    }

    // Map the unmapped section titles to the next closest earlier section.
    NSInteger lastIndex = 0;
    for (NSString* title in titles) {
      NSString* prefix = [title substringToIndex:1];
      if (nil != [sectionPrefixToSectionIndex objectForKey:prefix]) {
        lastIndex = [[sectionPrefixToSectionIndex objectForKey:prefix] intValue];
        
      } else {
        [sectionPrefixToSectionIndex setObject:[NSNumber numberWithInt:lastIndex] forKey:prefix];
      }
    }
  }

  self.sectionIndexTitles = titles;
  self.sectionPrefixToSectionIndex = sectionPrefixToSectionIndex;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.sections.count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NIDASSERT((section >= 0 && (NSUInteger)section < self.sections.count) || 0 == self.sections.count);
  if (section >= 0 && (NSUInteger)section < self.sections.count) {
    return [[self.sections objectAtIndex:section] headerTitle];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  NIDASSERT((section >= 0 && (NSUInteger)section < self.sections.count) || 0 == self.sections.count);
  if (section >= 0 && (NSUInteger)section < self.sections.count) {
    return [[self.sections objectAtIndex:section] footerTitle];
    
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
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return self.sectionIndexTitles;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
  if (tableView.tableHeaderView) {
    if (index == 0 && [self.sectionIndexTitles count] > 0
        && [self.sectionIndexTitles objectAtIndex:0] == UITableViewIndexSearch)  {
      // This is a hack to get the table header to appear when the user touches the
      // first row in the section index.  By default, it shows the first row, which is
      // not usually what you want.
      [tableView scrollRectToVisible:tableView.tableHeaderView.bounds animated:NO];
      return -1;
    }
  }

  NSString* letter = [title substringToIndex:1];
  NSNumber* sectionIndex = [self.sectionPrefixToSectionIndex objectForKey:letter];
  return (nil != sectionIndex) ? [sectionIndex intValue] : -1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NIDASSERT((NSUInteger)section < self.sections.count || 0 == self.sections.count);
  if ((NSUInteger)section < self.sections.count) {
    return [[[self.sections objectAtIndex:section] rows] count];

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
    cell = [self.delegate tableViewModel:self
                        cellForTableView:tableView
                             atIndexPath:indexPath
                              withObject:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
  if (nil == indexPath) {
    return nil;
  }

  NSInteger section = [indexPath section];
  NSInteger row = [indexPath row];

  id object = nil;

  NIDASSERT((NSUInteger)section < self.sections.count);
  if ((NSUInteger)section < self.sections.count) {
    NSArray* rows = [[self.sections objectAtIndex:section] rows];

    NIDASSERT((NSUInteger)row < rows.count);
    if ((NSUInteger)row < rows.count) {
      object = [rows objectAtIndex:row];
    }
  }

  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)indexPathForObject:(id)object {
  if (nil == object) {
    return nil;
  }

  NSArray *sections = self.sections;
  for (NSUInteger sectionIndex = 0; sectionIndex < [sections count]; sectionIndex++) {
    NSArray* rows = [[sections objectAtIndex:sectionIndex] rows];
    for (NSUInteger rowIndex = 0; rowIndex < [rows count]; rowIndex++) {
      if ([object isEqual:[rows objectAtIndex:rowIndex]]) {
        return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
      }
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSectionIndexType:(NITableViewModelSectionIndex)sectionIndexType showsSearch:(BOOL)showsSearch showsSummary:(BOOL)showsSummary {
  if (_sectionIndexType != sectionIndexType
      || _sectionIndexShowsSearch != showsSearch
      || _sectionIndexShowsSummary != showsSummary) {
    _sectionIndexType = sectionIndexType;
    _sectionIndexShowsSearch = showsSearch;
    _sectionIndexShowsSummary = showsSummary;

    [self _compileSectionIndex];
  }
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModelFooter

@synthesize title = _title;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NITableViewModelFooter *)footerWithTitle:(NSString *)title {
  return [[self alloc] initWithTitle:title];
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
+ (id)section {
  return [[self alloc] init];
}


@end
