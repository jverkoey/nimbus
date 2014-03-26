//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "NibCollectionModelViewController.h"

#import "NibCellObject.h"

#import "NimbusCollections.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of creating a NICollectionViewModel and filling it with a list of objects that
// will be displayed in a collection view.
//
// You will find the following Nimbus features used:
//
// [collections]
// NICollectionViewModel
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface NibCollectionModelViewController ()
@property (nonatomic, strong) NICollectionViewModel* model;
@end

@implementation NibCollectionModelViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
  flowLayout.itemSize = CGSizeMake(200, 200);
  if ((self = [super initWithCollectionViewLayout:flowLayout])) {
    self.title = @"Nibs";

    NSArray* collectionContents =
    @[
      [[NibCellObject alloc] init],
      [[NibCellObject alloc] init],
    ];

    _model = [[NICollectionViewModel alloc] initWithListArray:collectionContents
                                                     delegate:(id)[NICollectionViewCellFactory class]];
  }
  return self;
}

- (id)init {
  return [self initWithCollectionViewLayout:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.collectionView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
