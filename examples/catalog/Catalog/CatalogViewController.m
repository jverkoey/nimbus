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

// Attributed Label
#import "BasicInstantiationAttributedLabelViewController.h"
#import "CustomTextAttributedLabelViewController.h"
#import "LinksAttributedLabelViewController.h"
#import "DataTypesAttributedLabelViewController.h"
#import "ImagesAttributedLabelViewController.h"
#import "PerformanceAttributedLabelViewController.h"
#import "LongTapAttributedLabelViewController.h"
#import "InterfaceBuilderAttributedLabelViewController.h"

// Badge
#import "BasicInstantiationBadgeViewController.h"
#import "CustomizingBadgesViewController.h"
#import "InterfaceBuilderBadgeViewController.h"

// Interapp
#import "InterappViewController.h"

// Launcher
#import "BasicInstantiationLauncherViewController.h"
#import "ModelLauncherViewController.h"
#import "ModifyingLauncherViewController.h"
#import "RestoringLauncherViewController.h"
#import "BadgedLauncherViewController.h"

// Navigation Appearance
#import "NavigationAppearanceViewController.h"

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

// Web Controller
#import "ExtraActionsWebViewController.h"

#import "NimbusModels.h"
#import "NimbusWebController.h"

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

@synthesize model = _model;
@synthesize actions = _actions;

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
      NIPushControllerAction([BasicInstantiationAttributedLabelViewController class])

      // A subtitle cell object will eventually display a NITextCell in the table view. A NITextCell
      // is a simple UITableViewCell built to work with Nimbus' cell architecture.
      toObject:[NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                            subtitle:@"How to create a simple NIAttributedLabel"]],

     [_actions attachNavigationAction:
      NIPushControllerAction([CustomTextAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Customizing Text"
                                   subtitle:@"How to use NSAttributedString"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([LinksAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Links"
                                   subtitle:@"Automatic and explicit links"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([DataTypesAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Data Types"
                                   subtitle:@"Detecting different data types"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ImagesAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Images"
                                   subtitle:@"Adding inline images"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([PerformanceAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Performance"
                                   subtitle:@"Speeding up attributed labels"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([LongTapAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Long Taps"
                                   subtitle:@"Configuring long tap action sheets"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([InterfaceBuilderAttributedLabelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Interface Builder"
                                   subtitle:@"Using attributed labels in IB"]],

     @"Badge",
     [_actions attachNavigationAction:
      NIPushControllerAction([BasicInstantiationBadgeViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a simple NIBadgeView"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([CustomizingBadgesViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Customizing Badges"
                                   subtitle:@"How to customize badges"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([InterfaceBuilderBadgeViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Interface Builder"
                                   subtitle:@"Using badges in IB"]],

     @"Interapp",
     [_actions attachNavigationAction:
      NIPushControllerAction([InterappViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"All Actions"
                                   subtitle:@"A list of all available actions"]],
     
     @"Launcher",
     [_actions attachNavigationAction:
      NIPushControllerAction([BasicInstantiationLauncherViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to subclass a launcher controller"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ModelLauncherViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Model"
                                   subtitle:@"Using a model to manage data"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ModifyingLauncherViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Modifying"
                                   subtitle:@"How to add new launcher buttons"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([RestoringLauncherViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Restoring"
                                   subtitle:@"Saving and loading launcher data"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([BadgedLauncherViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Badges"
                                   subtitle:@"Adding badges to launcher items"]],
     
     @"Navigation Apperance",
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NavigationAppearanceViewController *appearanceController = 
        [[NavigationAppearanceViewController alloc] init];
        appearanceController.changeBarStyle = YES;
        [controller.navigationController pushViewController:appearanceController animated:YES];
        return NO;
      } toObject:
      [NISubtitleCellObject objectWithTitle:@"Bar Style"
                                   subtitle:@"Modify navigation bar style"]],
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NavigationAppearanceViewController *appearanceController = 
          [[NavigationAppearanceViewController alloc] init];
        appearanceController.changeTintColor = YES;
        [controller.navigationController pushViewController:appearanceController animated:YES];
        return NO;
      } toObject:
      [NISubtitleCellObject objectWithTitle:@"Tint Color"
                                   subtitle:@"Modify navigation bar tint color"]], 
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NavigationAppearanceViewController *appearanceController = 
        [[NavigationAppearanceViewController alloc] init];
        appearanceController.changeBackgroundImage = YES;
        [controller.navigationController pushViewController:appearanceController animated:YES];
        return NO;
      } toObject:
      [NISubtitleCellObject objectWithTitle:@"Background Image"
                                   subtitle:@"Modify navigation bar background image"]],

     @"Network Image",
     [_actions attachNavigationAction:
      NIPushControllerAction([BasicInstantiationNetworkImageViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a NINetworkImageView"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ContentModesNetworkImageViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Content Modes"
                                   subtitle:@"Effects of each content mode"]],
     
     @"Paging Scroll Views",
     [_actions attachNavigationAction:
      NIPushControllerAction([BasicInstantiationPagingScrollViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a paging scroll view"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([VerticalPagingScrollViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Vertical Paging"
                                   subtitle:@"Using a vertical layout"]],

     @"Table Models",
     [_actions attachNavigationAction:
      NIPushControllerAction([BasicInstantiationTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a table view model"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([SectionedTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Sectioned Model"
                                   subtitle:@"Sectioned table view models"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([IndexedTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Indexed Model"
                                   subtitle:@"Indexed table view models"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ActionsTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Actions"
                                   subtitle:@"Handling actions in table views"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([RadioGroupTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Radio Group"
                                   subtitle:@"How to use radio groups"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([NestedRadioGroupTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Nested Radio Group"
                                   subtitle:@"How to nest radio groups"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([ModalRadioGroupTableModelViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Modal Radio Group"
                                   subtitle:@"Customizing presentation"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([FormCellCatalogViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Form Cell Catalog"
                                   subtitle:@"Table view cells for forms"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([BlockCellsViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Block Cells"
                                   subtitle:@"Rendering cells with blocks"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([NetworkBlockCellsViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Network Block Cells"
                                   subtitle:@"Rendering network images with blocks"]],
     [_actions attachNavigationAction:
      NIPushControllerAction([SnapshotRotationTableViewController class])
                             toObject:
      [NISubtitleCellObject objectWithTitle:@"Snapshot Rotation"
                                   subtitle:@"Rotating table views with snapshots"]],
     
     @"Web Controller",
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];
        
        return NO;
      } toObject:
      [NISubtitleCellObject objectWithTitle:@"Basic Instantiation"
                                   subtitle:@"How to create a simple NIWebController"]],
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        webController.toolbarHidden = YES;
        [controller.navigationController pushViewController:webController
                                                   animated:YES];
        
        return NO;
      } toObject:[NISubtitleCellObject objectWithTitle:@"Hiding the Toolbar"
                                              subtitle:@"Showing a web controller without actions"]],
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NIWebController* webController = [[NIWebController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        webController.toolbarTintColor = [UIColor orangeColor];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];
        
        return NO;
      } toObject:[NISubtitleCellObject objectWithTitle:@"Tinting the Toolbar"
                                              subtitle:@"Tinting a web controller's toolbar"]],
     [_actions attachNavigationAction:
      ^(id object, UIViewController* controller) {
        NIWebController* webController = [[ExtraActionsWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://nimbuskit.info"]];
        [controller.navigationController pushViewController:webController
                                                   animated:YES];
        
        return NO;
      } toObject:
      [NISubtitleCellObject objectWithTitle:@"Extra Actions"
                                   subtitle:@"Subclassing for more actions"]],

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
  // functionality of Objective-C to insert the actions object between the table view
  // and this controller. The actions object forwards UITableViewDelegate methods along and
  // selectively intercepts methods required to make user interactions work.
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
