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

#import "NICollectionViewModel.h"

#import "NICollectionViewModel+Private.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static BOOL BothNilOrEqual(id object1, id object2) {
  return !(object1 || object2) || [object1 isEqual:object2];
}

@implementation NICollectionViewModel



- (id)initWithDelegate:(id<NICollectionViewModelDelegate>)delegate {
  if ((self = [super init])) {
    self.delegate = delegate;

    [self _resetCompiledData];
  }
  return self;
}

- (id)initWithListArray:(NSArray *)listArray delegate:(id<NICollectionViewModelDelegate>)delegate {
  if ((self = [self initWithDelegate:delegate])) {
    [self _compileDataWithListArray:listArray];
  }
  return self;
}

- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NICollectionViewModelDelegate>)delegate {
  if ((self = [self initWithDelegate:delegate])) {
    [self _compileDataWithSectionedArray:sectionedArray];
  }
  return self;
}

- (id)init {
  return [self initWithDelegate:nil];
}

#pragma mark - Compiling Data


- (void)_resetCompiledData {
  [self _setSectionsWithArray:nil];
  self.sectionIndexTitles = nil;
  self.sectionPrefixToSectionIndex = nil;
}

- (NICollectionViewModelSection *)_sectionFromListArray:(NSArray *)rows {
  NICollectionViewModelSection* section = [NICollectionViewModelSection section];
  section.rows = rows;
  return section;
}

- (void)_compileDataWithListArray:(NSArray *)listArray {
  [self _resetCompiledData];

  if (nil != listArray) {
    NICollectionViewModelSection* section = [self _sectionFromListArray:listArray];
    [self _setSectionsWithArray:@[ section ]];
  }
}

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
  [self _setSectionsWithArray:sections];
}

- (void)_setSectionsWithArray:(NSArray<NICollectionViewModelSection *> *)sectionsArray {
  self.sections = sectionsArray;
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NIDASSERT((NSUInteger)section < self.sections.count || 0 == self.sections.count);
  if ((NSUInteger)section < self.sections.count) {
    return [[[self.sections objectAtIndex:section] rows] count];

  } else {
    return 0;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self objectAtIndexPath:indexPath];

  return [self.delegate collectionViewModel:self
                      cellForCollectionView:collectionView
                                atIndexPath:indexPath
                                 withObject:object];
}

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

- (NSMapTable<id, NSIndexPath *> *)_reverseMap {
  NSArray<NICollectionViewModelSection *> *sections = self.sections;
  NSMapTable<id, NSIndexPath *> * reverseMap = [NSMapTable strongToStrongObjectsMapTable];
  for (NSUInteger sectionIndex = 0; sectionIndex < sections.count; sectionIndex++) {
    NICollectionViewModelSection *section = sections[sectionIndex];
    NSArray *items = section.rows;
    [reverseMap setObject:[NSIndexPath indexPathWithIndex:sectionIndex] forKey:section];
    for (NSUInteger itemIndex = 0; itemIndex < items.count; itemIndex ++) {
      id item = items[itemIndex];
      [reverseMap setObject:[NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex]
                     forKey:item];
    }
  }
  return reverseMap;
}

#pragma mark - Public


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

- (NSIndexPath *)indexPathForObject:(id)object {
  if (nil == object) {
    return nil;
  }

  NSArray<NICollectionViewModelSection *> *sections = self.sections;
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

- (void)enumerateItemsUsingBlock:(void (^)(id, NSIndexPath *, BOOL *))block {

  [self.sections enumerateObjectsUsingBlock:^(NICollectionViewModelSection *section,
                                              NSUInteger sectionIdx,
                                              BOOL *sectionStop) {
    [section.rows enumerateObjectsUsingBlock:^(id rowObject,
                                               NSUInteger itemIdx,
                                               BOOL *itemsStop) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx];
      block(rowObject, indexPath, itemsStop);
      *sectionStop = *itemsStop;
    }];
  }];
}

- (BOOL)isEqual:(id)object {
  NICollectionViewModel *other = (NICollectionViewModel *)object;
  return [other isKindOfClass:[NICollectionViewModel class]] &&
         BothNilOrEqual(self.delegate, other.delegate) &&
         BothNilOrEqual(self.sections, other.sections) &&
         BothNilOrEqual(self.sectionIndexTitles, other.sectionIndexTitles) &&
         BothNilOrEqual(self.sectionPrefixToSectionIndex, other.sectionPrefixToSectionIndex);
}

- (NSUInteger)hash {
  NSArray<NICollectionViewModelSection *>* sections = self.sections;
  NSArray* sectionIndexTitles = self.sectionIndexTitles;
  NSDictionary* sectionPrefixToSectionIndex = self.sectionPrefixToSectionIndex;

  NSUInteger hash = 0;
  hash ^= sections ? sections.hash : 0;
  hash ^= sectionIndexTitles ? sectionIndexTitles.hash : 0;
  hash ^= sectionPrefixToSectionIndex ? sectionPrefixToSectionIndex.hash : 0;

  return hash;
}

- (id)copyWithZone:(NSZone *)zone {
  NICollectionViewModel *copy = [[NICollectionViewModel alloc] init];
  copy.delegate = self.delegate;
  copy.sections = [self.sections copy];
  copy.sectionIndexTitles = [self.sectionIndexTitles copy];
  copy.sectionPrefixToSectionIndex = [self.sectionPrefixToSectionIndex copy];
  return copy;
}

- (NSString *)description {
  NSMutableString* result = [[super description] mutableCopy];
  [result appendString:@" sections: \n"];
  for (NICollectionViewModelSection *section in _sections) {
    [result appendFormat:@"section headerTitle: %@ footerTitle: %@\n", section.headerTitle, section.footerTitle];
    [result appendFormat:@"section rows: %@\n", section.rows];
  }

  [result appendFormat:@"sectionIndexTitles: %@", _sectionIndexTitles];
  return result;
}

@end


@implementation NICollectionViewModelFooter



+ (NICollectionViewModelFooter *)footerWithTitle:(NSString *)title {
  return [[self alloc] initWithTitle:title];
}

- (id)initWithTitle:(NSString *)title {
  if ((self = [super init])) {
    self.title = title;
  }
  return self;
}

@end


@implementation NICollectionViewModelSection



+ (id)section {
  return [[self alloc] init];
}

- (NICollectionViewModelSection *)mutableCopy {
  NICollectionViewModelSection *mutableCopy = [[NICollectionViewModelSection alloc] init];
  mutableCopy.headerTitle = self.headerTitle;
  mutableCopy.footerTitle = self.footerTitle;
  mutableCopy.rows = [self.rows mutableCopy];
  return mutableCopy;
}

- (BOOL)isEqual:(id)object {
  NICollectionViewModelSection *other = (NICollectionViewModelSection *)object;
  return [other isKindOfClass:[NICollectionViewModelSection class]] &&
         BothNilOrEqual(self.rows, other.rows) &&
         BothNilOrEqual(self.headerTitle, other.headerTitle) &&
         BothNilOrEqual(self.footerTitle, other.footerTitle);
}

- (NSUInteger)hash {
  NSString *headerTitle = self.headerTitle;
  NSString *footerTitle = self.footerTitle;
  NSArray* rows = self.rows;

  NSUInteger hash = 0;
  hash ^= headerTitle ? headerTitle.hash : 0;
  hash ^= footerTitle ? footerTitle.hash : 0;
  hash ^= rows ? rows.hash : 0;

  return hash;
}

- (id)copyWithZone:(NSZone *)zone {
  NICollectionViewModelSection *copy = [[NICollectionViewModelSection alloc] init];
  copy.headerTitle = self.headerTitle;
  copy.footerTitle = self.footerTitle;
  copy.rows = [self.rows copy];
  return copy;
}

@end
