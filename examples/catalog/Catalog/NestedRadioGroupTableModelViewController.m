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

#import "NestedRadioGroupTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of using a nested radio group with a table view.
//
// You will find the following Nimbus features used:
//
// [models]
// NIRadioGroup
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

@interface NestedRadioGroupTableModelViewController () <NIRadioGroupDelegate>
@property (nonatomic, retain) NITableViewModel* model;
@property (nonatomic, retain) NIRadioGroup* radioGroup;
@end

@implementation NestedRadioGroupTableModelViewController


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Nested Radio Group";

    _radioGroup = [[NIRadioGroup alloc] initWithController:self];
    _radioGroup.delegate = self;

    // The title that will be displayed in the radio group cell.
    _radioGroup.cellTitle = @"Selection";

    // The title that will be displayed in the nested radio group controller.
    _radioGroup.controllerTitle = @"Make a selection";
    
    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 1"] toIdentifier:RadioGroupOption1];
    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 2"] toIdentifier:RadioGroupOption2];
    [_radioGroup mapObject:[NITitleCellObject objectWithTitle:@"Option 3"] toIdentifier:RadioGroupOption3];

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     // To create a nested radio group we simply add the radio group as an object in the model.
     // NIRadioGroup implements the NICellObject protocol which allows us to do this.
     _radioGroup,
     nil];

    _radioGroup.selectedIdentifier = RadioGroupOption2;

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
  // When the radio group selection changes, this method will be called with the new identifier.
  NSLog(@"Did select radio group option %zd", identifier);
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

@end
