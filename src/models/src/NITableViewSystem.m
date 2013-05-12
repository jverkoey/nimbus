//
// Copyright 2011 Jared Egan
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

#import "NITableViewSystem.h"

#import "NICellFactory.h"
#import "NITableViewDelegate.h"

#import "NITableViewModel.h"
#import "NITableViewModel+Private.h"
#import "NITableViewDelegate.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewSystem

#pragma mark -
#pragma mark Init & Factory
////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithDelegate: (id<NITableViewSystemDelegate,UIScrollViewDelegate>)delegate {
  self = [super init];
  
  if (self) {
    self.cellFactory = [[NICellFactory alloc] init];
    self.delegate = delegate;
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDataSource:(NITableViewModel *) dataSource {
  if (_dataSource != dataSource) {
    _dataSource = dataSource;
    
    self.tableView.dataSource = self.dataSource;
    
    // Create delegate
    self.tableViewDelegate = [self createTableViewDelegate];
    
    if ([self.tableViewDelegate isKindOfClass:[NITableViewDelegate class]]) {
      [(NITableViewDelegate *)self.tableViewDelegate setDataSource:self.dataSource];
      [(NITableViewDelegate *)self.tableViewDelegate setTableSystem:self];
    }
    
    self.tableView.delegate = self.tableViewDelegate;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDataSourceWithArray:(NSArray *)listArray {
  [self setDataSource:[[NITableViewModel alloc] initWithListArray:listArray delegate:self]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createTableViewDelegate {
  // You may want to override this for custom views. You could subclass it,
  // or we find some other way to customize it.
  return [[NITableViewDelegate alloc] initWithDataSource:nil delegate:self.delegate];
}

#pragma mark -
#pragma mark NITableViewModelDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
  
  UITableViewCell *tableViewCell = [self.cellFactory tableViewModel:tableViewModel
                                                   cellForTableView:tableView
                                                        atIndexPath:indexPath
                                                         withObject:object];
  
	if ([self.delegate respondsToSelector:@selector(tableSystem:didAssignCell:toTableItem:atIndexPath:)]) {
		[self.delegate tableSystem:self didAssignCell:tableViewCell toTableItem:object atIndexPath:indexPath];
	}
  
	return tableViewCell;
}

#pragma mark -
#pragma mark Updating
////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath *)indexPathForTableItem:(id)object {
  
  
  int sectionIndex = 0;
  for (NITableViewModelSection *section in self.dataSource.sections) {
    int foundRow = [section.rows indexOfObject:object];
    
    if (foundRow != NSNotFound) {
      return [NSIndexPath indexPathForRow:foundRow inSection:sectionIndex];
    }
    
    sectionIndex++;
  }
  
  return nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)reloadCellForTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)rowAnimation {
  return [self reloadCellsForTableItems:@[object] withRowAnimation:rowAnimation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)reloadCellsForTableItems:(NSArray *)objects withRowAnimation:(UITableViewRowAnimation)rowAnimation {
  NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[objects count]];
  
  for (id object in objects) {
    NSIndexPath *path = [self indexPathForTableItem:object];
    if (path) {
      [indexPaths addObject:path];
    }
  }
  
  if ([indexPaths count] == 0) {
    return NO;
  }
  
  [self.tableView reloadRowsAtIndexPaths:indexPaths
                        withRowAnimation:rowAnimation];
  
  return YES;
}

// TODO: Finish creating methods to provide functionality that these do:
// - (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
// - (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertTableItem:(id)object atIndex:(int)index withRowAnimation:(UITableViewRowAnimation)animation {
  [self insertTableItem:object
            atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
       withRowAnimation:animation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertTableItem:(id)object atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
  
  // Update the datasource
  NITableViewModelSection *section = [self.dataSource.sections objectAtIndex:indexPath.section];
  
  NSMutableArray *newRows = [NSMutableArray arrayWithArray:section.rows];
  [newRows insertObject:object atIndex:indexPath.row];
  section.rows = newRows;
  
  // Update the table
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:animation];
  
  [self.tableView endUpdates];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)deleteTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)animation {
  NSIndexPath *indexPath = [self indexPathForTableItem:object];
  
  NSAssert(indexPath, @"Attempting to delete table item not in the table: %@", object);
  
  if (indexPath == nil) {
    // Can't find object, so it must be gone already. Nothing to do.
    return NO;
  }
  
  // Update the datasource
  NITableViewModelSection *section = [self.dataSource.sections objectAtIndex:indexPath.section];
  
  NSMutableArray *newRows = [NSMutableArray arrayWithArray:section.rows];
  [newRows removeObject:object];
  section.rows = newRows;
  
  // Update the table
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:animation];
  
  [self.tableView endUpdates];
  
  return YES;
}
@end
