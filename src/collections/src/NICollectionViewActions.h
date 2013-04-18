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

#import "NimbusCore.h"

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
 * <h2>Delegate Forwarding</h2>
 *
 * Your delegate implementation can call the listed collectionView: methods in order for the
 * collection view to respond to user actions. Notably shouldHighlightItemAtIndexPath: allows
 * cells to be highlighted only if the cell's object has an attached action.
 * didSelectItemAtIndexPath: will execute the object's attached tap actions.
 *
 * If you use the delegate forwarders your collection view's data source must be an instance of
 * NICollectionViewModel.
 *
 *      @ingroup CollectionViewTools
 */
@interface NICollectionViewActions : NIActions

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 * Asks the receiver whether the object at the given index path is actionable.
 *
 * collectionView.dataSource must be a NICollectionViewModel.
 *
 *    @returns YES if the object at the given index path is actionable.
 *    @fn NICollectionViewActions::collectionView:shouldHighlightItemAtIndexPath:
 */

/**
 * Asks the receiver to perform the tap action for an object at the given indexPath.
 *
 * collectionView.dataSource must be a NICollectionViewModel.
 *
 *    @fn NICollectionViewActions::collectionView:didSelectItemAtIndexPath:
 */
