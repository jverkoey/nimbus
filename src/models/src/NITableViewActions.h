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

typedef BOOL (^NITableViewActionBlock)(id object, UIViewController* controller);

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
 * An object that can be used to easily implement actions in table view controllers.
 *
 * This object provides support for the three primary types of actions that can be taken on cells
 * in UITableViews:
 *
 * - Tapping a cell.
 * - Tapping the details button.
 * - Navigating from a cell.
 *
 * This object will automatically apply the correct accessoryType and selectionStyle values to the
 * cell when it is displayed. This allows you to write cells without any knowledge of "actions",
 * greatly simplifying the logic that goes into your cells.
 *
 *      @ingroup ModelTools
 */
@interface NITableViewActions : NSObject <UITableViewDelegate>

// Designated initializer.
- (id)initWithController:(UIViewController *)controller;

#pragma mark Mapping Objects 

- (id)attachTapAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object;
- (id)attachDetailAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object;
- (id)attachNavigationAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object;

#pragma mark Mapping Classes

- (void)attachTapAction:(NITableViewActionBlock)action toClass:(Class)aClass;
- (void)attachDetailAction:(NITableViewActionBlock)action toClass:(Class)aClass;
- (void)attachNavigationAction:(NITableViewActionBlock)action toClass:(Class)aClass;

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
 * This is the designated initializer.
 *
 * The given controller is stored as a weak reference internally.
 *
 *      @param controller The controller that will be used in action blocks.
 *      @fn NITableViewActions::initWithController:
 */

/** @name Mapping Objects */

/**
 * Attaches a tap action to the given object.
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

/** @name Mapping Classes */

/**
 * Attaches a tap action to a class.
 *
 * This method behaves similarly to attachTapAction:toObject: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param action The tap action block.
 *      @param object The class to attach the action to.
 *      @fn NITableViewActions::attachTapAction:toClass:
 */

/**
 * Attaches a detail action to a class.
 *
 * This method behaves similarly to attachDetailAction:toObject: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param action The detail action block.
 *      @param class The class to attach the action to.
 *      @fn NITableViewActions::attachDetailAction:toClass:
 */

/**
 * Attaches a navigation action to a class.
 *
 * This method behaves similarly to attachNavigationAction:toObject: except it attaches a tap action
 * to all instances and subclassed instances of a given class.
 *
 *      @param action The navigation action block.
 *      @param class The class to attach the action to.
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
