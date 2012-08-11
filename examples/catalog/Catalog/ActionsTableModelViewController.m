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

#import "ActionsTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of handling actions in a UITableView.
//
// The NITableViewActions object attaches blocks to objects in three contexts: tapping, navigating,
// and detail actions. Any combination of these three blocks may be attached to a given object.
// The actions object will automatically update the accessory type of the cell when it is displayed
// so that it shows the correct accessory type for the available actions.
//
// You will find the following Nimbus features used:
//
// [models]
// NITableViewModel
// NITableViewActions
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface ActionsTableModelViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;

// The actions are stored in a separate object from the model.
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end

@implementation ActionsTableModelViewController

@synthesize model = _model;
@synthesize actions = _actions;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Actions";

    // We provide a weak reference to the controller object so that the actions object can pass
    // the controller to the block when the action is executed.
    _actions = [[NITableViewActions alloc] initWithController:self];

    // This is what an action block looks like. The block is given the object that was tapped and
    // the containing controller. In the following two blocks we simply show an alert view.
    NITableViewActionBlock tapAction = ^BOOL(id object, UIViewController *controller) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                      message:@"You tapped a cell!"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];

      // For tap actions specifically, returning YES means that we want the cell to deselect itself
      // after the action has performed. All other types of actions ignore the return value.
      return YES;
    };
    
    NITableViewActionBlock tapAction2 = ^BOOL(id object, UIViewController *controller) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                      message:@"Alternative tap action"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
      return YES;
    };

    NSArray* tableContents =
    [NSArray arrayWithObjects:

     // As seen in previous examples, this will show a cell that is not actionable. Tapping it will
     // not highlight it, nor are any cell accessories shown.
     [NITitleCellObject objectWithTitle:@"No action attached"],

     @"",
     // This attaches one of the tap action blocks defined above to this cell. Notice how we are
     // using the return value of attachTapAction:toObject: here. The attach:toObject: methods all
     // return the object that was passed in, allowing you to simultaneously add an object to a
     // table model and attach an action to it.
     [_actions attachTapAction:tapAction toObject:[NITitleCellObject objectWithTitle:@"Tap me"]],

     @"",
     // This attaches a navigation action to the object. We use a standard method,
     // NIPushControllerAction, here which simply instantiates the given class and then pushes it
     // to the current navigation controller. This method does not work in all situations, in which
     // cases you should implement your own block. When this cell appears it will automatically be
     // assigned a navigation accessory type.
     [_actions attachNavigationAction:NIPushControllerAction([ActionsTableModelViewController class])
                             toObject:[NITitleCellObject objectWithTitle:@"Navigate elsewhere"]],

     // This attaches a detail action to the object, displaying a detail accessory on the cell that
     // can be tapped. When the detail accessory is tapped, this action is executed.
     [_actions attachDetailAction:NIPushControllerAction([ActionsTableModelViewController class])
                         toObject:[NITitleCellObject objectWithTitle:@"Detail action"]],

     // It is possible to attach multiple types of actions to a single object. In the next three
     // examples we show attaching different types of actions to objects.
     [_actions attachDetailAction:NIPushControllerAction([ActionsTableModelViewController class])
                         toObject:
      [_actions attachNavigationAction:NIPushControllerAction([ActionsTableModelViewController class])
                              toObject:[NITitleCellObject objectWithTitle:@"Navigate and detail"]]],
     
     [_actions attachDetailAction:NIPushControllerAction([ActionsTableModelViewController class])
                         toObject:
      [_actions attachTapAction:tapAction
                       toObject:[NITitleCellObject objectWithTitle:@"Tap and detail"]]],

     // When you have a tap and navigation action attached to an object, both will be executed when
     // you tap the cell. Try tapping this cell and you will see that it navigates and shows an
     // alert view simultaneously.
     [_actions attachDetailAction:NIPushControllerAction([ActionsTableModelViewController class])
                         toObject:
      [_actions attachTapAction:tapAction
                       toObject:
       [_actions attachNavigationAction:NIPushControllerAction([ActionsTableModelViewController class])
                               toObject:[NITitleCellObject objectWithTitle:@"All actions"]]]],

     @"Implicit Actions",
     // It is possible to set up implicit actions by attach an action to a class. When such an
     // attachment is made, all instances of that class (including subclasses of that class) will
     // implicitly have the given action. For example, below we attach a tap action to the
     // NISubtitleCellObject class. Now when we include any NISubtitleCellObject or subclass of
     // NISubtitleCellObject in the model they will automatically respond to taps.
     [NISubtitleCellObject objectWithTitle:@"Tap me" subtitle:@"Implicit action"],

     // You can also explicitly override the implicit action by attaching an action directly to
     // the object.
     [_actions attachTapAction:tapAction2 toObject:
      [NISubtitleCellObject objectWithTitle:@"Override" subtitle:@"Explicit tap action"]],

     nil];

    // This attaches a tap action to all instances of NISubtitleCellObject and is a great way to
    // handle common cells.
    [_actions attachTapAction:tapAction toClass:[NISubtitleCellObject class]];

    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

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
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
