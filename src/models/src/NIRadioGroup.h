//
// Copyright 2011-2014 NimbusKit
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

#import "NICellFactory.h"

@protocol NIRadioGroupDelegate;
@class NIRadioGroupController;

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
 * If you add a NIRadioGroup object to a NITableViewModel, it will show a cell that displays the
 * current radio group selection. This cell is also tappable. Tapping this cell will push a
 * controller onto the navigation stack that presents the radio group options for the user to
 * select. The radio group delegate is notified immediately when a selection is made and the
 * tapped cell is also updated to reflect the new selection.
 *
 * @ingroup ModelTools
 */
@interface NIRadioGroup : NSObject <NICellObject, UITableViewDelegate>

// Designated initializer.
- (id)initWithController:(UIViewController *)controller;

@property (nonatomic, weak) id<NIRadioGroupDelegate> delegate;

#pragma mark Mapping Objects

- (id)mapObject:(id)object toIdentifier:(NSInteger)identifier;

#pragma mark Selection

- (BOOL)hasSelection;
@property (nonatomic, assign) NSInteger selectedIdentifier;
- (void)clearSelection;

#pragma mark Object State

- (BOOL)isObjectInRadioGroup:(id)object;
- (BOOL)isObjectSelected:(id)object;
- (NSInteger)identifierForObject:(id)object;

#pragma mark Forwarding

@property (nonatomic, assign) UITableViewCellSelectionStyle tableViewCellSelectionStyle;
- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate;
- (void)removeForwarding:(id<UITableViewDelegate>)forwardDelegate;

#pragma mark Sub Radio Groups

@property (nonatomic, copy) NSString* cellTitle;
@property (nonatomic, copy) NSString* controllerTitle;
- (NSArray *)allObjects;

@end

/**
 * The delegate for NIRadioGroup.
 *
 * @ingroup ModelTools
 */
@protocol NIRadioGroupDelegate <NSObject>
@required

/**
 * Called when the user changes the radio group selection.
 *
 * @param radioGroup The radio group object.
 * @param identifier The newly selected identifier.
 */
- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier;

@optional

/**
 * Fetches the text that will be displayed in a radio group cell for the current selection.
 *
 * This is only used when the radio group is added to a table view as a sub radio group.
 */
- (NSString *)radioGroup:(NIRadioGroup *)radioGroup textForIdentifier:(NSInteger)identifier;

/**
 * The radio group controller is about to appear.
 *
 * This method provides a customization point for the radio group view controller.
 *
 * @return YES if controller should be pushed onto the current navigation stack.
 *              NO if you are going to present the controller yourself.
 */
- (BOOL)radioGroup:(NIRadioGroup *)radioGroup radioGroupController:(NIRadioGroupController *)radioGroupController willAppear:(BOOL)animated;

@end

/**
 * The cell that is displayed for a NIRadioGroup object when it is displayed in a UITableView.
 *
 * This class is exposed publicly so that you may subclass it and customize the way it displays
 * its information. You can override the cell class that the radio group uses in two ways:
 *
 * 1. Subclass NIRadioGroup and return a different cell class in -cellClass.
 * 2. Create a NICellFactory and map NIRadioGroup to a different cell class and then use this
 *    factory for your model in your table view controller.
 *
 * By default this cell displays the cellTitle property of the radio group on the left and the
 * text retrieved from the radio group delegate's radioGroup:textForIdentifier: method on the right.
 */
@interface NIRadioGroupCell : UITableViewCell <NICell>
@end

/** @name Creating Radio Groups */

/**
 * Initializes a newly allocated radio group object with the given controller.
 *
 * This is the designated initializer.
 *
 * The given controller is stored as a weak reference internally.
 *
 * @param controller The controller that will be used when this object is used as a sub radio
 *                        group.
 * @fn NIRadioGroup::initWithController:
 */

/** @name Mapping Objects */

/**
 * Maps the given object to the given identifier.
 *
 * The identifier will be used in all subsequent operations and is a means of abstracting away
 * the objects. The identifier range does not have to be sequential. The only reserved value is
 * NSIntegerMin, which is used to signify that no selection exists.
 *
 * You can NOT map the same object to multiple identifiers. Attempts to do so fill fire a debug
 * assertion and will not map the new object in the radio group.
 *
 * @param object The object to map to the identifier.
 * @param identifier The identifier that will represent the object.
 * @returns The object that was mapped.
 * @fn NIRadioGroup::mapObject:toIdentifier:
 */

/** @name Selection */

/**
 * Whether or not a selection has been made.
 *
 * @fn NIRadioGroup::hasSelection
 */

/**
 * The currently selected identifier if one is selected, otherwise returns NSIntegerMin.
 *
 * @fn NIRadioGroup::selectedIdentifier
 */

/**
 * Removes the selection from this cell group.
 *
 * @fn NIRadioGroup::clearSelection
 */

/** @name Object State */

/**
 * Returns YES if the given object is in this radio group.
 *
 * @fn NIRadioGroup::isObjectInRadioGroup:
 */

/**
 * Returns YES if the given object is selected.
 *
 * This method should only be called after verifying that the object is contained within the radio
 * group with isObjectInRadioGroup:.
 *
 * @fn NIRadioGroup::isObjectSelected:
 */

/**
 * Returns the mapped identifier for this object.
 *
 * This method should only be called after verifying that the object is contained within the radio
 * group with isObjectInRadioGroup:.
 *
 * @fn NIRadioGroup::identifierForObject:
 */

/** @name Forwarding */

/**
 * The cell selection style that will be applied to the cell when it is displayed using
 * delegate forwarding.
 *
 * By default this is UITableViewCellSelectionStyleBlue.
 *
 * @fn NIRadioGroup::tableViewCellSelectionStyle
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
 * @param forwardDelegate The delegate to forward invocations to.
 * @returns self so that this method can be chained.
 * @fn NIRadioGroup::forwardingTo:
 */

/**
 * Removes the delegate from the forwarding chain.
 *
 * If a forwared delegate is about to be released but this object may live on, you must remove the
 * forwarding in order to avoid invalid access errors at runtime.
 *
 * @param forwardDelegate The delegate to stop forwarding invocations to.
 * @fn NIRadioGroup::removeForwarding:
 */

/**
 * The title of the cell that is displayed for a radio group in a UITableView.
 *
 * @fn NIRadioGroup::cellTitle
 */

/**
 * The title of the controller that shows the sub radio group selection.
 *
 * @fn NIRadioGroup::controllerTitle
 */

/**
 * An array of mapped objects in this radio group, ordered in the same order they were mapped.
 *
 * This is used primarily by NIRadioGroupController to display the radio group options.
 *
 * @fn NIRadioGroup::allObjects
 */
