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

#import "NIMutableTableViewModel.h"

#import "NITableViewModel+Private.h"
#import "NIMutableTableViewModel+Private.h"
#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMutableTableViewModel

@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)addObject:(id)object {
  NITableViewModelSection* section = self.sections.count == 0 ? [self _appendSection] : self.sections.lastObject;
  [section.mutableRows addObject:object];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:section.mutableRows.count - 1
                                                     inSection:self.sections.count - 1]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)addObject:(id)object toSection:(NSUInteger)sectionIndex {
  NIDASSERT(sectionIndex >= 0 && sectionIndex < self.sections.count);
  NITableViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
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
  NITableViewModelSection *section = [self.sections objectAtIndex:sectionIndex];
  [section.mutableRows insertObject:object atIndex:row];
  return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:sectionIndex]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT(indexPath.section < (NSInteger)self.sections.count);
  if (indexPath.section >= (NSInteger)self.sections.count) {
    return nil;
  }
  NITableViewModelSection* section = [self.sections objectAtIndex:indexPath.section];
  NIDASSERT(indexPath.row < (NSInteger)section.mutableRows.count);
  if (indexPath.row >= (NSInteger)section.mutableRows.count) {
    return nil;
  }
  [section.mutableRows removeObjectAtIndex:indexPath.row];
  return [NSArray arrayWithObject:indexPath];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *)addSectionWithTitle:(NSString *)title {
  NITableViewModelSection* section = [self _appendSection];
  section.headerTitle = title;
  return [NSIndexSet indexSetWithIndex:self.sections.count - 1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexSet *)insertSectionWithTitle:(NSString *)title atIndex:(NSUInteger)index {
  NITableViewModelSection* section = [self _insertSectionAtIndex:index];
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
- (void)updateSectionIndex {
  [self _compileSectionIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewModelSection *)_appendSection {
  if (nil == self.sections) {
    self.sections = [NSMutableArray array];
  }
  NITableViewModelSection* section = nil;
  section = [[NITableViewModelSection alloc] init];
  section.rows = [NSMutableArray array];
  [self.sections addObject:section];
  return section;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewModelSection *)_insertSectionAtIndex:(NSUInteger)index {
  if (nil == self.sections) {
    self.sections = [NSMutableArray array];
  }
  NITableViewModelSection* section = nil;
  section = [[NITableViewModelSection alloc] init];
  section.rows = [NSMutableArray array];
  NIDASSERT(index >= 0 && index <= self.sections.count);
  [self.sections insertObject:section atIndex:index];
  return section;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.delegate respondsToSelector:@selector(tableViewModel:canEditObject:atIndexPath:inTableView:)]) {
    id object = [self objectAtIndexPath:indexPath];
    return [self.delegate tableViewModel:self canEditObject:object atIndexPath:indexPath inTableView:tableView];
  } else {
    return NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self objectAtIndexPath:indexPath];
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    BOOL shouldDelete = YES;
    if ([self.delegate respondsToSelector:@selector(tableViewModel:shouldDeleteObject:atIndexPath:inTableView:)]) {
      shouldDelete = [self.delegate tableViewModel:self shouldDeleteObject:object atIndexPath:indexPath inTableView:tableView];
    }
    if (shouldDelete) {
      NSArray *indexPaths = [self removeObjectAtIndexPath:indexPath];
      UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
      if ([self.delegate respondsToSelector:@selector(tableViewModel:deleteRowAnimationForObject:atIndexPath:inTableView:)]) {
        animation = [self.delegate tableViewModel:self deleteRowAnimationForObject:object atIndexPath:indexPath inTableView:tableView];
      }
      [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    }
  }
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModelSection (Mutable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)mutableRows {
  NIDASSERT([self.rows isKindOfClass:[NSMutableArray class]] || nil == self.rows);
    
  self.rows = nil == self.rows ? [NSMutableArray array] : self.rows;
  return (NSMutableArray *)self.rows;
}

@end
