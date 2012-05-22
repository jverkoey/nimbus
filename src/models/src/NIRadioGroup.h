//
// Copyright 2012 Jeff Verkoeyen
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

/**
 * A general-purpose radio cell group.
 *
 * This group object manages radio-style selection of objects. Only one object may be selected at
 * a time.
 *
 * Due to the general-purpose nature of this object, it can be used with UITableViews or any other
 * view that has sets of objects being displayed. There are helper methods specifically for
 * UITableViews to reduce code duplication.
 *
 *      @ingroup TableViewForms
 */
@interface NIRadioGroup : NSObject <UITableViewDelegate>

#pragma mark Mapping Objects

- (void)mapObject:(id)object toIdentifier:(NSInteger)identifier;

#pragma mark Selection

- (BOOL)hasSelection;
@property (nonatomic, readwrite, assign) NSInteger selectedIdentifier;
- (void)clearSelection;

#pragma mark Object State

- (BOOL)isObjectInRadioGroup:(id)object;
- (BOOL)isObjectSelected:(id)object;
- (NSInteger)identifierForObject:(id)object;

#pragma mark Forwarding

@property (nonatomic, readwrite, assign) UITableViewCellSelectionStyle tableViewCellSelectionStyle;
- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate;

@end

/** @name Mapping Objects */

/**
 * Maps the given object to the given identifier.
 *
 * The identifier will be used in all subsequent operations and is a means of abstracting away
 * the objects. The identifier range does not have to be sequential. The only reserved value is
 * NSIntegerMin, which is used to signify that no selection exists.
 *
 * You may NOT map the same object to multiple identifiers. Attempts to do so fill fire a debug
 * assertion and will not map the new object in the radio group.
 *
 *      @fn NIRadioGroup::mapObject:toIdentifier:
 */

/** @name Selection */

/**
 * Whether or not a selection has been made.
 *
 *      @fn NIRadioGroup::hasSelection
 */

/**
 * The currently selected identifier if one is selected, otherwise returns NSIntegerMin.
 *
 *      @fn NIRadioGroup::selectedIdentifier
 */

/**
 * Removes the selection from this cell group.
 *
 *      @fn NIRadioGroup::clearSelection
 */

/** @name Object State */

/**
 * Returns YES if the given object is in this radio group.
 *
 *      @fn NIRadioGroup::isObjectInRadioGroup:
 */

/**
 * Returns YES if the given object is selected.
 *
 * This method should only be called after verifying that the object is contained within the radio
 * group with isObjectInRadioGroup:.
 *
 *      @fn NIRadioGroup::isObjectSelected:
 */

/**
 * Returns the mapped identifier for this object.
 *
 * This method should only be called after verifying that the object is contained within the radio
 * group with isObjectInRadioGroup:.
 *
 *      @fn NIRadioGroup::identifierForObject:
 */

/** @name UITableView Helpers */

/**
 * Helper method to be used in UITableViewDelegate's tableView:willDisplayCell:forRowAtIndexPath:
 *
 * Checks whether the given object exists within this radio group and, if it is, updates the
 * cell accessory type accordingly.
 *
 *      @param cell The table view cell that is about to be displayed.
 *      @param object The object that will was mapped to this cell view.
 *      @returns YES if the cell is within this radio group, NO otherwise.
 *      @fn NIRadioGroup::willDisplayCell:forObject:
 */

/**
 * Helper method to be used in UITableViewDelegate's tableView:didSelectRowAtIndexPath::
 *
 * Updates the radio group selection if the selected object is within this radio group.
 *
 *      @param tableView The table view within which this object resides.
 *      @param object The object that was selected.
 *      @param indexPath The index path of the selected object.
 *      @returns YES if the radio group selection changed, NO otherwise.
 *      @fn NIRadioGroup::tableView:didSelectObject:atIndexPath:
 */
