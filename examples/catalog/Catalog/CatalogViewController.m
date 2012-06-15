//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "CatalogViewController.h"

#import "HelloWorldAttributedLabelViewController.h"

//
// What's going on in this file:
//
// This is the root view controller of the Nimbus iPhone Catalog application. It is a table view
// controller that uses Nimbus' table view models features to populate the data source and handle
// user actions. From this controller the user can navigate into any of the Nimbus samples.
//
// You will find the following Nimbus features used:
//
// [core]
// NIIsSupportedOrientation()
//
// [models]
// NITableViewModel
// NITableViewActions
// NISubtitleCellObject
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface CatalogViewController ()
// We declare these properties here in the source file so that we don't have to expose private
// interfaces publicly in the header.
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end

@implementation CatalogViewController

- (id)initWithStyle:(UITableViewStyle)style {
  // We explicitly set the table view style in this controller's implementation because we want this
  // controller to control how the table view is displayed.
  self = [super initWithStyle:UITableViewStyleGrouped];

  if (self) {
    // We set the title in the init method because it will never change. You generally don't neet to
    // set the title in loadView or viewDidLoad because those methods may be called repeatedly.
    self.title = @"Nimbus Catalog";

    // When we instantiate the actions object we must provide it with a weak reference to the parent
    // controller. This value is passed to the action blocks so that we can easily navigate to new
    // controllers without introducing retain cycles by otherwise having to access self in the
    // block.
    _actions = [[NITableViewActions alloc] initWithController:self];

    // This controller uses the Nimbus table view model. In loose terms, Nimbus models implement
    // data source protocols. They encapsulate standard delegate functionality and will make your
    // life a lot easier. In this particular case we're using NITableViewModel with a sectioned
    // array of objects.
    NSArray* sectionedObjects =
    [NSArray arrayWithObjects:

     // An NSString in a sectioned array denotes the start of a new section. It's also the label of
     // the section header.
     @"Attributed Label",

     // Any objects following an NSString will be part of the same group until another NSString
     // is encountered.

     // We attach actions to objects using the chaining pattern. The "attach" methods of
     // NITableViewActions will return the object we pass to them, allowing us to create an object,
     // attach an action to it, and then add the object to the sectioned array in one statement.
     [_actions attachNavigationAction:

      // NIPushControllerAction is a helper method that instantiates the controller class and then
      // pushes it onto the current view controller's navigation stack.
      NIPushControllerAction([HelloWorldAttributedLabelViewController class])

      // A subtitle cell object will eventually display a NITextCell in the table view. A NITextCell
      // is a simple UITableViewCell built to work with Nimbus' cell architecture.
      toObject:[NISubtitleCellObject objectWithTitle:@"Hello World"
                                            subtitle:@"Create a simple NIAttributedLabel"]],
     nil];

    // When we create the model we must provide it with a delegate that implements the
    // NITableViewModelDelegate protocol. This protocol has a single method that is used to create
    // cells given an object from the model. If we don't require any custom cell bindings then it's
    // often easiest to use the NICellFactory as the delegate. The NICellFactory class provides a
    // barebones implementation that is sufficient for nearly all applications.
    _model = [[NITableViewModel alloc] initWithSectionedArray:sectionedObjects
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Once the tableView has loaded we attach the model to the data source. As mentioned above,
  // NITableViewModel implements UITableViewDataSource so that you don't have to implement any
  // of the data source methods directly in your controller.
  self.tableView.dataSource = self.model;

  // What we're doing here is known as "delegate chaining". It uses the message forwarding
  // functionality of Objective-C to allow us to insert the actions object between the table view
  // and this controller. The actions object forwards all methods of the UITableViewDelegate and
  // also selectively implements the methods required to make user interactions work.
  //
  // Experiment: try commenting out this line. You'll notice that you can no longer tap any of
  // the cells in the table view and that they no longer show the disclosure accessory types.
  // Cool, eh? That this functionality is all provided to you in one line should make you
  // heel-click.
  self.tableView.delegate = [self.actions forwardingTo:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  // This is a core Nimbus method that simplifies the logic required to display a controller on
  // both the iPad (where all orientations are supported) and the iPhone (where anything but
  // upside-down is supported). This method will be deprecated in iOS 6.0.
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
