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

#import <Foundation/Foundation.h>

typedef BOOL (^NICollectionViewActionBlock)(id object, id target, NSIndexPath* indexPath);

/**
 * The NICollectionViewActions class provides an interface for attaching actions to objects in a
 * NICollectionViewModel.
 *
 * <h2>Basic Use</h2>
 *
 * NICollectionViewModel and NICollectionViewActions cooperate to solve two related tasks: data
 * representation and user actions, respectively. A NICollectionViewModel is composed of objects and
 * NICollectionViewActions maintains a mapping of actions to these objects. The object's attached
 * actions are executed when the user interacts with the cell representing an object.
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
 * Actions come in two forms: blocks and selector invocations. Both can be attached to an object
 * for each type of action and both will be executed, with the block being executed first. Blocks
 * should be used for simple executions while selectors should be used when the action is complex.
 *
 *      @ingroup CollectionViewTools
 */
@interface NICollectionViewActions : NSObject

// Designated initializer.
- (id)initWithTarget:(id)target;

#pragma mark Mapping Objects

- (id)attachToObject:(id<NSObject>)object tapBlock:(NICollectionViewActionBlock)action;
- (id)attachToObject:(id<NSObject>)object tapSelector:(SEL)selector;

#pragma mark Mapping Classes

- (void)attachToClass:(Class)aClass tapBlock:(NICollectionViewActionBlock)action;
- (void)attachToClass:(Class)aClass tapSelector:(SEL)selector;

#pragma mark Object State

- (BOOL)isObjectActionable:(id<NSObject>)object;

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/** @name Creating Collection View Actions */

/**
 * Initializes a newly allocated collection view actions object with the given target.
 *
 * This is the designated initializer.
 *
 * The target is stored as a weak reference internally.
 *
 *      @param target The target that will be provided to action blocks and on which selectors will
 *                    be performed.
 *      @fn NICollectionViewActions::initWithTarget:
 */

/** @name Mapping Objects */

/**
 * Attaches a tap action to the given object.
 *
 * The action will be executed when the object's corresponding cell is tapped. The object argument
 * of the block will be the object to which this action was attached. The target argument of the
 * block will be this receiver's @c target.
 *
 * Return NO if the tap action is used to present a modal view controller. This provides a visual
 * reminder to the user when the modal controller is dismissed as to which cell was tapped to invoke
 * the modal controller.
 *
 *      @param object The object to attach the action to. This object must be contained within
 *                    an NICollectionViewModel.
 *      @param action The tap action block.
 *      @returns The object that you attached this action to.
 *      @fn NICollectionViewActions::attachToObject:tapBlock:
 *      @sa NICollectionViewActions::attachToObject:tapSelector:
 */

/**
 * Attaches a tap selector to the given object.
 *
 * The method signature for the selector is:
@code
- (BOOL)didTapObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
@endcode
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
 *                    an NICollectionViewModel.
 *      @param selector The selector that will be invoked by this action.
 *      @returns The object that you attached this action to.
 *      @fn NICollectionViewActions::attachToObject:tapSelector:
 *      @sa NICollectionViewActions::attachToObject:tapBlock:
 */

/** @name Mapping Classes */

/**
 * Attaches a tap block to a class.
 *
 * This method behaves similarly to attachToObject:tapBlock: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param action The tap action block.
 *      @fn NICollectionViewActions::attachToClass:tapBlock:
 */

/**
 * Attaches a tap selector to a class.
 *
 * This method behaves similarly to attachToObject:tapBlock: except it attaches a tap action to
 * all instances and subclassed instances of a given class.
 *
 *      @param aClass The class to attach the action to.
 *      @param selector The tap selector.
 *      @fn NICollectionViewActions::attachToClass:tapSelector:
 */

/** @name Object State */

/**
 * Returns whether or not the object has any actions attached to it.
 *
 *      @fn NICollectionViewActions::isObjectActionable:
 */
