//
// Copyright 2012 Jared Egan
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NimbusCore.h"

#import "NITableViewModel.h"

@class NITableViewDelegate;
@class NITableViewSystem;
@class NICellFactory;

/**
 * NITableViewSystemDelegates receive messages from the tableViewDelegate, including:
 * - table row selection
 * - Forwarding some UIScrollViewDelegate messages, so UIViewControllers can do neat things.
 */
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol NITableViewSystemDelegate <NSObject>

@optional
- (void)tableSystem:(NITableViewSystem *)tableSystem didSelectObject:(id)object
        atIndexPath:(NSIndexPath *)indexPath;
- (void)tableSystem:(NITableViewSystem *)tableSystem didAssignCell:(id)object toTableItem:(id)tableItem
		atIndexPath:(NSIndexPath *)indexPath;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewSystem : NSObject <NITableViewModelDelegate> {

}

// UI
@property (nonatomic, readonly) UITableView *tableView;

// Data & Logic
@property (nonatomic, strong) NITableViewModel *dataSource;
@property (nonatomic, strong) NICellFactory *cellFactory;
@property (nonatomic, strong) NITableViewDelegate *tableViewDelegate;
@property (nonatomic, unsafe_unretained) id<NITableViewSystemDelegate, UIScrollViewDelegate> delegate;

+ (id)tableSystemWithFrame:(CGRect)frame style:(UITableViewStyle)tableStyle delegate:(id<NITableViewSystemDelegate, UIScrollViewDelegate>)delegate;

/**
 *  A convenience method. Sets the datasource and reloads _tableView if specified.
 */
- (void)setDataSource:(NITableViewModel *)dataSource reloadTableView:(BOOL)reloadTableView;

/**
 *  A convenience method. Instead of worrying about making a NITableViewModel, just set the array of items.
 */
- (void)setDataSourceWithListArray:(NSArray *)listArray;
- (void)setDataSourceWithListArray:(NSArray *)listArray reloadTableView:(BOOL)reloadTableView;

/**
 *  Returns a UITableView with the given frame. Subclasses can return table view preconfigured with more custom view tweaks.
 */
- (UITableView *)createTableViewWithFrame:(CGRect)frame withStyle:(UITableViewStyle)tableStyle;

- (NSIndexPath *)indexPathForTableItem:(id)object;

/**
 *  Given a table item, reload that table cell with the given animation.
 *  @returns YES if a NSIndexPath was found and reloadCellsAtIndexPaths: was called on the table, NO otherwise.
 */
- (BOOL)reloadCellForTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)rowAnimation;
- (BOOL)reloadCellsForTableItems:(NSArray *)objects withRowAnimation:(UITableViewRowAnimation)rowAnimation;

- (void)insertTableItem:(id)object atIndex:(int)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertTableItem:(id)object atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *  Given a table item, remove that item from the datasource, and the corresponding cell from the table view with the given animation.
 *  @returns YES if a NSIndexPath was found and deleteRowsAtIndexPaths: was called on the table, NO otherwise.
 */
- (BOOL)deleteTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)animation;

@end



