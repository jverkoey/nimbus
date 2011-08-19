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
 *
 * This factory is designed to be used with NITableViewModels, though one could easily use
 * it with other table view data source implementations simply by providing nil for the table
 * view model.
 *
 *      @ingroup TableCellFactory
 */
@interface NICellFactory : NSObject

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
@end

/**
 * The protocol for an object that can be used in the NICellFactory.
 *
 *      @ingroup TableCellFactory
 */
@protocol NICellObject
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
@protocol NICell
@required
/**
 * Called when a cell is created and reused.
 *
 * Implement this method to customize the cell's properties for display using the given object.
 */
- (BOOL)shouldUpdateCellWithObject:(id)object;
@end
