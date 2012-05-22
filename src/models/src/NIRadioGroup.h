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
#import <UIKit/UIKit.h>

@protocol NIRadioGroupDelegate;

/**
 * A general-purpose radio group.
 *
 * This group object manages radio-style selection of objects. Only one object may be selected at
 * a time.
 *
 * Due to the general-purpose nature of this object, it can be used with UITableViews or any other
 * view that has sets of objects being displayed. This object can insert itself into a
 * UITableViewDelegate call chain to minimize the amount of code that needs to be written in your
 * controller.
 *
 *      @ingroup ModelTools
 */
@interface NIRadioGroup : NSObject <UITableViewDelegate>

@property (nonatomic, readwrite, assign) id<NIRadioGroupDelegate> delegate;

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

/**
 * The delegate for NIRadioGroup.
 *
 *      @ingroup ModelTools
 */
@protocol NIRadioGroupDelegate
@required
/**
 * Called when the user changes the radio group selection.
 *
 *      @param radioGroup The radio group object.
 *      @param identifier The newly selected identifier.
 */
- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier;
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

/** @name Forwarding */

/**
 * The cell selection style that will be applied to the cell when it is displayed using
 * delegate forwarding.
 *
 * By default this is UITableViewCellSelectionStyleBlue.
 *
 *      @fn NIRadioGroup::tableViewCellSelectionStyle
 */

/**
 * Sets the delegate that table view methods should be forwarded to.
 *
 * This method allows you to insert the radio group into the call chain for the table view's
 * delegate methods.
 *
 * Example:
 *
@code
// Let the radio group handle delegate methods and then forward them to whatever delegate was
// already assigned.
self.tableView.delegate = [self.radioGroup forwardingTo:self.tableView.delegate];
@endcode
 *
 *      @param forwardDelegate The delegate to forward invocations to.
 *      @returns self so that this method can be chained.
 *      @fn NIRadioGroup::forwardingTo:
 */
