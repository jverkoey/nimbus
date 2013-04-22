//
// Copyright 2013 Jeff Verkoeyen
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

#import "NICollectionViewModel.h"

/**
 * The NIMutableCollectionViewModel class is a mutable collection view model.
 *
 * When modifications are made to the model there are two ways to reflect the changes in the
 * collection view.
 *
 * - Call reloadData on the collection view. This is the most destructive way to update the
 *   collection view.
 * - Call insert/delete/reload methods on the collection view with the retuned index path arrays.
 *
 * The latter option is the recommended approach to adding new cells to a collection view. Each
 * method in the mutable collection view model returns a data structure that can be used to inform
 * the collection view of the exact modifications that have been made to the model.
 *
 * Example of adding a new section:
 @code
 // Appends a new section to the end of the model.
 NSIndexSet* indexSet = [self.model addSectionWithTitle:@"New section"];

 // Appends a cell to the last section in the model (in this case, the new section we just created).
 [self.model addObject:[TestTextCollectionViewCellObject objectWithTitle:@"A cell"]];

 // Inform the collection view that we've modified the model.
 [self.collectionView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
 @endcode
 *
 *      @ingroup TableViewModels
 */
@interface NIMutableCollectionViewModel : NICollectionViewModel

- (NSArray *)addObject:(id)object;
- (NSArray *)addObject:(id)object toSection:(NSUInteger)section;
- (NSArray *)addObjectsFromArray:(NSArray *)array;
- (NSArray *)insertObject:(id)object atRow:(NSUInteger)row inSection:(NSUInteger)section;
- (NSArray *)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexSet *)addSectionWithTitle:(NSString *)title;
- (NSIndexSet *)insertSectionWithTitle:(NSString *)title atIndex:(NSUInteger)index;
- (NSIndexSet *)removeSectionAtIndex:(NSUInteger)index;

@end

/** @name Modifying Objects */

/**
 * Appends an object to the last section.
 *
 * If no sections exist, a section will be created without a title and the object will be added to
 * this new section.
 *
 *      @param object The object to append to the last section.
 *      @returns An array with a single NSIndexPath representing the index path of the new object
 *               in the model.
 *      @fn NIMutableCollectionViewModel::addObject:
 */

/**
 * Appends an object to the end of the given section.
 *
 *      @param object The object to append to the section.
 *      @param section The index of the section to which this object should be appended.
 *      @returns An array with a single NSIndexPath representing the index path of the new object
 *               in the model.
 *      @fn NIMutableCollectionViewModel::addObject:toSection:
 */

/**
 * Appends an array of objects to the last section.
 *
 * If no section exists, a section will be created without a title and the objects will be added to
 * this new section.
 *
 *      @param array The array of objects to append to the last section.
 *      @returns An array of NSIndexPath objects representing the index paths of the objects in the
 *               model.
 *      @fn NIMutableCollectionViewModel::addObjectsFromArray:
 */

/**
 * Inserts an object into the given section at the given row.
 *
 *      @param object The object to append to the section.
 *      @param row The row within the section at which to insert the object.
 *      @param section The index of the section in which the object should be inserted.
 *      @returns An array with a single NSIndexPath representing the index path of the new object
 *               in the model.
 *      @fn NIMutableCollectionViewModel::insertObject:atRow:inSection:
 */

/**
 * Removes an object at the given index path.
 *
 * If the index path does not represent a valid object then a debug assertion will fire and the
 * method will return nil without removing any object.
 *
 *      @param indexPath The index path at which to remove a single object.
 *      @returns An array with a single NSIndexPath representing the index path of the object that
 *               was removed from the model, or nil if no object exists at the given index path.
 *      @fn NIMutableCollectionViewModel::removeObjectAtIndexPath:
 */

/** @name Modifying Sections */

/**
 * Appends a section with a given title to the model.
 *
 *      @param title The title of the new section.
 *      @returns An index set with a single index representing the index of the new section.
 *      @fn NIMutableCollectionViewModel::addSectionWithTitle:
 */

/**
 * Inserts a section with a given title to the model at the given index.
 *
 *      @param title The title of the new section.
 *      @param index The index in the model at which to add the new section.
 *      @returns An index set with a single index representing the index of the new section.
 *      @fn NIMutableCollectionViewModel::insertSectionWithTitle:atIndex:
 */

/**
 * Removes a section at the given index.
 *
 *      @param index The index in the model of the section to remove.
 *      @returns An index set with a single index representing the index of the removed section.
 *      @fn NIMutableCollectionViewModel::removeSectionAtIndex:
 */

/** @name Updating the Section Index */

/**
 * Updates the section index with the current section index settings.
 *
 * This method should be called after modifying the model if a section index is being used.
 *
 *      @fn NIMutableCollectionViewModel::updateSectionIndex
 */
