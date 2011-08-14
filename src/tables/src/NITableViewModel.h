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

#if NS_BLOCKS_AVAILABLE
typedef UITableViewCell* (^NITableViewModelCellForIndexPathBlock)(UITableView* tableView, NSIndexPath* indexPath, id object);
#endif // #if NS_BLOCKS_AVAILABLE

@protocol NITableViewModelDelegate;

/**
 * A non-mutable table view model that complies to the UITableViewDataSource protocol.
 */
@interface NITableViewModel : NSObject <UITableViewDataSource> {
@private
  // Compiled Information
  NSInteger _numberOfSections;
  NSArray* _sectionTitles;  // Array of NSStrings
  NSArray* _sectionsOfRows; // Array of NSArrays

  // Creating Table View Cells
  id<NITableViewModelDelegate> _delegate;
  
#if NS_BLOCKS_AVAILABLE
  NITableViewModelCellForIndexPathBlock _createCellBlock;
#endif // #if NS_BLOCKS_AVAILABLE
}

#pragma mark Creating Table View Models

// Designated initializer.
- (id)initWithDelegate:(id<NITableViewModelDelegate>)delegate;
- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NITableViewModelDelegate>)delegate;

#pragma mark Accessing Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Creating Table View Cells

@property (nonatomic, readwrite, assign) id<NITableViewModelDelegate> delegate;

#if NS_BLOCKS_AVAILABLE
// If both the delegate and this block are provided, cells returned by this block will be used.
@property (nonatomic, readwrite, copy) NITableViewModelCellForIndexPathBlock createCellBlock;
#endif // #if NS_BLOCKS_AVAILABLE

@end

/**
 * A protocol for NITableViewModel to fetch information from the controller.
 */
@protocol NITableViewModelDelegate <NSObject>

@required

/**
 * Fetches a table view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object;

@end

/** @name Creating Table View Models */

/**
 * Designated initializer.
 *
 *      @fn NITableViewModel::init
 */

/**
 * Initializes a newly allocated static model with the contents of a sectioned array.
 *
 * A sectioned array contains objects that are either NSStrings or non-NSStrings.
 * Each NSString denotes a new section. Each non-NSString object denotes a new row.
 *
 * <h3>Example</h3>
 *
 * @code
 * [[NIStaticTableViewModel alloc] initWithSectionedArray:
 *  [NSArray arrayWithObjects:
 *   @"Section 1",
 *   [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
 *   [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
 *   @"Section 2",
 *   @"Section 3",
 *   [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
 *   nil]];
 * @endcode
 *
 *      @fn NITableViewModel::initWithSectionedArray:
 */


/** @name Accessing Objects */

/**
 * Returns the object at the given index path.
 *
 *      @fn NITableViewModel::objectAtIndexPath:
 */


/** @name Creating Table View Cells */

/**
 * A delegate used to fetch table view cells for the data source.
 *
 *      @fn NITableViewModel::delegate
 */

#if NS_BLOCKS_AVAILABLE

/**
 * A block used to create a UITableViewCell for a given object.
 *
 *      @fn NITableViewModel::createCellBlock
 */

#endif // #if NS_BLOCKS_AVAILABLE
