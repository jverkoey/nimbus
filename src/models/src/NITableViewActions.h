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

#import "NimbusCore.h" // For 

typedef BOOL (^NITableViewActionBlock)(id object, id target);

#if defined __cplusplus
extern "C" {
#endif

/**
 * Returns a block that pushes an instance of the controllerClass onto the navigation stack.
 *
 * Allocates an instance of the controller class and calls the init selector.
 *
 *      @param controllerClass The class of controller to instantiate.
 */
NITableViewActionBlock NIPushControllerAction(Class controllerClass);

#if defined __cplusplus
};
#endif

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
  [self.actions attachBlockToObject:[NITitleCellObject objectWithTitle:@"Explicit tap handler"]
                                tap:
   ^BOOL(id object, id target) {
     NSLog(@"Object was tapped with an explicit action: %@", object);
   }]
];

[self.actions attachBlockToClass:[NITitleCellObject class]
                             tap:
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
@interface NITableViewActions : NSObject <UITableViewDelegate>

// Designated initializer.
- (id)initWithTarget:(id)target;

// Deprecated designated initializer. Use initWithTarget: instead.
- (id)initWithController:(UIViewController *)controller __NI_DEPRECATED_METHOD;

#pragma mark Mapping Objects

- (id)attachTapAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object __NI_DEPRECATED_METHOD;
- (id)attachDetailAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object __NI_DEPRECATED_METHOD;
- (id)attachNavigationAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object __NI_DEPRECATED_METHOD;

- (id)attachBlockToObject:(id<NSObject>)object tap:(NITableViewActionBlock)action;
- (id)attachBlockToObject:(id<NSObject>)object detail:(NITableViewActionBlock)action;
- (id)attachBlockToObject:(id<NSObject>)object navigation:(NITableViewActionBlock)action;

- (id)attachSelectorToObject:(id<NSObject>)object tap:(SEL)selector;
- (id)attachSelectorToObject:(id<NSObject>)object detail:(SEL)selector;
- (id)attachSelectorToObject:(id<NSObject>)object navigation:(SEL)selector;

#pragma mark Mapping Classes

- (void)attachTapAction:(NITableViewActionBlock)action toClass:(Class)aClass __NI_DEPRECATED_METHOD;
- (void)attachDetailAction:(NITableViewActionBlock)action toClass:(Class)aClass __NI_DEPRECATED_METHOD;
- (void)attachNavigationAction:(NITableViewActionBlock)action toClass:(Class)aClass __NI_DEPRECATED_METHOD;

- (void)attachBlockToClass:(Class)aClass tap:(NITableViewActionBlock)action;
- (void)attachBlockToClass:(Class)aClass detail:(NITableViewActionBlock)action;
- (void)attachBlockToClass:(Class)aClass navigation:(NITableViewActionBlock)action;

- (void)attachSelectorToClass:(Class)aClass tap:(SEL)selector;
- (void)attachSelectorToClass:(Class)aClass detail:(SEL)selector;
- (void)attachSelectorToClass:(Class)aClass navigation:(SEL)selector;

#pragma mark Object State

- (BOOL)isObjectActionable:(id<NSObject>)object;

#pragma mark Forwarding

- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate;
- (void)removeForwarding:(id<UITableViewDelegate>)forwardDelegate;

#pragma mark Configurable Properties

@property (nonatomic, assign) UITableViewCellSelectionStyle tableViewCellSelectionStyle;

@end

/** @name Creating Table View Actions */

/**
 * Initializes a newly allocated table view actions object with the given controller.
 *
 * @attention This method is deprecated. Use the new method
 *            @link NITableViewActions::initWithTarget: initWithTarget:@endlink.
 *
 * The controller is stored as a weak reference internally.
 *
 *      @param controller The controller that will be used in action blocks.
 *      @fn NITableViewActions::initWithController:
 */

/**
 * Initializes a newly allocated table view actions object with the given target.
 *
 * This is the designated initializer.
 *
 * The target is stored as a weak reference internally.
 *
 *      @param target The target that will be provided to action blocks and on which selectors will
 *                    be performed.
 *      @fn NITableViewActions::initWithTarget:
 */

/** @name Mapping Objects */

/**
 * Attaches a tap action to the given object.
 *
 * A cell with an attached tap action will have its selectionStyle set to
 * @c tableViewCellSelectionStyle when the cell is displayed.
 *
 * The action will be executed when the object's corresponding cell is tapped. The object argument
 * of the block will be the object to which this action was attached. The target argument of the
 * block will be this receiver's @c target.
 *
 * Return NO if the tap action is used to present a modal view controller. This provides a visual
 * reminder to the user when the modal controller is dismissed as to which cell was tapped to invoke
 * the modal controller.
 *
 * The tap action will be invoked first, followed by the navigation action if one is attached.
 *
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @param action The tap action block.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachBlockToObject:tap:
 *      @sa NITableViewActions::attachSelectorToObject:tap:
 */

/**
 * Attaches a detail action to the given object.
 *
 * When a cell with a detail action is displayed, its accessoryType will be set to
 * UITableViewCellAccessoryDetailDisclosureButton.
 *
 * When a cell's detail button is tapped, the detail action block will be executed. The return
 * value of the block is ignored.
 *
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @param action The detail action block.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachBlockToObject:detail:
 */

/**
 * Attaches a navigation action to the given object.
 *
 * When a cell with a navigation action is displayed, its accessoryType will be set to
 * UITableViewCellAccessoryDisclosureIndicator if there is no detail action, otherwise the
 * detail disclosure indicator takes precedence.
 *
 * When a cell with a navigation action is tapped the navigation block will be executed.
 *
 * If a tap action also exists for this object then the tap action will be executed first, followed
 * by the navigation action.
 *
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @param action The navigation action block.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachBlockToObject:navigation:
 */

/**
 * Attaches a tap selector to the given object.
 *
 * The method signature for the selector is:
 @code
 - (BOOL)didTapObject:(id)object;
 @endcode
 *
 * A cell with an attached tap action will have its selectionStyle set to
 * @c tableViewCellSelectionStyle when the cell is displayed.
 *
 * The selector will be performed on the action object's target when a cell with a tap selector is
 * tapped, unless that selector does not exist on the @c target in which case nothing happens.
 *
 * If the selector invocation returns YES then the cell will be deselected immediately after the
 * invocation completes its execution. If NO is returned then the cell's selection will remain.
 *
 * Return NO if the tap action is used to present a modal view controller. This provides a visual
 * reminder to the user when the modal controller is dismissed as to which cell was tapped to invoke
 * the modal controller.
 *
 * The tap action will be invoked first, followed by the navigation action if one is attached.
 *
 *      @param object The object to attach the selector to. This object must be contained within
 *                    an NITableViewModel.
 *      @param selector The selector that will be invoked by this action.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachSelectorToObject:tap:
 *      @sa NITableViewActions::attachBlockToObject:tap:
 */

/**
 * Attaches a detail selector to the given object.
 *
 * The method signature for the selector is:
 @code
 - (void)didTapObject:(id)object;
 @endcode
 *
 * A cell with an attached tap action will have its selectionStyle set to
 * @c tableViewCellSelectionStyle and its accessoryType set to
 * @c UITableViewCellAccessoryDetailDisclosureButton when the cell is displayed.
 *
 * The selector will be performed on the action object's target when a cell with a detail selector's
 * accessory indicator is tapped, unless that selector does not exist on the @c target in which
 * case nothing happens.
 *
 *      @param object The object to attach the selector to. This object must be contained within
 *                    an NITableViewModel.
 *      @param selector The selector that will be invoked by this action.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachSelectorToObject:detail:
 *      @sa NITableViewActions::attachBlockToObject:detail:
 */

/**
 * Attaches a navigation selector to the given object.
 *
 * The method signature for the selector is:
 @code
 - (void)didTapObject:(id)object;
 @endcode
 *
 * A cell with an attached navigation action will have its selectionStyle set to
 * @c tableViewCellSelectionStyle and its accessoryType set to
 * @c UITableViewCellAccessoryDetailDisclosureButton, unless it also has an attached detail action,
 * in which case its accessoryType will be set to @c UITableViewCellAccessoryDisclosureIndicator
 * when the cell is displayed.
 *
 * The selector will be performed on the action object's target when a cell with a navigation
 * selector is tapped, unless that selector does not exist on the @c target in which case nothing
 * happens.
 *
 *      @param object The object to attach the selector to. This object must be contained within
 *                    an NITableViewModel.
 *      @param selector The selector that will be invoked by this action.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachSelectorToObject:navigation:
 *      @sa NITableViewActions::attachBlockToObject:navigation:
 */

/** @name Mapping Classes */

/**
 * Attaches a tap block to a class.
 *
 * This method behaves similarly to attachBlockToObject:tap: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param action The tap action block.
 *      @fn NITableViewActions::attachBlockToClass:tap:
 */

/**
 * Attaches a detail block to a class.
 *
 * This method behaves similarly to attachBlockToObject:detail: except it attaches a detail action
 * to all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param action The detail action block.
 *      @fn NITableViewActions::attachBlockToClass:detail:
 */

/**
 * Attaches a navigation block to a class.
 *
 * This method behaves similarly to attachBlockToObject:navigation: except it attaches a navigation
 * action to all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param action The navigation action block.
 *      @fn NITableViewActions::attachBlockToClass:navigation:
 */

/**
 * Attaches a tap selector to a class.
 *
 * This method behaves similarly to attachBlockToObject:tap: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param selector The tap selector.
 *      @fn NITableViewActions::attachSelectorToClass:tap:
 */

/**
 * Attaches a detail selector to a class.
 *
 * This method behaves similarly to attachBlockToObject:detail: except it attaches a detail action
 * to all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param selector The tap selector.
 *      @fn NITableViewActions::attachSelectorToClass:detail:
 */

/**
 * Attaches a navigation selector to a class.
 *
 * This method behaves similarly to attachBlockToObject:navigation: except it attaches a navigation
 * action to all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param selector The tap selector.
 *      @fn NITableViewActions::attachSelectorToClass:navigation:
 */

/** @name Mapping Objects (Deprecated) */

/**
 * Attaches a tap action to the given object.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToObject:tap: attachBlockToObject:tap:@endlink.
 *
 * When a cell with a tap action is displayed, its selectionStyle will be set to
 * tableViewCellSelectionStyle.
 *
 * When a cell with a tap action is tapped, the action block will be executed. If the action block
 * returns YES then the cell will be deselected immediately after the block completes execution.
 * If NO is returned then the selection will remain.
 *
 * You should return NO if you use the tap action to present a modal view controller. This will
 * ensure that the cell selection remains when the modal controller is dismissed, providing a visual
 * cue to the user as to which cell was tapped.
 *
 * If a navigation action also exists for this object then the tap action will be executed first,
 * followed by the navigation action.
 *
 *      @param action The tap action block.
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachTapAction:toObject:
 */

/**
 * Attaches a detail action to the given object.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToObject:detail: attachBlockToObject:detail:@endlink.
 *
 * When a cell with a detail action is displayed, its accessoryType will be set to
 * UITableViewCellAccessoryDetailDisclosureButton.
 *
 * When a cell's detail button is tapped, the detail action block will be executed. The return
 * value of the block is ignored.
 *
 *      @param action The detail action block.
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachDetailAction:toObject:
 */

/**
 * Attaches a navigation action to the given object.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToObject:navigation: attachBlockToObject:navigation:@endlink.
 *
 * When a cell with a navigation action is displayed, its accessoryType will be set to
 * UITableViewCellAccessoryDisclosureIndicator if there is no detail action, otherwise the
 * detail disclosure indicator takes precedence.
 *
 * When a cell with a navigation action is tapped the navigation block will be executed.
 *
 * If a tap action also exists for this object then the tap action will be executed first, followed
 * by the navigation action.
 *
 *      @param action The navigation action block.
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NITableViewModel.
 *      @returns The object that you attached this action to.
 *      @fn NITableViewActions::attachNavigationAction:toObject:
 */

/** @name Mapping Classes (Deprecated) */

/**
 * Attaches a tap action to a class.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToClass:tap: attachBlockToClass:tap:@endlink.
 *
 * This method behaves similarly to attachBlockToObject:tap: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param action The tap action block.
 *      @param aClass The class to attach the action to.
 *      @fn NITableViewActions::attachTapAction:toClass:
 */

/**
 * Attaches a detail action to a class.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToClass:detail: attachBlockToClass:detail:@endlink.
 *
 * This method behaves similarly to attachBlockToObject:detail: except it attaches a detail action
 * to all instances and subclassed instances of a given class.
 *
 *      @param action The detail action block.
 *      @param aClass The class to attach the action to.
 *      @fn NITableViewActions::attachDetailAction:toClass:
 */

/**
 * Attaches a navigation action to a class.
 *
 * @attention This method is deprecated. Use the new form
 *            @link NITableViewActions::attachBlockToClass:navigation: attachBlockToClass:navigation:@endlink.
 *
 * This method behaves similarly to attachBlockToObject:navigation: except it attaches a navigation
 * action to all instances and subclassed instances of a given class.
 *
 *      @param action The navigation action block.
 *      @param aClass The class to attach the action to.
 *      @fn NITableViewActions::attachNavigationAction:toClass:
 */

/** @name Object State */

/**
 * Returns whether or not the object has any actions attached to it.
 *
 *      @fn NITableViewActions::isObjectActionable:
 */

/** @name Forwarding */

/**
 * The cell selection style that will be applied to the cell when it is displayed using
 * delegate forwarding.
 *
 * By default this is UITableViewCellSelectionStyleBlue.
 *
 *      @fn NITableViewActions::tableViewCellSelectionStyle
 */

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
