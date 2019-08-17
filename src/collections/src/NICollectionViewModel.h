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

#import "NIActions.h"  /* for NIActionsDataSource */
#import "NIPreprocessorMacros.h" /* for weak */

@protocol NICollectionViewModelDelegate;


#pragma mark Sectioned Array Objects

// Classes used when creating NICollectionViewModels.
@class NICollectionViewModelFooter;  // Provides the information for a footer.

/**
 * A protocol that declares the interface for a non-mutable collection view model.
 *
 * A default implementation of this protocol is provided with the NICollectionViewModel class.
 * If you want to customize the implementation of your collection view model while keeping the base
 * interface the same, conform to this protocol and implement the declared methods at minimum.
 *
 * The model class that conforms to this protocol is intended to allow you to easily create a data
 * source for a UICollectionView without having to implement the UICollectionViewDataSource methods
 * in your controller.
 *
 * @ingroup CollectionViewModels
 */
@protocol NICollectionViewModeling <NIActionsDataSource, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching>

#pragma mark Accessing Objects

- (nullable NSIndexPath *)indexPathForObject:(nonnull id)object;

#pragma mark Creating Collection View Cells

@property (nonatomic, weak, nullable) id<NICollectionViewModelDelegate> delegate;

@end

/**
 * A non-mutable collection view model object that provides a lightweight implementation of
 * the NICollectionViewModeling protocol.
 *
 * This base class is non-mutable, much like an NSArray. You must initialize this model with
 * the contents when you create it.
 *
 * This model simply manages the data relationship with your collection view. It is up to you to
 * implement the collection view's layout object.
 *
 * @ingroup CollectionViewModels
 */
@interface NICollectionViewModel : NSObject <NICollectionViewModeling>

- (nonnull id)initWithDelegate:(nullable id<NICollectionViewModelDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (nonnull id)initWithListArray:(nonnull NSArray *)listArray delegate:(nullable id<NICollectionViewModelDelegate>)delegate;

// Each NSString in the array starts a new section. Any other object is a new row (with exception of certain model-specific objects).
- (nonnull id)initWithSectionedArray:(nonnull NSArray *)sectionedArray delegate:(nullable id<NICollectionViewModelDelegate>)delegate;

// Redeclaring for property autosynthesis.
@property (nonatomic, weak, nullable) id<NICollectionViewModelDelegate> delegate;

@end

/**
 * A protocol for NICollectionViewModel to fetch rows to be displayed for the collection view.
 *
 * @ingroup CollectionViewModels
 */
@protocol NICollectionViewModelDelegate <NSObject>
@required

/**
 * Fetches a collection view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
- (nonnull UICollectionViewCell *)collectionViewModel:(nonnull id<NICollectionViewModeling>)collectionViewModel
                                cellForCollectionView:(nonnull UICollectionView *)collectionView
                                          atIndexPath:(nonnull NSIndexPath *)indexPath
                                           withObject:(nonnull id)object;

@optional

/**
 * Fetches a supplementary collection view element at a given indexPath.
 *
 * The value of the kind property and indexPath are implementation-dependent
 * based on the type of UICollectionViewLayout being used.
 */
- (nonnull UICollectionReusableView *)collectionViewModel:(nonnull id<NICollectionViewModeling>)collectionViewModel
                                           collectionView:(nonnull UICollectionView *)collectionView
                        viewForSupplementaryElementOfKind:(nonnull NSString *)kind
                                              atIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 * Prefetch one or more collection view cells at given index paths with given objects.
 */
- (void)collectionViewModel:(nonnull id<NICollectionViewModeling>)collectionViewModel
               collectionView:(nonnull UICollectionView *)collectionView
    prefetchItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths
                  withObjects:(nonnull NSArray<id> *)objects NS_AVAILABLE_IOS(10_0);

/**
 * Cancel the running prefetching task for one or more collection view cells at given index paths with given objects.
 */
- (void)collectionViewModel:(nonnull id<NICollectionViewModeling>)collectionViewModel
                        collectionView:(nonnull UICollectionView *)collectionView
    cancelPrefetchingItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)indexPaths
                           withObjects:(nonnull NSArray<id> *)objects NS_AVAILABLE_IOS(10_0);

@end

/**
 * An object used in sectioned arrays to denote a section footer title.
 *
 * Meant to be used in a sectioned array for NICollectionViewModel.
 *
 * <h3>Example</h3>
 *
 * @code
 *  [NICollectionViewModelFooter footerWithTitle:@"Footer"]
 * @endcode
 */
@interface NICollectionViewModelFooter : NSObject

+ (nonnull id)footerWithTitle:(nonnull NSString *)title;
- (nonnull id)initWithTitle:(nonnull NSString *)title;

@property (nonatomic, copy, nonnull) NSString* title;

@end

/** @name Creating Collection View Models */

/**
 * Initializes a newly allocated static model with the given delegate and empty contents.
 *
 * This method can be used to create an empty model.
 *
 * @fn NICollectionViewModel::initWithDelegate:
 */

/**
 * Initializes a newly allocated static model with the contents of a list array.
 *
 * A list array is a one-dimensional array that defines a flat list of rows. There will be
 * no sectioning of contents in any way.
 *
 * <h3>Example</h3>
 *
 * @code
 * NSArray* contents =
 * [NSArray arrayWithObjects:
 *  [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
 *  nil];
 * [[NICollectionViewModel alloc] initWithListArray:contents delegate:self];
 * @endcode
 *
 * @fn NICollectionViewModel::initWithListArray:delegate:
 */

/**
 * Initializes a newly allocated static model with the contents of a sectioned array.
 *
 * A sectioned array is a one-dimensional array that defines a list of sections and each
 * section's contents. Each NSString begins a new section and any other object defines a
 * row for the current section.
 *
 * <h3>Example</h3>
 *
 * @code
 * NSArray* contents =
 * [NSArray arrayWithObjects:
 *  @"Section 1",
 *  [NSDictionary dictionaryWithObject:@"Row 1" forKey:@"title"],
 *  [NSDictionary dictionaryWithObject:@"Row 2" forKey:@"title"],
 *  @"Section 2",
 *  // This section is empty.
 *  @"Section 3",
 *  [NSDictionary dictionaryWithObject:@"Row 3" forKey:@"title"],
 *  [NICollectionViewModelFooter footerWithTitle:@"Footer"],
 *  nil];
 * [[NICollectionViewModel alloc] initWithSectionedArray:contents delegate:self];
 * @endcode
 *
 * @fn NICollectionViewModel::initWithSectionedArray:delegate:
 */


/** @name Accessing Objects */

/**
 * Returns the object at the given index path.
 *
 * If no object exists at the given index path (an invalid index path, for example) then nil
 * will be returned.
 *
 * @fn NICollectionViewModel::objectAtIndexPath:
 */

/**
 * Returns the index path of the given object within the model.
 *
 * If the model does not contain the object then nil will be returned.
 *
 * @fn NICollectionViewModel::indexPathForObject:
 */


/** @name Creating Collection View Cells */

/**
 * A delegate used to fetch collection view cells for the data source.
 *
 * @fn NICollectionViewModel::delegate
 */
