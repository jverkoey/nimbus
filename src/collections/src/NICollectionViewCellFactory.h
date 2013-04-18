//
// Copyright 2011 Jeff Verkoeyen
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

#import "NICollectionViewModel.h"

/**
 * A simple factory for creating collection view cells from objects.
 *
 * This factory provides a single method that accepts an object and returns a UICollectionViewCell
 * for use in a UICollectionView. A cell will only be returned if the object passed to the factory
 * conforms to the NICollectionViewCellObject protocol. The created cell should ideally conform to
 * the NICollectionViewCell protocol. If it does, the object will be passed to it via
 * @link NICollectionViewCell::shouldUpdateCellWithObject: shouldUpdateCellWithObject:@endlink
 * before the factory method returns.
 *
 * This factory is designed to be used with NICollectionViewModel, though one could easily use
 * it with other collection view data source implementations simply by providing nil for the
 * collection view model argument.
 *
 * If you instantiate an NICollectionViewCellFactory then you can provide explicit mappings from
 * objects to cells. This is helpful if the effort required to implement the NICollectionViewCell
 * protocol on an object outweighs the benefit of using the factory, i.e. when you want to map
 * simple types such as NSString to cells.
 *
 *      @ingroup CollectionViewCellFactory
 */
@interface NICollectionViewCellFactory : NSObject <NICollectionViewModelDelegate>

/**
 * Creates a cell from a given object if and only if the object conforms to the
 * NICollectionViewCellObject protocol.
 *
 * This method signature matches the NICollectionViewModelDelegate method so that you can
 * set this factory as the model's delegate:
 *
 * @code
// Must cast to id to avoid compiler warnings.
_model.delegate = (id)[NICollectionViewCellFactory class];
 * @endcode
 *
 * If you would like to customize the factory's output, implement the model's delegate method
 * and call the factory method. Remember that if the factory doesn't know how to map
 * the object to a cell it will return nil.
 *
 * @code
- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                        cellForCollectionView:(UICollectionView *)collectionView
                                  atIndexPath:(NSIndexPath *)indexPath
                                   withObject:(id)object {
  UICollectionViewCell* cell = [NICollectionViewCellFactory collectionViewModel:collectionViewModel
                                                          cellForCollectionView:collectionView
                                                                    atIndexPath:indexPath
                                                                     withObject:object];
  if (nil == cell) {
    // Custom cell creation here.
  }
  return cell;
}
 * @endcode
 */
+ (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel cellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object;

/**
 * Map an object's class to a cell's class.
 *
 * If an object implements the NICollectionViewCell protocol AND is found in this factory
 * mapping, the factory mapping will take precedence. This allows you to
 * explicitly override the mapping on a case-by-case basis.
 */
- (void)mapObjectClass:(Class)objectClass toCellClass:(Class)collectionViewCellClass;

/**
 * Returns the mapped cell class for an object at a given index path.
 *
 * Explicitly mapped classes in the receiver take precedence over implicitly mapped classes.
 *
 * This method is helpful when implementing layout calculation methods for your collection view. You
 * can fetch the cell class and then perform any selectors that are necessary for calculating the
 * dimensions of the cell before it is instantiated.
 */
- (Class)collectionViewCellClassForItemAtIndexPath:(NSIndexPath *)indexPath model:(NICollectionViewModel *)model;

/**
 * Returns the mapped cell class for an object at a given index path.
 *
 * This method is helpful when implementing layout calculation methods for your collection view. You
 * can fetch the cell class and then perform any selectors that are necessary for calculating the
 * dimensions of the cell before it is instantiated.
 */
+ (Class)collectionViewCellClassForItemAtIndexPath:(NSIndexPath *)indexPath model:(NICollectionViewModel *)model;

@end

/**
 * The protocol for an object that can be used in the NICollectionViewCellFactory.
 *
 *      @ingroup CollectionViewCellFactory
 */
@protocol NICollectionViewCellObject <NSObject>
@required

/** The class of cell to be created when this object is passed to the cell factory. */
- (Class)collectionViewCellClass;

@end

/**
 * The protocol for a cell created in the NICollectionViewCellFactory.
 *
 * Cells that implement this protocol are given the object that implemented the
 * NICollectionViewCellObject protocol and returned this cell's class name in
 * @link NICollectionViewCellObject::collectionViewCellClass collectionViewCellClass@endlink.
 *
 *      @ingroup CollectionViewCellFactory
 */
@protocol NICollectionViewCell <NSObject>
@required

/**
 * Called both when a cell is created and when it is reused.
 *
 * Implement this method to customize the cell's properties for display using the given object.
 */
- (BOOL)shouldUpdateCellWithObject:(id)object;

@optional

/**
 * Asks the receiver whether the mapped object class should be appended to the reuse identifier
 * in order to create a unique cell.object identifier key.
 *
 * This is useful when you have a cell that is intended to be used by a variety of different
 * objects.
 */
+ (BOOL)shouldAppendObjectClassToReuseIdentifier;

@end

/**
 * A light-weight implementation of the NICollectionViewCellObject protocol.
 *
 * Use this object in cases where you can't set up a hard binding between an object and a cell,
 * or when you simply don't want to.
 *
 * For example, let's say that you want to show a cell that shows a loading indicator.
 * Rather than create a new interface, LoadMoreObject, simply for the cell and binding it
 * to the cell view, you can create an NICollectionViewCellObject and pass the class name of the cell.
 *
@code
[contents addObject:[NICollectionViewCellObject objectWithCellClass:[LoadMoreCell class]]];
@endcode
 */
@interface NICollectionViewCellObject : NSObject <NICollectionViewCellObject>

// Designated initializer.
- (id)initWithCellClass:(Class)collectionViewCellClass userInfo:(id)userInfo;
- (id)initWithCellClass:(Class)collectionViewCellClass;

+ (id)objectWithCellClass:(Class)collectionViewCellClass userInfo:(id)userInfo;
+ (id)objectWithCellClass:(Class)collectionViewCellClass;

@property (nonatomic, readonly, NI_STRONG) id userInfo;

@end

/**
 * An object that can be used to populate information in the cell.
 *
 *      @fn NICollectionViewCellObject::userInfo
 */
