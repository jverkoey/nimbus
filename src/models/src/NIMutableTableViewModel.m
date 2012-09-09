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
- (NSArray *)addObjectsFromArray:(NSArray *)array {
  NSMutableArray* indices = [NSMutableArray array];
  for (id object in array) {
    [indices addObject:[self addObject:object]];
  }
  return indices;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT(indexPath.section < self.sections.count);
  NITableViewModelSection* section = [self.sections objectAtIndex:indexPath.section];
  NIDASSERT(indexPath.row < section.mutableRows.count);
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

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModelSection (Mutable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray *)mutableRows {
  NIDASSERT([self.rows isKindOfClass:[NSMutableArray class]]);
  return (NSMutableArray *)self.rows;
}

@end
