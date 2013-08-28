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

#import <Foundation/Foundation.h>

#import "NIPreprocessorMacros.h"
#import "NIMutableTableViewModel.h"

@class NITableViewDelegate;
@class NITableViewSystem;
@class NICellFactory;
@class NITableViewSystemActions;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * NITableViewSystemDelegates receive messages from the tableViewDelegate, including:
 * - table row selection
 * - Forwarding some UIScrollViewDelegate messages, so UIViewControllers can do neat things.
*/
@protocol NITableViewSystemDelegate <NSObject, UITableViewDelegate>

@optional
- (void)tableSystem:(NITableViewSystem *)tableSystem didSelectObject:(id)object
        atIndexPath:(NSIndexPath *)indexPath;
- (void)tableSystem:(NITableViewSystem *)tableSystem didAssignCell:(id)object toTableItem:(id)tableItem
    atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)tableSystem:(NITableViewSystem *)tableSystem canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableSystem:(NITableViewSystem *)tableSystem shouldDeleteObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewRowAnimation)tableSystem:(NITableViewSystem *)tableSystem deleteRowAnimationForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
@end

#import "NITableViewSystemActions.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewSystem : NSObject <NIMutableTableViewModelDelegate>

- (id) initWithTableView: (UITableView*) tableView andDelegate: (id<NITableViewSystemDelegate>) delegate;
- (id) initWithDelegate: (id<NITableViewSystemDelegate>) delegate;

/**
 * Given a table object, return the index path if any.
 *
 * @param object The table object
 */
- (NSIndexPath *)indexPathForTableItem:(id)object;

/**
 * Given an indexPath, return the table object if it's a valid indexPath. Otherwise, returns nil.
 *
 * @param indexPath The index path.
 */
- (id)tableObjectForIndexPath:(NSIndexPath *)indexPath;

/**
 * Given a table item, reload that table cell with the given animation.
 *
 * @returns YES if a NSIndexPath was found and reloadCellsAtIndexPaths: was called on the table,
 * NO otherwise.
 */
- (BOOL)reloadCellForTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)rowAnimation;
- (BOOL)reloadCellsForTableItems:(NSArray *)objects withRowAnimation:(UITableViewRowAnimation)rowAnimation;

- (void)insertTableItem:(id)object atIndex:(int)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertTableItem:(id)object atIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

/**
 * Given a table item, remove that item from the datasource, and the corresponding cell from the
 * table view with the given animation.
 *
 * @returns YES if a NSIndexPath was found and deleteRowsAtIndexPaths: was called on the table, 
 * NO otherwise.
 */
- (BOOL)deleteTableItem:(id)object withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *  A convenience method. Instead of worrying about making a NITableViewModel, just set the array of items.
 *  Don't forget to call reloadData on the table view.
 */
- (void)setDataSourceWithArray:(NSArray *)listArray;

/**
 * The table view managed by this tableview system. You are responsible for creating and setting
 * this in viewDidLoad (or at another time of your choosing)
 */
@property (nonatomic, NI_STRONG) UITableView  *tableView;

/**
 * Generally you don't have to worry about this, we'll manage it for you via the array data setters.
 * That's pretty much the point of using the NITableViewSystem.
 */
@property (nonatomic, NI_STRONG) NIMutableTableViewModel *dataSource;

/**
 * Generally you can use the default cell factory, since it will use the cellClass of the table object.
 */
@property (nonatomic, NI_STRONG) NICellFactory          *cellFactory;

/**
 * Table view systems do fancy footwork with the table view delegates to make things easier. As a result,
 * you can't be the table view's delegate. Instead, you should use this actions object to assign
 * actions to your table cell objects. See the NimbusCatalog TableSystemViewController example.
 */
@property (nonatomic, readonly, NI_STRONG) NITableViewSystemActions     *actions;

@property (nonatomic, NI_WEAK) id<NITableViewSystemDelegate, UIScrollViewDelegate> delegate;

@end
