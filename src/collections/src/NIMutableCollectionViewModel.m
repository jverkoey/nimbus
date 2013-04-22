//
// Copyright 2013 Jeff Verkoeyen
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMutableCollectionViewModel


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)addObject:(id)object {
  NICollectionViewModelSection* section = self.sections.count == 0 ? [self _appendSection] : self.sections.lastObject;
  [section.mutableRows addObject:object];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:section.mutableRows.count - 1
                                                     inSection:self.sections.count - 1]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)addObject:(id)object toSection:(NSUInteger)sectionIndex {
  NIDASSERT(sectionIndex >= 0 && sectionIndex < self.sections.count);
  NICollectionViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
  [section.mutableRows addObject:object];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:section.mutableRows.count - 1
                                                     inSection:sectionIndex]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)addObjectsFromArray:(NSArray *)array {
  NSMutableArray* indices = [NSMutableArray array];
  for (id object in array) {
    [indices addObject:[[self addObject:object] objectAtIndex:0]];
  }
  return indices;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)insertObject:(id)object atRow:(NSUInteger)row inSection:(NSUInteger)sectionIndex {
  NIDASSERT(sectionIndex >= 0 && sectionIndex < self.sections.count);
  NICollectionViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
  [section.mutableRows insertObject:object atIndex:row];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:sectionIndex]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *)addSectionWithTitle:(NSString *)title {
  NICollectionViewModelSection* section = [self _appendSection];
  section.headerTitle = title;
  return [NSIndexSet indexSetWithIndex:self.sections.count - 1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *)insertSectionWithTitle:(NSString *)title atIndex:(NSUInteger)index {
  NICollectionViewModelSection* section = [self _insertSectionAtIndex:index];
  section.headerTitle = title;
  return [NSIndexSet indexSetWithIndex:index];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *)removeSectionAtIndex:(NSUInteger)index {
  NIDASSERT(index >= 0 && index < self.sections.count);
  [self.sections removeObjectAtIndex:index];
  return [NSIndexSet indexSetWithIndex:index];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
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

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewModelSection (Mutable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)mutableRows {
  NIDASSERT([self.rows isKindOfClass:[NSMutableArray class]] || nil == self.rows);

  self.rows = nil == self.rows ? [NSMutableArray array] : self.rows;
  return (NSMutableArray *)self.rows;
}

@end
