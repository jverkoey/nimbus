//
//  NITableViewSystem.m
//  Nimbus
//
//  Created by Jared Egan on 2/27/13.
//  Copyright 2013 Jeff Verkoeyen. All rights reserved.
//

#import "NITableViewSystem.h"
#import "NICellFactory.h"

#import "NITableViewModel.h"
#import "NITableViewModel+Private.h"
#import "NITableViewDelegate.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewSystem() {

}

// UI
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewSystem

#pragma mark -
#pragma mark Init & Factory
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    self = [super init];

	if (self) {
        self.cellFactory = [[NICellFactory alloc] init];
	}

	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)tableSystemWithFrame:(CGRect)frame style:(UITableViewStyle)tableStyle delegate:(id<NITableViewSystemDelegate, UIScrollViewDelegate>)delegate {
    NITableViewSystem *result = [[self alloc] init];
    result.delegate = delegate;
    result.tableViewStyle = tableStyle;
    result.myTableView = [result createTableViewWithFrame:frame withStyle:result.tableViewStyle];

    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {

}

#pragma mark -
#pragma mark NITableViewSystem
////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView *)tableView {
    if (self.myTableView == nil) {
        self.myTableView = [self createTableView];
    }

    return self.myTableView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView *)createTableView {
    // Picks an effectively random size
    return [self createTableViewWithFrame:CGRectMake(0, 0, 320, 416) withStyle:UITableViewStylePlain];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView *)createTableViewWithFrame:(CGRect)frame withStyle:(UITableViewStyle)tableStyle {
    UITableView *result = [[UITableView alloc] initWithFrame:frame style:tableStyle];

    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(NITableViewModel *)newDataSource {
    [self setDataSource:newDataSource reloadTableView:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(NITableViewModel *)newDataSource reloadTableView:(BOOL)reloadTableView {
    if (self.dataSource != newDataSource) {
        _dataSource = newDataSource;

        self.tableView.dataSource = self.dataSource;

        // Create delegate
        self.tableViewDelegate = [self createTableViewDelegate];

        if ([self.tableViewDelegate isKindOfClass:[NITableViewDelegate class]]) {
            [(NITableViewDelegate *)self.tableViewDelegate setDataSource:self.dataSource];
            [(NITableViewDelegate *)self.tableViewDelegate setTableSystem:self];
        }

        self.tableView.delegate = self.tableViewDelegate;
    }

    if (reloadTableView) {
        [self.tableView reloadData];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)createTableViewDelegate {
    // You may want to override this for custom views. You could subclass it,
    // or we find some other way to customize it.
    return [[NITableViewDelegate alloc]
            initWithDataSource:nil
            delegate:self.delegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSourceWithListArray:(NSArray *)listArray {
    [self setDataSourceWithListArray:listArray reloadTableView:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSourceWithListArray:(NSArray *)listArray reloadTableView:(BOOL)reloadTableView {
    [self setDataSource:[[NITableViewModel alloc] initWithListArray:listArray delegate:self]
        reloadTableView:reloadTableView];
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


