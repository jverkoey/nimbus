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

#import "NIMutableCollectionViewModel.h"

#import "NICollectionViewModel.h"
#import "NICollectionViewModel+Private.h"
#import "NIMutableCollectionViewModel+Private.h"
#import "NimbusCore.h"


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif


@implementation NIMutableCollectionViewModel


#pragma mark - Public


- (NSArray *)addObject:(id)object {
  NICollectionViewModelSection* section = self.sections.count == 0 ? [self _appendSection] : self.sections.lastObject;
  [section.mutableRows addObject:object];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:section.mutableRows.count - 1
                                                     inSection:self.sections.count - 1]];
}

- (NSArray *)addObject:(id)object toSection:(NSUInteger)sectionIndex {
  NIDASSERT(sectionIndex >= 0 && sectionIndex < self.sections.count);
  NICollectionViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
  [section.mutableRows addObject:object];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:section.mutableRows.count - 1
                                                     inSection:sectionIndex]];
}

- (NSArray *)addObjectsFromArray:(NSArray *)array {
  NSMutableArray* indices = [NSMutableArray array];
  for (id object in array) {
    [indices addObject:[[self addObject:object] objectAtIndex:0]];
  }
  return indices;
}

- (NSArray *)insertObject:(id)object atRow:(NSUInteger)row inSection:(NSUInteger)sectionIndex {
  NIDASSERT(sectionIndex >= 0 && sectionIndex < self.sections.count);
  NICollectionViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
  [section.mutableRows insertObject:object atIndex:row];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:sectionIndex]];
}

- (NSArray *)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT(indexPath.section < (NSInteger)self.sections.count);
  if (indexPath.section >= (NSInteger)self.sections.count) {
    return nil;
  }
  NICollectionViewModelSection* section = [self.sections objectAtIndex:indexPath.section];
  NIDASSERT(indexPath.row < (NSInteger)section.mutableRows.count);
  if (indexPath.row >= (NSInteger)section.mutableRows.count) {
    return nil;
  }
  [section.mutableRows removeObjectAtIndex:indexPath.row];
  return [NSArray arrayWithObject:indexPath];
}

- (NSIndexSet *)addSectionWithTitle:(NSString *)title {
  NICollectionViewModelSection* section = [self _appendSection];
  section.headerTitle = title;
  return [NSIndexSet indexSetWithIndex:self.sections.count - 1];
}

- (NSIndexSet *)insertSectionWithTitle:(NSString *)title atIndex:(NSUInteger)index {
  NICollectionViewModelSection* section = [self _insertSectionAtIndex:index];
  section.headerTitle = title;
  return [NSIndexSet indexSetWithIndex:index];
}

- (NSIndexSet *)removeSectionAtIndex:(NSUInteger)index {
  NIDASSERT(index >= 0 && index < self.sections.count);
  [self.sections removeObjectAtIndex:index];
  return [NSIndexSet indexSetWithIndex:index];
}

- (void)updateToMatchModel:(NICollectionViewModel *)other {
  self.sections = [NSMutableArray arrayWithCapacity:other.sections.count];
  for (NICollectionViewModelSection *section in other.sections) {
    [self.sections addObject:[section mutableCopy]];
  }
  self.sectionIndexTitles = [other.sectionIndexTitles mutableCopy];
  self.sectionPrefixToSectionIndex = [other.sectionPrefixToSectionIndex mutableCopy];
}

static NSIndexSet *IntersectIndexSets(NSIndexSet *set1, NSIndexSet *set2) {
  NSMutableIndexSet *intersectSet = [NSMutableIndexSet indexSet];
  [set1 enumerateIndexesUsingBlock:^(NSUInteger index, BOOL * _Nonnull stop) {
    if ([set2 containsIndex:index]) {
      [intersectSet addIndex:index];
    }
  }];
  return intersectSet;
}

- (void)updateToMatchModel:(NICollectionViewModel *)other
        withCollectionView:(UICollectionView *)collectionView {

  // First compute the required set of collection view updates
  NSMapTable<id, NSIndexPath *> *firstReverseMap = [self _reverseMap];
  NSMapTable<id, NSIndexPath *> *secondReverseMap = [other _reverseMap];

  NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
  NSMutableIndexSet *sectionsToInsert = [NSMutableIndexSet indexSet];
  NSMutableDictionary *sectionsToMove = [NSMutableDictionary dictionary];

  // Detect section moves and deletions.
  for (NSUInteger firstIndex = 0; firstIndex < self.sections.count; firstIndex++) {
    NICollectionViewModelSection *firstSection = self.sections[firstIndex];
    NSIndexPath *secondIndex = [secondReverseMap objectForKey:firstSection];
    if (secondIndex) {
      sectionsToMove[@(firstIndex)] = @(secondIndex.section);
    } else {
      [sectionsToDelete addIndex:firstIndex];
    }
  }

  // Detect section insertions.
  for (NSUInteger secondIndex = 0; secondIndex < other.sections.count; secondIndex++) {
    NICollectionViewModelSection *secondSection = other.sections[secondIndex];
    NSIndexPath *firstIndex = [firstReverseMap objectForKey:secondSection];
    if (!firstIndex) {
      [sectionsToInsert addIndex:secondIndex];
    }
  }

  // Treat sections that are deleted then inserted as reloadable.
  NSIndexSet *sectionsToReload = IntersectIndexSets(sectionsToDelete, sectionsToInsert);
  [sectionsToDelete removeIndexes:sectionsToReload];
  [sectionsToInsert removeIndexes:sectionsToReload];

  NSMutableArray *pathsToDelete = [NSMutableArray array];
  NSMutableArray *pathsToInsert = [NSMutableArray array];
  NSMutableDictionary *pathsToMove = [NSMutableDictionary dictionary];

  // Detect item moves and deletions.
  [self enumerateItemsUsingBlock:^(id object, NSIndexPath *firstIndexPath, BOOL *stop) {
    NSIndexPath *secondIndexPath = [secondReverseMap objectForKey:object];
    if (secondIndexPath) {
      pathsToMove[firstIndexPath] = secondIndexPath;
    } else {
      [pathsToDelete addObject:firstIndexPath];
    }
  }];

  // Detect item insertions.
  [other enumerateItemsUsingBlock:^(id object, NSIndexPath *secondIndexPath, BOOL *stop) {
    NSIndexPath *firstIndexPath = [firstReverseMap objectForKey:object];
    if (!firstIndexPath) {
      [pathsToInsert addObject:secondIndexPath];
    }
  }];

  // Update the current model to match the new model.
  [self updateToMatchModel:other];

  // Finally update the collection view.
  [collectionView deleteSections:sectionsToDelete];
  [collectionView insertSections:sectionsToInsert];
  [collectionView reloadSections:sectionsToReload];
  [sectionsToMove enumerateKeysAndObjectsUsingBlock:^(NSNumber *fromIndex,
                                                      NSNumber *toIndex,
                                                      BOOL *stop) {
    [collectionView moveSection:fromIndex.unsignedIntegerValue
                      toSection:toIndex.unsignedIntegerValue];
  }];

  [collectionView deleteItemsAtIndexPaths:pathsToDelete];
  [collectionView insertItemsAtIndexPaths:pathsToInsert];
  [pathsToMove enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *fromIndexPath,
                                                   NSIndexPath *toIndexPath,
                                                   BOOL *stop) {
    [collectionView moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
  }];
}

#pragma mark - Private


- (NICollectionViewModelSection *)_appendSection {
  if (nil == self.sections) {
    self.sections = [NSMutableArray array];
  }
  NICollectionViewModelSection* section = nil;
  section = [[NICollectionViewModelSection alloc] init];
  section.rows = [NSMutableArray array];
  [self.sections addObject:section];
  return section;
}

- (NICollectionViewModelSection *)_insertSectionAtIndex:(NSUInteger)index {
  if (nil == self.sections) {
    self.sections = [NSMutableArray array];
  }
  NICollectionViewModelSection* section = nil;
  section = [[NICollectionViewModelSection alloc] init];
  section.rows = [NSMutableArray array];
  NIDASSERT(index >= 0 && index <= self.sections.count);
  [self.sections insertObject:section atIndex:index];
  return section;
}

- (void)_setSectionsWithArray:(NSArray<NICollectionViewModelSection *> *)sectionsArray {
  if ([sectionsArray isKindOfClass:[NSMutableArray class]]) {
    self.sections = (NSMutableArray *)sectionsArray;
  } else {
    self.sections = [sectionsArray mutableCopy];
  }
}

- (NICollectionViewModelSection *)_sectionFromListArray:(NSArray *)rows {
  NICollectionViewModelSection* section = [NICollectionViewModelSection section];
  section.rows = [rows isKindOfClass:[NSMutableArray class]] ? rows : [rows mutableCopy];
  return section;
}

@end


@implementation NICollectionViewModelSection (Mutable)


- (NSMutableArray *)mutableRows {
  NIDASSERT([self.rows isKindOfClass:[NSMutableArray class]] || nil == self.rows);

  self.rows = nil == self.rows ? [NSMutableArray array] : self.rows;
  return (NSMutableArray *)self.rows;
}

@end
