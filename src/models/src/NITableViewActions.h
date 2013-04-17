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

#import "NimbusCore.h"

/**
 * The NITableViewActions class provides an interface for attaching actions to objects in a
 * NITableViewModel.
 *
 * The three primary types of table view actions are supported for tapping
 *
 * - a button,
 * - the details button,
 * - and with the intent of pushing a new controller onto the navigation controller.
 *
 * <h2>Basic Use</h2>
 *
 * NITableViewModel and NITableViewActions cooperate to solve two related tasks: data
 * representation and user actions, respectively. A NITableViewModel is composed of objects and
 * NITableViewActions maintains a mapping of actions to these objects. The object's attached actions
 * are executed when the user interacts with the cell representing an object.
 *
 * <h3>Attaching Actions</h3>
 *
 * Actions may be attached to specific instances of objects or to entire classes of objects. When
 * an action is attached to both a class of object and an instance of that class, only the instance
 * action will be executed.
 *
 * All attachment methods return the object that was provided. This makes it simple to attach
 * actions within an array creation statement.
 *
@code
NSArray *objects = @[
  [NITitleCellObject objectWithTitle:@"Implicit tap handler"],
  [self.actions attachToObject:[NITitleCellObject objectWithTitle:@"Explicit tap handler"]
                      tapBlock:
   ^BOOL(id object, id target) {
     NSLog(@"Object was tapped with an explicit action: %@", object);
   }]
];

[self.actions attachToClass:[NITitleCellObject class]
                   tapBlock:
 ^BOOL(id object, id target) {
   NSLog(@"Object was tapped: %@", object);
 }];
@endcode
 *
 * This array may then be used to create the NITableViewModel object.
 *
 * Actions come in two forms: blocks and selector invocations. Both can be attached to an object
 * for each type of action and both will be executed, with the block being executed first. Blocks
 * should be used for simple executions while selectors should be used when the action is complex.
 *
 * <h3>Delegate Forwarding</h3>
 *
 * NITableViewActions will apply the correct accessoryType and selectionStyle values to the cell
 * when the cell is displayed using a mechanism known as <i>delegate chaining</i>. This effect is
 * achieved by invoking @link NITableViewActions::forwardingTo: forwardingTo:@endlink on the
 * NITableViewActions instance and providing the appropriate object to forward to (generally
 * @c self).
 *
@code
tableView.delegate = [self.actions forwardingTo:self];
@endcode
 *
 * The dataSource property of the table view must be an instance of NITableViewModel.
 *
 *      @ingroup ModelTools
 */
@interface NITableViewActions : NIActions <UITableViewDelegate>

#pragma mark Forwarding

- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate;
- (void)removeForwarding:(id<UITableViewDelegate>)forwardDelegate;

#pragma mark Configurable Properties

@property (nonatomic, assign) UITableViewCellSelectionStyle tableViewCellSelectionStyle;

@end

/** @name Forwarding */

/**
 * Sets the delegate that table view methods should be forwarded to.
 *
 * This method allows you to insert the actions into the call chain for the table view's
 * delegate methods.
 *
 * Example:
 *
@code
// Let the actions handle delegate methods and then forward them to whatever delegate was
// already assigned.
self.tableView.delegate = [self.actions forwardingTo:self.tableView.delegate];
@endcode
 *
 *      @param forwardDelegate The delegate to forward invocations to.
 *      @returns self so that this method can be chained.
 *      @fn NITableViewActions::forwardingTo:
 */

/**
 * Removes the delegate from the forwarding chain.
 *
 * If a forwared delegate is about to be released but this object may live on, you must remove the
 * forwarding in order to avoid invalid access errors at runtime.
 *
 *      @param forwardDelegate The delegate to stop forwarding invocations to.
 *      @fn NITableViewActions::removeForwarding:
 */

/** @name Configurable Properties */

/**
 * The cell selection style that will be applied to the cell when it is displayed using
 * delegate forwarding.
 *
 * By default this is UITableViewCellSelectionStyleBlue.
 *
 *      @fn NITableViewActions::tableViewCellSelectionStyle
 */
