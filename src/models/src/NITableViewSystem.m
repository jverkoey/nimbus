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

#import "NITableViewModel.h"
#import "NITableViewModel+Private.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewSystem

#pragma mark -
#pragma mark Init & Factory
////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
  self = [super init];

  if (self) {
    self.cellFactory = [[NICellFactory alloc] init];
  }
  
  return self;  
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_tableView removeObserver:self forKeyPath:@"delegate"];
    _tableView.delegate = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithDelegate: (id<NITableViewSystemDelegate>)delegate {
  self = [self init];
  
  if (self) {
    _actions = [[NITableViewSystemActions alloc] initWithTarget:delegate];
    _delegate = delegate;
  }
  
  return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTableView:(UITableView *)tableView andDelegate:(id<NITableViewSystemDelegate>)delegate {
  self = [self initWithDelegate:delegate];

  if (self) {
    self.tableView = tableView;
    // No need to set anything else because the table is empty right now anyways
  }

  return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTableView:(UITableView *)tableView {
  if (tableView != _tableView) {
    [_tableView removeObserver:self forKeyPath:@"delegate"];
    _tableView = tableView;
    if (_tableView.delegate) {
      _tableView.delegate = [_actions forwardingTo:_tableView.delegate];
    } else if (_delegate) {
      _tableView.delegate = [_actions forwardingTo:_delegate];
    }else {
      _tableView.delegate = _actions;
    }

    [_tableView addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:nil];
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.tableView && [keyPath isEqualToString:@"delegate"]) {
        id new = change[NSKeyValueChangeNewKey];        
        if (new != self.actions) {
            self.tableView.delegate = [self.actions forwardingTo:new];
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDataSource:(NIMutableTableViewModel *) dataSource {
  if (_dataSource != dataSource) {
    _dataSource = dataSource;
    
    self.tableView.dataSource = self.dataSource;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setDataSourceWithArray:(NSArray *)listArray {
  [self setDataSource:[[NIMutableTableViewModel alloc] initWithListArray:listArray delegate:self]];
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
#pragma mark NIMutableTableViewModelDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel
         canEditObject:(id)object
           atIndexPath:(NSIndexPath *)indexPath
           inTableView:(UITableView *)tableView {
    
    if ([self.delegate respondsToSelector:@selector(tableSystem:canEditObject:atIndexPath:)]) {
        return [self.delegate tableSystem:self canEditObject:object atIndexPath:indexPath];
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableViewModel:(NIMutableTableViewModel *)tableViewModel
    shouldDeleteObject:(id)object
           atIndexPath:(NSIndexPath *)indexPath
           inTableView:(UITableView *)tableView {
    
    if ([self.delegate respondsToSelector:@selector(tableSystem:shouldDeleteObject:atIndexPath:)]) {
        return [self.delegate tableSystem:self shouldDeleteObject:object atIndexPath:indexPath];
    }
    
    return NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewRowAnimation)tableViewModel:(NIMutableTableViewModel *)tableViewModel
              deleteRowAnimationForObject:(id)object
                              atIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView {
    
    if ([self.delegate respondsToSelector:@selector(tableSystem:deleteRowAnimationForObject:atIndexPath:)]) {
        return [self.delegate tableSystem:self deleteRowAnimationForObject:object atIndexPath:indexPath];
    }
    
    return UITableViewRowAnimationAutomatic;
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
- (id)tableObjectForIndexPath:(NSIndexPath *)indexPath {
  if ([self.dataSource.sections count] >= (indexPath.section + 1)) {
    NITableViewModelSection *section = [self.dataSource.sections objectAtIndex:indexPath.section];
    if ([section.rows count] >= (indexPath.row + 1)) {
      return [section.rows objectAtIndex:indexPath.row];
    }
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
    
  NSArray *indexPaths = [self.dataSource insertObject:object atRow:indexPath.row inSection:indexPath.section];
  
  // Update the table
  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
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
    
  NSArray *indexPaths = [self.dataSource removeObjectAtIndexPath:indexPath];
  
  // Update the table
  [self.tableView beginUpdates];
  [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
  [self.tableView endUpdates];
  
  return YES;
}
@end
