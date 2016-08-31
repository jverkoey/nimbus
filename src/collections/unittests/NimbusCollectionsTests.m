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
#import "NimbusModels.h"

static UICollectionView *CollectionView() {
  UICollectionViewLayout *layout = [[UICollectionViewLayout alloc] init];
  UICollectionView *collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  return collectionView;
}

static id ObjectWithTitle(NSString *title) {
  return [NITitleCellObject objectWithTitle:title];
}

@interface NimbusCollectionsTests : XCTestCase
@end

@implementation NimbusCollectionsTests

- (void)testMutableModelInitializationWithListArray {
  NIMutableCollectionViewModel *model =
      [[NIMutableCollectionViewModel alloc] initWithListArray:@[ ObjectWithTitle(@"One") ]
                                                     delegate:nil];
  UICollectionView *collectionView = CollectionView();
  XCTAssertEqual([model collectionView:collectionView numberOfItemsInSection:0], 1);
  [model addObject:ObjectWithTitle(@"Two")];
  XCTAssertEqual([model collectionView:collectionView numberOfItemsInSection:0], 2);
}

@end
