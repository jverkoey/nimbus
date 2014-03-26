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

#import "BasicInstantiationCollectionModelViewController.h"

#import "ColorCell.h"

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

@interface BasicInstantiationCollectionModelViewController ()

// A model exists through the lifetime of the controller.
@property (nonatomic, strong) NICollectionViewModel* model;

@end

@implementation BasicInstantiationCollectionModelViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
  UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
  if ((self = [super initWithCollectionViewLayout:flowLayout])) {
    self.title = @"Basic Instantiation";

    // This controller uses the Nimbus collection view model. In loose terms, Nimbus models
    // implement data source protocols. In this particular case we're using NICollectionViewModel
    // with a list of objects.
    //
    // Each of these objects must implement the NICollectionViewCellObject protocol which requires
    // the object to implement the method `-collectionViewCellClass`. This method can be called by
    // the delegate provided to NICollectionViewModel to determine which cell implementation should
    // be used to display this object.
    //
    // In this case we will use the NICollectionViewCellFactory helper class which provides a
    // typical implementation of the NICollectionViewModelDelegate protocol.
    NSArray* collectionContents =
    @[
      // You can find the implementation for the cells used in this catalog in the "Collection
      // Cells" folder, or by command-clicking the cell object class name.
      [Color colorWithColor:[UIColor redColor]],
      [Color colorWithColor:[UIColor blueColor]],
    ];

    // NICollectionViewModel may be initialized with two types of arrays: list and sectioned.
    // A list array is a list of objects, where each object in the array will map to a cell in
    // the collection view.
    // A sectioned array is a list of NSStrings and objects, where each NSString starts a new
    // section and any other type of object is a cell.
    //
    // As discussed above, we provide the model with the NICollectionViewCellFactory class as its
    // delegate.
    //
    // Further exploration:
    // Check out the NICollectionViewCellFactory implementation and notice how the
    // NICollectionViewModelDelegate methods are implemented twice. First as class methods (+ as a
    // prefix), second as instance methods (- as a prefix). This allows you to use
    // NICollectionViewCellFactory's class as the delegate or to instantiate the
    // NICollectionViewCellFactory as an object and provide explicit mappings.
    _model = [[NICollectionViewModel alloc] initWithListArray:collectionContents
                                                     delegate:(id)[NICollectionViewCellFactory class]];
  }
  return self;
}

- (id)init {
  // UICollectionViewController doesn't implement its initializer chain as would be expected, so we
  // must forward init methods to -initWithCollectionViewLayout ourselves.
  return [self initWithCollectionViewLayout:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Only assign the collection view's data source after the view has loaded.
  // You must be careful when you call self.collectionView in general because it will call loadView
  // if the view has not been loaded yet.
  self.collectionView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
