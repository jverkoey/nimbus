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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NimbusCollections.h"

@interface TestObject : NSObject <NICollectionViewCellObject>
@property (nonatomic, copy) NSString *identifier;
+ (instancetype)testObjectWithIdentifier:(NSString *)identifier;
@end

@interface TestCell : UICollectionViewCell <NICollectionViewCell>
@end

@implementation TestObject

+ (instancetype)testObjectWithIdentifier:(NSString *)identifier {
  TestObject *testObject = [[TestObject alloc] init];
  testObject.identifier = identifier;
  return testObject;
}

#pragma mark - NICollectionViewCellObject

- (Class)collectionViewCellClass {
  return [TestCell class];
}

- (BOOL)isEqual:(id)object {
  if (object == self) {
    return YES;
  }
  if (![object isKindOfClass:[TestObject class]]) {
    return NO;
  }
  TestObject *other = (TestObject *)object;
  if (self.identifier) {
    return [self.identifier isEqual:other.identifier];
  }
  return (other.identifier == nil);
}

- (NSUInteger)hash {
  return self.identifier.hash;
}

@end

@implementation TestCell

#pragma mark - NICollectionViewCell

- (BOOL)shouldUpdateCellWithObject:(TestObject *)object {
  return YES;
}

@end

@interface TestCollectionView : UICollectionView
@property (strong, nonatomic) NSMutableIndexSet *insertedSections;
@property (strong, nonatomic) NSMutableIndexSet *deletedSections;
@property (strong, nonatomic) NSMutableIndexSet *reloadedSections;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSNumber *> *movedSections;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *insertedItems;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *deletedItems;
@property (strong, nonatomic) NSMutableArray<NSIndexPath *> *reloadedItems;
@property (strong, nonatomic) NSMutableDictionary<NSIndexPath *, NSIndexPath *> *movedItems;
@end

@implementation TestCollectionView

+ (TestCollectionView *)collectionView {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  TestCollectionView *collectionView =
      [[TestCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  [collectionView resetUpdateTracking];
  return collectionView;
}

- (void)resetUpdateTracking {
  self.insertedSections = [NSMutableIndexSet indexSet];
  self.deletedSections = [NSMutableIndexSet indexSet];
  self.reloadedSections = [NSMutableIndexSet indexSet];
  self.movedSections = [NSMutableDictionary dictionary];
  self.insertedItems = [NSMutableArray array];
  self.deletedItems = [NSMutableArray array];
  self.reloadedItems = [NSMutableArray array];
  self.movedItems = [NSMutableDictionary dictionary];
}

- (void)insertSections:(NSIndexSet *)sections {
  [self.insertedSections addIndexes:sections];
  [super insertSections:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
  [self.deletedSections addIndexes:sections];
  [super deleteSections:sections];
}

- (void)reloadSections:(NSIndexSet *)sections {
  [self.reloadedSections addIndexes:sections];
  [super reloadSections:sections];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
  self.movedSections[@(section)] = @(newSection);
  [super moveSection:section toSection:newSection];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  [self.insertedItems addObjectsFromArray:indexPaths];
  [super insertItemsAtIndexPaths:indexPaths];
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  [self.deletedItems addObjectsFromArray:indexPaths];
  [super deleteItemsAtIndexPaths:indexPaths];
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
  [self.reloadedItems addObjectsFromArray:indexPaths];
  [super reloadItemsAtIndexPaths:indexPaths];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
  self.movedItems[indexPath] = newIndexPath;
  [super moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

@end

static NIMutableCollectionViewModel *CollectionViewModel() {
  NIMutableCollectionViewModel *model = [[NIMutableCollectionViewModel alloc] initWithDelegate:(id)[NICollectionViewCellFactory class]];
  [model addSectionWithTitle:@"Section One"];
  [model addSectionWithTitle:@"Section Two"];
  [model addSectionWithTitle:@"Section Three"];

  [model addObject:[TestObject testObjectWithIdentifier:@"Section One Item One"] toSection:0];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section One Item Two"] toSection:0];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section One Item Three"] toSection:0];

  [model addObject:[TestObject testObjectWithIdentifier:@"Section Two Item One"] toSection:1];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section Two Item Two"] toSection:1];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section Two Item Three"] toSection:1];

  [model addObject:[TestObject testObjectWithIdentifier:@"Section Three Item One"] toSection:2];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section Three Item Two"] toSection:2];
  [model addObject:[TestObject testObjectWithIdentifier:@"Section Three Item Three"] toSection:2];

  return model;
}

@interface NimbusCollectionsTests : XCTestCase
@end

@implementation NimbusCollectionsTests

- (void)testMutableModelInitializationWithListArray {
  NIMutableCollectionViewModel *model =
      [[NIMutableCollectionViewModel alloc] initWithListArray:@[ [TestObject testObjectWithIdentifier:@"One"] ]
                                                     delegate:nil];
  TestCollectionView *collectionView = [TestCollectionView collectionView];
  XCTAssertEqual([model collectionView:collectionView numberOfItemsInSection:0], 1);
  [model addObject:[TestObject testObjectWithIdentifier:@"Two"]];
  XCTAssertEqual([model collectionView:collectionView numberOfItemsInSection:0], 2);
}


- (void)testCopy {
  NIMutableCollectionViewModel *model1 = CollectionViewModel();
  NIMutableCollectionViewModel *model2 = [model1 copy];
  XCTAssertEqualObjects(model1, model2);
  XCTAssertEqualObjects(model2, model1);
}

- (void)testObjectAtIndexPath {
  NIMutableCollectionViewModel *model = CollectionViewModel();

  NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:0];
  TestObject *object = [model objectAtIndexPath:path];
  XCTAssertEqualObjects(object.identifier, @"Section One Item One");

  path = [NSIndexPath indexPathForItem:1 inSection:1];
  object = [model objectAtIndexPath:path];
  XCTAssertEqualObjects(object.identifier, @"Section Two Item Two");

  path = [NSIndexPath indexPathForItem:2 inSection:2];
  object = [model objectAtIndexPath:path];
  XCTAssertEqualObjects(object.identifier, @"Section Three Item Three");
}

- (void)testEnumerateItemsUsingBlock {
  NIMutableCollectionViewModel *model = CollectionViewModel();
  __block NSUInteger itemCount = 0;
  [model enumerateItemsUsingBlock:^(id item, NSIndexPath *indexPath, BOOL *stop) {
    itemCount++;
    id queriedItem = [model objectAtIndexPath:indexPath];
    NSIndexPath *queriedIndexPath = [model indexPathForObject:item];
    XCTAssertEqualObjects(item, queriedItem);
    XCTAssertEqualObjects(indexPath, queriedIndexPath);
  }];
  XCTAssertEqual(itemCount, 9);
}

- (void)testUpdateToMatchModel {
  NIMutableCollectionViewModel *model1 = CollectionViewModel();
  NIMutableCollectionViewModel *model2 = CollectionViewModel();

  [model1 removeSectionAtIndex:1];
  [model2 updateToMatchModel:model1];

  XCTAssertEqualObjects(model1, model2);

  model1 = CollectionViewModel();
  [model2 updateToMatchModel:model1];

  XCTAssertEqualObjects(model1, model2);
}

- (void)testUpdateToMatchModelWithCollectionView {
  TestCollectionView *collectionView = [TestCollectionView collectionView];
  NIMutableCollectionViewModel *viewModel = CollectionViewModel();
  NIMutableCollectionViewModel *updatedModel = CollectionViewModel();

  collectionView.dataSource = viewModel;

  [updatedModel removeSectionAtIndex:1];

  [collectionView performBatchUpdates:^{
    [viewModel updateToMatchModel:updatedModel withCollectionView:collectionView];
  } completion:^(BOOL finished) { }];
  XCTAssertEqualObjects(viewModel, updatedModel);
  XCTAssertEqual(collectionView.deletedSections.count, 1);
  XCTAssertEqual(collectionView.deletedItems.count, 3);

  [collectionView resetUpdateTracking];
  updatedModel = CollectionViewModel();
  [collectionView performBatchUpdates:^{
    [viewModel updateToMatchModel:updatedModel withCollectionView:collectionView];
  } completion:^(BOOL finished) { }];
  XCTAssertEqualObjects(viewModel, updatedModel);
  XCTAssertEqual(collectionView.insertedSections.count, 1);
  XCTAssertEqual(collectionView.insertedItems.count, 3);
}

@end
