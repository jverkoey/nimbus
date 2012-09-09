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

#import "NITableViewModel.h"

/**
 * The NIMutableTableViewModel class is a mutable table view model.
 *
 * TODO: Comment about how modifying the model requires informing the table view of changes
 * accordingly or simply calling reloadData.
 */
@interface NIMutableTableViewModel : NITableViewModel

- (NSArray *)addObject:(id)object;
- (NSArray *)addObjectsFromArray:(NSArray *)array;
- (NSArray *)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexSet *)addSectionWithTitle:(NSString *)title;

@end

/**
 * Appends an object to the last section in the model.
 *
 * If no section exists, a section will be created without a title and the object will be added to
 * this new section.
 *
 *      @param object The object to append to the last section in the model.
 *      @returns An array with a single NSIndexPath representing the index path of the object in the
 *               model.
 *      @fn NIMutableTableViewModel::addObject:
 */

/**
 * Appends an array of objects to the last section in the model.
 *
 * If no section exists, a section will be created without a title and the objects will be added to
 * this new section.
 *
 *      @param array The array of objects to append to the last section in the model.
 *      @returns An array of NSIndexPath objects representing the index paths of the objects in the
 *               model.
 *      @fn NIMutableTableViewModel::addObjectsFromArray:
 */

/**
 * Removes an object from the model at the given index path.
 *
 * If the index path does not represent a valid object then a debug assertion will fire and the
 * method will return nil without removing any object.
 *
 *      @param indexPath The index path at which to remove a single object.
 *      @returns An array with a single NSIndexPath representing the index path of the object that
 *               was removed from the model, or nil if no object exists at the given index path.
 *      @fn NIMutableTableViewModel::removeObjectAtIndexPath:
 */

/**
 * Appends a section with a given title to the model.
 *
 *      @param title The title of the new section.
 *      @returns An index set with a single index representing the index of the new section.
 *      @fn NIMutableTableViewModel::addSectionWithTitle:
 */
