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

#import "NICollectionViewModel.h"

#import "NICollectionViewModel+Private.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewModel

@synthesize sections = _sections;
@synthesize sectionIndexTitles = _sectionIndexTitles;
@synthesize sectionPrefixToSectionIndex = _sectionPrefixToSectionIndex;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<NICollectionViewModelDelegate>)delegate {
  if ((self = [super init])) {
    self.delegate = delegate;

    [self _resetCompiledData];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithListArray:(NSArray *)listArray delegate:(id<NICollectionViewModelDelegate>)delegate {
  if ((self = [self initWithDelegate:delegate])) {
    [self _compileDataWithListArray:listArray];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NICollectionViewModelDelegate>)delegate {
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
    NICollectionViewModelSection* section = [NICollectionViewModelSection section];
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
    BOOL isSectionFooter = [object isKindOfClass:[NICollectionViewModelFooter class]];

    NSString* nextSectionHeaderTitle = nil;

    if (isSection) {
      nextSectionHeaderTitle = object;

    } else if (isSectionFooter) {
      NICollectionViewModelFooter* footer = object;
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
        NICollectionViewModelSection* section = [NICollectionViewModelSection section];
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
    NICollectionViewModelSection* section = [NICollectionViewModelSection section];
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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UICollectionViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.sections.count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NIDASSERT((NSUInteger)section < self.sections.count || 0 == self.sections.count);
  if ((NSUInteger)section < self.sections.count) {
    return [[[self.sections objectAtIndex:section] rows] count];

  } else {
    return 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self objectAtIndexPath:indexPath];

  return [self.delegate collectionViewModel:self
                      cellForCollectionView:collectionView
                                atIndexPath:indexPath
                                 withObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  if ([self.delegate respondsToSelector:
       @selector(collectionViewModel:collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
    return [self.delegate collectionViewModel:self
                               collectionView:collectionView
            viewForSupplementaryElementOfKind:kind
                                  atIndexPath:indexPath];
  }
  return nil;
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


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewModelFooter

@synthesize title = _title;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NICollectionViewModelFooter *)footerWithTitle:(NSString *)title {
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
@implementation NICollectionViewModelSection

@synthesize headerTitle = _headerTitle;
@synthesize footerTitle = _footerTitle;
@synthesize rows = _rows;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)section {
  return [[self alloc] init];
}


@end
