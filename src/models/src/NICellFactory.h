//
// Copyright 2011 Jeff Verkoeyen
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

#import "NITableViewModel.h"

/**
 * A simple factory for creating table view cells from objects.
 *
 * This factory provides a single method that accepts an object and returns a UITableViewCell
 * for use in a UITableView. A cell will only be returned if the object passed to the factory
 * conforms to the NICellObject protocol. The created cell should ideally conform to
 * the NICell protocol. If it does, the object will be passed to it via
 * @link NICell::shouldUpdateCellWithObject: shouldUpdateCellWithObject:@endlink before the
 * factory method returns.
 *
 * This factory is designed to be used with NITableViewModels, though one could easily use
 * it with other table view data source implementations simply by providing nil for the table
 * view model.
 *
 * If you instantiate an NICellFactory then you can provide explicit mappings from objects
 * to cells. This is helpful if the effort required to implement the NICell protocol on
 * an object outweighs the benefit of using the factory, i.e. when you want to map
 * simple types such as NSString to cells.
 *
 *      @ingroup TableCellFactory
 */
@interface NICellFactory : NSObject <NITableViewModelDelegate>

/**
 * Creates a cell from a given object if and only if the object conforms to the NICellObject
 * protocol.
 *
 * This method signature matches the NITableViewModelDelegate method so that you can
 * set this factory as the model's delegate:
 *
 * @code
// Must cast to id to avoid compiler warnings.
_model.delegate = (id)[NICellFactory class];
 * @endcode
 *
 * If you would like to customize the factory's output, implement the model's delegate method
 * and call the factory method. Remember that if the factory doesn't know how to map
 * the object to a cell it will return nil.
 *
 * @code
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  UITableViewCell* cell = [NICellFactory tableViewModel: tableViewModel
                                       cellForTableView: tableView
                                            atIndexPath: indexPath
                                             withObject: object];
  if (nil == cell) {
    // Custom cell creation here.
  }
  return cell;
}
 * @endcode
 */
+ (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object;

/**
 * Map an object's class to a cell's class.
 *
 * If an object implements the NICell protocol AND is found in this factory
 * mapping, the factory mapping will take precedence. This allows you to
 * explicitly override the mapping on a case-by-case basis.
 */
- (void)mapObjectClass:(Class)objectClass toCellClass:(Class)cellClass;

/**
 * Returns the height for a row at a given index path.
 *
 * Uses the heightForObject:atIndexPath:tableView: selector from the NICell protocol to ask the
 * object at indexPath in the model what its height should be. If a class mapping has been made for
 * the given object in this factory then that class mapping will be used over the result of
 * cellClass from the NICellObject protocol.
 *
 * If the cell returns a height of zero then tableView.rowHeight will be used.
 *
 * Example implementation:
 *
@code
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.cellFactory tableView:tableView heightForRowAtIndexPath:indexPath model:self.model];
}
@endcode
 *
 *      @param tableView The table view within which the cell exists.
 *      @param indexPath The location of the cell in the table view.
 *      @param model The backing model being used by the table view.
 *      @returns The height of the cell mapped to the object at indexPath, if it implements
 *               heightForObject:atIndexPath:tableView:; otherwise, returns tableView.rowHeight.
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath model:(NITableViewModel *)model;

/**
 * Returns the height for a row at a given index path.
 *
 * Uses the heightForObject:atIndexPath:tableView: selector from the NICell protocol to ask the
 * object at indexPath in the model what its height should be. Only implicit mappings will be
 * checked with this static implementation. If you would like to provide explicit mappings you must
 * create an instance of NICellFactory.
 *
 * If the cell returns a height of zero then tableView.rowHeight will be used.
 *
 * Example implementation:
 *
@code
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [NICellFactory tableView:tableView heightForRowAtIndexPath:indexPath model:self.model];
}
@endcode
 *
 *      @param tableView The table view within which the cell exists.
 *      @param indexPath The location of the cell in the table view.
 *      @param model The backing model being used by the table view.
 *      @returns The height of the cell mapped to the object at indexPath, if it implements
 *               heightForObject:atIndexPath:tableView:; otherwise, returns tableView.rowHeight.
 */
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath model:(NITableViewModel *)model;

@end

@interface NICellFactory (KeyClassMapping)

/**
 * Returns a mapped object from the given key class.
 *
 * If the key class is a subclass of any mapped key classes, the nearest ancestor class's mapped
 * object will be returned and keyClass will be added to the map for future accesses.
 *
 *      @param keyClass The key class that will be used to find the mapping in map.
 *      @param map A map of key classes to classes. May be modified if keyClass is a subclass of
 *                 any existing key classes.
 *      @returns The mapped object if a match for keyClass was found in map. nil is returned
 *               otherwise.
 */
+ (id)objectFromKeyClass:(Class)keyClass map:(NSMutableDictionary *)map;

@end

/**
 * The protocol for an object that can be used in the NICellFactory.
 *
 *      @ingroup TableCellFactory
 */
@protocol NICellObject <NSObject>
@required
/** The class of cell to be created when this object is passed to the cell factory. */
- (Class)cellClass;

@optional
/** The style of UITableViewCell to be used when initializing the cell for the first time. */
- (UITableViewCellStyle)cellStyle;
@end

/**
 * The protocol for a cell created in the NICellFactory.
 *
 * Cells that implement this protocol are given the object that implemented the NICellObject
 * protocol and returned this cell's class name in @link NICellObject::cellClass cellClass@endlink.
 *
 *      @ingroup TableCellFactory
 */
@protocol NICell <NSObject>
@required
/**
 * Called when a cell is created and reused.
 *
 * Implement this method to customize the cell's properties for display using the given object.
 */
- (BOOL)shouldUpdateCellWithObject:(id)object;

@optional

/**
 * Asks the receiver to calculate its height.
 *
 * The following is an appropiate implementation in your tableView's delegate:
 *
@code
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat height = tableView.rowHeight;
  id object = [(NITableViewModel *)tableView.dataSource objectAtIndexPath:indexPath];
  id class = [object cellClass];
  if ([class respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
    height = [class heightForObject:object atIndexPath:indexPath tableView:tableView];
  }
  return height;
}
@endcode
 *
 * You may also use the
 * @link NICellFactory::tableView:heightForRowAtIndexPath:model: tableView:heightForRowAtIndexPath:model:@endlink
 * methods on NICellFactory to achieve the same result. Using the above example allows you to
 * customize the logic according to your specific needs.
 */
+ (CGFloat)heightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

/**
 * A light-weight implementation of the NICellObject protocol.
 *
 * Use this object in cases where you can't set up a hard binding between an object and a cell,
 * or when you simply don't want to.
 *
 * For example, let's say that you want to show a cell that shows a loading indicator.
 * Rather than create a new interface, LoadMoreObject, simply for the cell and binding it
 * to the cell view, you can create an NICellObject and pass the class name of the cell.
 *
@code
[tableContents addObject:[NICellObject objectWithCellClass:[LoadMoreCell class]]];
@endcode
 */
@interface NICellObject : NSObject <NICellObject>

// Designated initializer.
- (id)initWithCellClass:(Class)cellClass userInfo:(id)userInfo;
- (id)initWithCellClass:(Class)cellClass;

+ (id)objectWithCellClass:(Class)cellClass userInfo:(id)userInfo;
+ (id)objectWithCellClass:(Class)cellClass;

@property (nonatomic, readonly, NI_STRONG) id userInfo;

@end

/**
 * An object that can be used to populate information in the cell.
 *
 *      @fn NICellObject::userInfo
 */
