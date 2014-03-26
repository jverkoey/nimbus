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

#import "CatalogViewController.h"

// Attributed Label
#import "BasicInstantiationAttributedLabelViewController.h"
#import "CustomTextAttributedLabelViewController.h"
#import "LinksAttributedLabelViewController.h"
#import "DataTypesAttributedLabelViewController.h"
#import "ImagesAttributedLabelViewController.h"
#import "PerformanceAttributedLabelViewController.h"
#import "LongTapAttributedLabelViewController.h"
#import "InterfaceBuilderAttributedLabelViewController.h"
#import "AlignmentAttributedLabelViewController.h"

// Badge
#import "BasicInstantiationBadgeViewController.h"
#import "CustomizingBadgesViewController.h"
#import "InterfaceBuilderBadgeViewController.h"

// Collections
#import "BasicInstantiationCollectionModelViewController.h"
#import "NibCollectionModelViewController.h"
#import "CustomNibCollectionModelViewController.h"

// Interapp
#import "InterappViewController.h"

// Launcher
#import "BasicInstantiationLauncherViewController.h"
#import "ModelLauncherViewController.h"
#import "ModifyingLauncherViewController.h"
#import "RestoringLauncherViewController.h"
#import "BadgedLauncherViewController.h"

// Network Image
#import "BasicInstantiationNetworkImageViewController.h"
#import "ContentModesNetworkImageViewController.h"

// Paging Scroll View
#import "BasicInstantiationPagingScrollViewController.h"
#import "VerticalPagingScrollViewController.h"

// Tables
#import "BasicInstantiationTableModelViewController.h"
#import "SectionedTableModelViewController.h"
#import "IndexedTableModelViewController.h"
#import "ActionsTableModelViewController.h"
#import "RadioGroupTableModelViewController.h"
#import "NestedRadioGroupTableModelViewController.h"
#import "ModalRadioGroupTableModelViewController.h"
#import "FormCellCatalogViewController.h"
#import "NetworkBlockCellsViewController.h"
#import "BlockCellsViewController.h"
#import "SnapshotRotationTableViewController.h"
#import "MutableTableModelViewController.h"

// Web Controller
#import "ExtraActionsWebViewController.h"

#import "NimbusModels.h"
#import "NimbusWebController.h"

//
// What's going on in this file:
//
// This is the root view controller of the Nimbus iPhone Catalog application. It is a table view
// controller that uses Nimbus' table view models features to populate the data source and handle
// user actions. From this controller the user can navigate to any of the Nimbus samples.
//
// You will find the following Nimbus features used:
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

@implementation CatalogViewController {
  // The UITableView refers to the model and actions objects throughout its lifetime but does not
  // retain them. We must store the instances in this class.
  NITableViewModel* _model;
  NITableViewActions* _actions;
}

- (id)initWithStyle:(UITableViewStyle)style {
  // We explicitly set the table view style in this controller's implementation because we want this
  // controller to control how the table view is displayed.
  self = [super initWithStyle:UITableViewStyleGrouped];

  if (self) {
    // We set the title in the init method because it will never change.
    self.title = @"Nimbus Catalog";

    // When we instantiate the actions object we must provide it with a reference to the target to
    // whom actions will be sent.
    //
    // For block actions:
    // This value is passed to the block as an argument so that we can navigate to new
    // controllers without introducing retain cycles by otherwise having to access
    // self.navigationController in the block.
    //
    // For selector actions:
    // The selector will be executed on the target. For a demo of selector actions, see
    // ActionsTableModelViewController.m.
    _actions = [[NITableViewActions alloc] initWithTarget:self];

    // This controller uses the Nimbus table view model. In loose terms, Nimbus models implement
    // data source protocols. They avoid code duplication and abstract the storage of the backing
    // data for views. There is a model for UITableView, NITableViewModel, and a model for
    // UICollectionView, NICollectionViewModel.
    //
    // We're going to use NITableViewModel with a sectioned array of objects. A sectioned array of
    // objects is an NSArray where any instance of an NSString delimits the beginning of a new
    // section.
    NSArray* sectionedObjects =
    @[
     // An NSString in a sectioned array denotes the start of a new section. It's also the label of
     // the section header.
     @"Attributed Label",

     // Any objects following an NSString will be part of the same group until another NSString
     // is encountered.

     // We attach actions to objects using the chaining pattern. The "attach" methods of
     // NITableViewActions will return the object we pass to them, allowing us to create an object,
     // attach an action to it, and then add the object to the sectioned array in one statement.
     [_actions attachToObject:

      // A subtitle cell object will eventually display a NITextCell in the table view. A NITextCell
      // is a simple UITableViewCell built to work with Nimbus' cell architecture.
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a simple NIAttributedLabel"]

      // NIPushControllerAction is a helper method that instantiates the controller class and then
      // pushes it onto the current view controller's navigation stack. It initializes the
      // controller via the init method, so if you need custom initialization then you'll need to
      // implement the block yourself.
              navigationBlock:NIPushControllerAction([BasicInstantiationAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Customizing Text"
                                   subtitle:@"How to use NSAttributedString"]
              navigationBlock:NIPushControllerAction([CustomTextAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Links"
                                   subtitle:@"Automatic and explicit links"]
              navigationBlock:NIPushControllerAction([LinksAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Data Types"
                                   subtitle:@"Detecting different data types"]
              navigationBlock:NIPushControllerAction([DataTypesAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Images"
                                   subtitle:@"Adding inline images"]
              navigationBlock:NIPushControllerAction([ImagesAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Performance"
                                   subtitle:@"Speeding up attributed labels"]
              navigationBlock:NIPushControllerAction([PerformanceAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Long Taps"
                                   subtitle:@"Configuring long tap action sheets"]
              navigationBlock:NIPushControllerAction([LongTapAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Interface Builder"
                                   subtitle:@"Using attributed labels in IB"]
              navigationBlock:NIPushControllerAction([InterfaceBuilderAttributedLabelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Alignment"
                                   subtitle:@"Verical alignment in attributed labels"]
              navigationBlock:NIPushControllerAction([AlignmentAttributedLabelViewController class])],

     @"Badge",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a simple NIBadgeView"]
              navigationBlock:NIPushControllerAction([BasicInstantiationBadgeViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Customizing Badges"
                                   subtitle:@"How to customize badges"]
              navigationBlock:NIPushControllerAction([CustomizingBadgesViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Interface Builder"
                                   subtitle:@"Using badges in IB"]
              navigationBlock:NIPushControllerAction([InterfaceBuilderBadgeViewController class])],

     @"Collections",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a collection view model"]
              navigationBlock:NIPushControllerAction([BasicInstantiationCollectionModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Nibs"
                                   subtitle:@"How to use nibs with collection view models"]
              navigationBlock:NIPushControllerAction([NibCollectionModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Custom Nibs"
                                   subtitle:@"How to customize nibs"]
              navigationBlock:NIPushControllerAction([CustomNibCollectionModelViewController class])],

     @"Interapp",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"All Actions"
                                   subtitle:@"A list of all available actions"]
              navigationBlock:NIPushControllerAction([InterappViewController class])],

     @"Launcher",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to subclass a launcher controller"]
              navigationBlock:NIPushControllerAction([BasicInstantiationLauncherViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Model"
                                   subtitle:@"Using a model to manage data"]
              navigationBlock:NIPushControllerAction([ModelLauncherViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Modifying"
                                   subtitle:@"How to add new launcher buttons"]
              navigationBlock:NIPushControllerAction([ModifyingLauncherViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Restoring"
                                   subtitle:@"Saving and loading launcher data"]
              navigationBlock:NIPushControllerAction([RestoringLauncherViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Badges"
                                   subtitle:@"Adding badges to launcher items"]
              navigationBlock:NIPushControllerAction([BadgedLauncherViewController class])],

     @"Network Image",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a NINetworkImageView"]
              navigationBlock:NIPushControllerAction([BasicInstantiationNetworkImageViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Content Modes"
                                   subtitle:@"Effects of each content mode"]
              navigationBlock:NIPushControllerAction([ContentModesNetworkImageViewController class])],

     @"Paging Scroll Views",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a paging scroll view"]
              navigationBlock:NIPushControllerAction([BasicInstantiationPagingScrollViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Vertical Paging"
                                   subtitle:@"Using a vertical layout"]
              navigationBlock:NIPushControllerAction([VerticalPagingScrollViewController class])],

     @"Table Models",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a table view model"]
              navigationBlock:NIPushControllerAction([BasicInstantiationTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Sectioned Model"
                                   subtitle:@"Sectioned table view models"]
              navigationBlock:NIPushControllerAction([SectionedTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Indexed Model"
                                   subtitle:@"Indexed table view models"]
              navigationBlock:NIPushControllerAction([IndexedTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Actions"
                                   subtitle:@"Handling actions in table views"]
              navigationBlock:NIPushControllerAction([ActionsTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Radio Group"
                                   subtitle:@"How to use radio groups"]
              navigationBlock:NIPushControllerAction([RadioGroupTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Nested Radio Group"
                                   subtitle:@"How to nest radio groups"]
              navigationBlock:NIPushControllerAction([NestedRadioGroupTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Modal Radio Group"
                                   subtitle:@"Customizing presentation"]
              navigationBlock:NIPushControllerAction([ModalRadioGroupTableModelViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Form Cell Catalog"
                                   subtitle:@"Table view cells for forms"]
              navigationBlock:NIPushControllerAction([FormCellCatalogViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Block Cells"
                                   subtitle:@"Rendering cells with blocks"]
              navigationBlock:NIPushControllerAction([BlockCellsViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Network Block Cells"
                                   subtitle:@"Rendering network images with blocks"]
              navigationBlock:NIPushControllerAction([NetworkBlockCellsViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Snapshot Rotation"
                                   subtitle:@"Rotating table views with snapshots"]
              navigationBlock:NIPushControllerAction([SnapshotRotationTableViewController class])],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Mutable Models"
                                   subtitle:@"Mutating table view models"]
              navigationBlock:NIPushControllerAction([MutableTableModelViewController class])],

     @"Web Controller",

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a simple NIWebController"]
              navigationBlock:
      ^(id object, UIViewController* controller, NSIndexPath* indexPath) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];

        // NimbusKit uses the return value from this block to determine whether to deselect the cell
        // after it has been selected. This, however, only applies to tap actions. For navigation
        // actions we never want to deselect the cell immediately after tapping it because we're
        // supposed to keep it selected until the controller we pushed gets popped, at which point
        // the selected cell will be deselected during the pop animation.
        return NO;
      }],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Hiding the Toolbar"
                                   subtitle:@"Showing a web controller without actions"]
              navigationBlock:
      ^(id object, UIViewController* controller, NSIndexPath* indexPath) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        webController.toolbarHidden = YES;
        [controller.navigationController pushViewController:webController
                                                   animated:YES];

        return NO;
      }],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Tinting the Toolbar"
                                   subtitle:@"Tinting a web controller's toolbar"]
              navigationBlock:
      ^(id object, UIViewController* controller, NSIndexPath* indexPath) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        webController.toolbarTintColor = [UIColor orangeColor];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];

        return NO;
      }],

     [_actions attachToObject:
      [NISubtitleCellObject objectWithTitle:@"Extra Actions"
                                   subtitle:@"Subclassing for more actions"]
              navigationBlock:
      ^(id object, UIViewController* controller, NSIndexPath* indexPath) {
        NIWebController* webController = [[ExtraActionsWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];

        return NO;
      }]
     ];

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
  self.tableView.dataSource = _model;

  // What we're doing here is known as "delegate chaining". It uses the message forwarding
  // functionality of Objective-C to insert the actions object between the table view
  // and this controller. The actions object forwards UITableViewDelegate methods along and
  // selectively intercepts methods required to make user interactions work.
  //
  // Experiment: try commenting out this line. You'll notice that you can no longer tap any of
  // the cells in the table view and that they no longer show the disclosure accessory types.
  // Cool, eh? That this functionality is all provided to you in one line should make you
  // heel-click.
  self.tableView.delegate = [_actions forwardingTo:self];
}

@end
