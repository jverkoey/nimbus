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

#import "NIPreprocessorMacros.h" /* for NI_WEAK */

@protocol NICollectionViewModelDelegate;


#pragma mark Sectioned Array Objects

// Classes used when creating NICollectionViewModels.
@class NICollectionViewModelFooter;  // Provides the information for a footer.

/**
 * A non-mutable collection view model that complies to the UICollectionViewDataSource protocol.
 *
 * This model allows you to easily create a data source for a UICollectionView without having to
 * implement the UICollectionViewDataSource methods in your controller.
 *
 * This base class is non-mutable, much like an NSArray. You must initialize this model with
 * the contents when you create it.
 *
 * This model simply manages the data relationship with your collection view. It is up to you to
 * implement the collection view's layout object.
 *
 *      @ingroup CollectionViewModels
 */
@interface NICollectionViewModel : NSObject <UICollectionViewDataSource>

#pragma mark Creating Collection View Models

// Designated initializer.
- (id)initWithDelegate:(id<NICollectionViewModelDelegate>)delegate;
- (id)initWithListArray:(NSArray *)listArray delegate:(id<NICollectionViewModelDelegate>)delegate;
// Each NSString in the array starts a new section. Any other object is a new row (with exception of certain model-specific objects).
- (id)initWithSectionedArray:(NSArray *)sectionedArray delegate:(id<NICollectionViewModelDelegate>)delegate;

#pragma mark Accessing Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Creating Collection View Cells

@property (nonatomic, NI_WEAK) id<NICollectionViewModelDelegate> delegate;

@end

/**
 * A protocol for NICollectionViewModel to fetch rows to be displayed for the collection view.
 *
 *      @ingroup CollectionViewModels
 */
@protocol NICollectionViewModelDelegate <NSObject>
@required

/**
 * Fetches a collection view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                        cellForCollectionView:(UICollectionView *)collectionView
                                  atIndexPath:(NSIndexPath *)indexPath
                                   withObject:(id)object;

@optional

/**
 * Fetches a supplementary collection view element at a given indexPath.
 *
 * The value of the kind property and indexPath are implementation-dependent
 * based on the type of UICollectionViewLayout being used.
 */
- (UICollectionReusableView *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                                   collectionView:(UICollectionView *)collectionView
                viewForSupplementaryElementOfKind:(NSString *)kind
                                      atIndexPath:(NSIndexPath *)indexPath;

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

+ (id)footerWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title;

@property (nonatomic, copy) NSString* title;

@end

/** @name Creating Collection View Models */

/**
 * Initializes a newly allocated static model with the given delegate and empty contents.
 *
 * This method can be used to create an empty model.
 *
 *      @fn NICollectionViewModel::initWithDelegate:
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
 *      @fn NICollectionViewModel::initWithListArray:delegate:
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
 *      @fn NICollectionViewModel::initWithSectionedArray:delegate:
 */


/** @name Accessing Objects */

/**
 * Returns the object at the given index path.
 *
 * If no object exists at the given index path (an invalid index path, for example) then nil
 * will be returned.
 *
 *      @fn NICollectionViewModel::objectAtIndexPath:
 */


/** @name Creating Collection View Cells */

/**
 * A delegate used to fetch collection view cells for the data source.
 *
 *      @fn NICollectionViewModel::delegate
 */
