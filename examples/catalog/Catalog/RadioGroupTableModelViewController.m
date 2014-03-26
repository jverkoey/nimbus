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

#import "RadioGroupTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of using a radio group with a table view simultaneously with table actions.
//
// You will find the following Nimbus features used:
//
// [models]
// NIRadioGroup
// NITableViewModel
// NITableViewActions
// NICellFactory
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

typedef enum {
  RadioGroupOption1,
  RadioGroupOption2,
  RadioGroupOption3,
} RadioGroup;

@interface RadioGroupTableModelViewController () <NIRadioGroupDelegate>
@end

@implementation RadioGroupTableModelViewController {
  NITableViewModel* _model;

  // In order to implement the radio group we must create a radio group object. This object will
  // maintain the state of the currently selected object. It will also handle all user interactions
  // and updating the visual state of the cell when the selection changes.
  NIRadioGroup* _radioGroup;

  NITableViewActions* _actions;
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Radio Group";

    // When we create the radio group we must provide it with a reference to the parent controller.
    // This allows the radio group to push new controllers onto the navigation controller when the
    // radio group is added as an object in the table view model.
    _radioGroup = [[NIRadioGroup alloc] initWithController:self];

    // We want to be notified of changes to the radio group selection.
    _radioGroup.delegate = self;

    // We'll demonstrate how to use a radio group and actions simultaneously.
    _actions = [[NITableViewActions alloc] initWithTarget:self];

    // When we create the table contents we use the chaining pattern to create the table cell
    // object, map it in the radio group to an identifier, and then add the object to the array.
    // The radio group's mapObject:toIdentifier: method returns the given object which is what
    // allows us to use this pattern.
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     [_actions attachToObject:[NITitleCellObject objectWithTitle:@"Tap me"] tapSelector:@selector(didTapObject:)],
     [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 1"] toIdentifier:RadioGroupOption1],
     [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 2"] toIdentifier:RadioGroupOption2],
     [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 3"] toIdentifier:RadioGroupOption3],
     nil];

    // The alternative method to initializing the radio group would look like this for each
    // object:
    //
    //   NITitleCellObject* object1 = [NITitleCellObject objectWithTitle:@"Option 1"];
    //   [_radioGroup mapObject:object1 toIdentifier:RadioGroupOption1];
    //   [tableContents addObject:object1];
    //

    // We can only set the selected identifier once we've mapped an object in the radio group to
    // the given identifier. Attempting to assign an identifier that hasn't been mapped will fire
    // a debug assertion and then clear the selection.
    _radioGroup.selectedIdentifier = RadioGroupOption2;

    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.dataSource = _model;

  // The radio group object implements a subset of the UITableViewDelegate methods and forwards all
  // delegate methods along. This allows us to insert the radio group into the delegate chain and
  // not have to implement any additional delegate methods in our controller.
  //
  // Experiment:
  // Try removing this line. You will notice that the radio group no longer shows the current
  // selection or allows you to select objects in the group.
  //
  // Note:
  // In order to support actions and radio groups on the same delegate you must chain them in the
  // following order: actions -> radio group -> self.
  //
  // The actions objects enforces the concept that only cells with attached actions should be
  // actionable. The radio group implements its own actions and assigns them afterward. Finally self
  // can override any of this functionality in its implementation of the table view delegate.
  //
  // Implementing the chain in the opposite order would cause the actions object to "disable" the
  // radio group. You can try this for yourself to see the effect.
  self.tableView.delegate = [_actions forwardingTo:[_radioGroup forwardingTo:self]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - User Actions

- (BOOL)didTapObject:(id)object {
  NSLog(@"Did tap object %@", object);
  return YES;
}

#pragma mark - NIRadioGroupDelegate

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  // When the radio group selection changes, this method will be called with the new identifier.
  NSLog(@"Did select radio group option %d", identifier);
}

@end
