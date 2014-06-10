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

#import "ModalRadioGroupTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of customizing the appearance of a radio group controller so that it appears
// modally and making a selection dismisses the controller.
//
// You will find the following Nimbus features used:
//
// [models]
// NIRadioGroup
// NIRadioGroupDelegate
// NITableViewModel
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

@interface ModalRadioGroupTableModelViewController () <NIRadioGroupDelegate>
@property (nonatomic, retain) NITableViewModel* model;
@property (nonatomic, retain) NIRadioGroup* radioGroup;
@end

@implementation ModalRadioGroupTableModelViewController


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Modal Radio Group";

    _radioGroup = [[NIRadioGroup alloc] initWithController:self];
    _radioGroup.delegate = self;

    _radioGroup.cellTitle = @"Selection";
    _radioGroup.controllerTitle = @"Make a selection";

    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 1"] toIdentifier:RadioGroupOption1];
    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 2"] toIdentifier:RadioGroupOption2];
    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 3"] toIdentifier:RadioGroupOption3];
    _radioGroup.selectedIdentifier = RadioGroupOption2;

    NSArray* tableContents = [NSArray arrayWithObject:_radioGroup];
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.radioGroup forwardingTo:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

#pragma mark - NIRadioGroupDelegate

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  NSLog(@"Did select radio group option %zd", identifier);

  // Dismiss the modal view controller that's showing the radio group options.
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)radioGroup:(NIRadioGroup *)radioGroup textForIdentifier:(NSInteger)identifier {
  switch (identifier) {
    case RadioGroupOption1:
      return @"Option 1";
    case RadioGroupOption2:
      return @"Option 2";
    case RadioGroupOption3:
      return @"Option 3";
  }
  return nil;
}

// This method will be called immediately before the radio group controller is presented and gives
// us the opportunity to present the controller ourselves, rather than simply pushing the radio
// group controller onto the current navigation controller stack.
- (BOOL)radioGroup:(NIRadioGroup *)radioGroup radioGroupController:(NIRadioGroupController *)radioGroupController willAppear:(BOOL)animated {
  // We wrap the radio controller in a navigation controller so that it has a navbar when
  // presented.
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:radioGroupController];

  // Present the radio controller modally.
  [self presentViewController:nc animated:YES completion:nil];

  return NO; // Don't let the radio group display the controller; we're displaying it ourselves.
}

@end
