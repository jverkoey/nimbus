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

#import "BasicInstantiationTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of creating a NITableViewModel and filling it with a list of objects that will
// be displayed in a table view.
//
// You will find the following Nimbus features used:
//
// [models]
// NITableViewModel
// NICellFactory
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface BasicInstantiationTableModelViewController ()
@property (nonatomic, retain) NITableViewModel* model;
@end

@implementation BasicInstantiationTableModelViewController


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Basic Instantiation";
    
    // This controller uses the Nimbus table view model. In loose terms, Nimbus models implement
    // data source protocols. They encapsulate standard delegate functionality and will make your
    // life a lot easier. In this particular case we're using NITableViewModel with a list of
    // objects.
    //
    // Each of these objects implements the NICellObject protocol which requires the object to
    // implement the method "cellClass". This method is called by the NICellFactory to determine
    // which UITableViewCell implementation should be used to display this object.
    //
    // When a cell is about to be created, the model asks its delegate to create a cell with the
    // given object. In most cases the delegate is [NICellFactory class]. NICellFactory implements
    // the NITableViewModelDelegate protocol as static methods, allowing us to use it as a delegate
    // without instantiating it.
    //
    // Once the cell is created, shouldUpdateCellWithObject: is called on the cell, giving it the
    // opportunity to update itself accordingly.
    NSArray* tableContents =
    [NSArray arrayWithObjects:

     // Shows a cell with a title.
     [NITitleCellObject objectWithTitle:@"Row 1"],
     [NITitleCellObject objectWithTitle:@"Row 2"],

     // Shows a cell with a title and subtitle.
     [NISubtitleCellObject objectWithTitle:@"Row 3" subtitle:@"Subtitle"],
     nil];
    
    // NITableViewModel may be initialized with two types of arrays: list and sectioned.
    // A list array is a list of objects, where each object in the array will map to a cell in
    // the table view.
    // A sectioned array is a list of NSStrings and objects, where each NSString starts a new
    // section and any other type of object is a cell.
    //
    // As discussed above, we provide the model with the NICellFactory class as its delegate.
    // In a future example we will show how you can create a NICellFactory object to override the
    // default mappings that the cell objects return from their cellClass implementation.
    //
    // Further exploration:
    // Check out the NICellFactory implementation and notice how the NITableViewModelDelegate
    // methods are implemented twice. First as class methods (+ as a prefix), second as
    // instance methods (- as a prefix). This allows you to use NICellFactory's class object as
    // the delegate or to instantiate the NICellFactory as an object and provide explicit mappings.
    _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Only assign the table view's data source after the view has loaded.
  // You must be careful when you call self.tableView in general because it will call loadView
  // if the view has not been loaded yet. You do not need to clear the data source when the
  // view is unloaded (more importantly: you shouldn't, due to the reason just outlined
  // regarding loadView).
  self.tableView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
