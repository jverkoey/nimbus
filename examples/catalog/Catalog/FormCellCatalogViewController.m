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

#import "FormCellCatalogViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a catalog of all of Nimbus' form cells. This example does not go into details on the
// individual cells. It is meant to provide a quick overview of the cells.
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

// This enumeration is used in the radio group mapping.
typedef enum {
  RadioOption1,
  RadioOption2,
  RadioOption3,
} RadioOptions;

// This enumeration is used in the sub radio group mapping.
typedef enum {
  SubRadioOption1,
  SubRadioOption2,
  SubRadioOption3,
} SubRadioOptions;

@interface FormCellCatalogViewController () <UITextFieldDelegate, NIRadioGroupDelegate>
@property (nonatomic, retain) NITableViewModel* model;

// A radio group object allows us to easily maintain radio group-style interactions in a table view.
@property (nonatomic, retain) NIRadioGroup* radioGroup;

// Each radio group object maintains a specific set of table objects, so in order to have multiple
// radio groups you need to instantiate multiple radio group objects.
@property (nonatomic, retain) NIRadioGroup* subRadioGroup;
@end

@implementation FormCellCatalogViewController


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Form Cell Catalog";
    
    _radioGroup = [[NIRadioGroup alloc] init];
    _radioGroup.delegate = self;
    
    _subRadioGroup = [[NIRadioGroup alloc] initWithController:self];
    _subRadioGroup.delegate = self;
    _subRadioGroup.cellTitle = @"Selection";
    _subRadioGroup.controllerTitle = @"Make a Selection";
    
    [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 1"
                                                           subtitle:@"First option"]
                 toIdentifier:SubRadioOption1];
    [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 2"
                                                           subtitle:@"Second option"]
                 toIdentifier:SubRadioOption2];
    [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 3"
                                                           subtitle:@"Third option"]
                 toIdentifier:SubRadioOption3];
    
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"Radio Group",
     [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 1"
                                                         subtitle:@"First option"]
               toIdentifier:RadioOption1],
     [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 2"
                                                         subtitle:@"Second option"]
               toIdentifier:RadioOption2],
     [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 3"
                                                         subtitle:@"Third option"]
               toIdentifier:RadioOption3],
     @"Radio Group Controller",
     _subRadioGroup,
     
     @"NITextInputFormElement",
     [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:nil],
     [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:@"Initial value"],
     [NITextInputFormElement textInputElementWithID:1 placeholderText:nil value:@"Disabled input field" delegate:self],
     [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:nil],
     [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:@"Password"],
     
     @"NISwitchFormElement",
     [NISwitchFormElement switchElementWithID:0 labelText:@"Switch" value:NO],
     [NISwitchFormElement switchElementWithID:0 labelText:@"Switch with a really long label that will be cut off" value:YES],
     [NISwitchFormElement switchElementWithID:0 labelText:@"Switch with target/selector" value:NO didChangeTarget:self didChangeSelector:@selector(switchChanged:)],

     @"NISliderFormElement",
     [NISliderFormElement sliderElementWithID:0
                                    labelText:@"Slider"
                                        value:45
                                 minimumValue:0
                                 maximumValue:100],
     
     @"NISegmentedControlFormElement",
     [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                        labelText:@"Text segments"
                                                         segments:[NSArray arrayWithObjects:
                                                                   @"one", @"two", nil]
                                                    selectedIndex:0],
     [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                        labelText:@"Image segments"
                                                         segments:[NSArray arrayWithObjects:
                                                                   [UIImage imageNamed:@"star.png"],
                                                                   [UIImage imageNamed:@"circle.png"],
                                                                   nil]
                                                    selectedIndex:-1
                                                  didChangeTarget:self
                                                didChangeSelector:@selector(segmentedControlWithImagesDidChangeValue:)],
     @"NIDatePickerFormElement",
     [NIDatePickerFormElement datePickerElementWithID:0
                                            labelText:@"Date and time"
                                                 date:[NSDate date]
                                       datePickerMode:UIDatePickerModeDateAndTime],
     [NIDatePickerFormElement datePickerElementWithID:0
                                            labelText:@"Date only"
                                                 date:[NSDate date]
                                       datePickerMode:UIDatePickerModeDate],
     [NIDatePickerFormElement datePickerElementWithID:0
                                            labelText:@"Time only"
                                                 date:[NSDate date]
                                       datePickerMode:UIDatePickerModeTime
                                      didChangeTarget:self
                                    didChangeSelector:@selector(datePickerDidChangeValue:)],
     [NIDatePickerFormElement datePickerElementWithID:0
                                            labelText:@"Countdown"
                                                 date:[NSDate date]
                                       datePickerMode:UIDatePickerModeCountDownTimer],
     nil];
    
    self.radioGroup.selectedIdentifier = RadioOption1;
    self.subRadioGroup.selectedIdentifier = SubRadioOption1;
    
    // We let the Nimbus cell factory create the cells.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = _model;
  
  self.tableView.delegate = [self.radioGroup forwardingTo:
                             [self.subRadioGroup forwardingTo:self.tableView.delegate]];
  
  // When including text editing cells in table views you should provide a means for the user to
  // stop editing the control. To do this we add a gesture recognizer to the table view.
  UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];

  // We still want the table view to be able to process touch events when we tap.
  tap.cancelsTouchesInView = NO;

  [self.tableView addGestureRecognizer:tap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

- (void)segmentedControlWithImagesDidChangeValue:(UISegmentedControl *)segmentedControl {
  NIDPRINT(@"Segmented control changed value to index %d", segmentedControl.selectedSegmentIndex);
}

- (void)datePickerDidChangeValue:(UIDatePicker *)picker {
  NIDPRINT(@"Time only date picker changed value to %@",
           [NSDateFormatter localizedStringFromDate:picker.date
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:NSDateFormatterShortStyle]);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField.tag == 1) {
    return NO;
  }
  return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Customize the presentation of certain types of cells.
  if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
    NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
    if (1 == cell.tag) {
      // Make the disabled input field look slightly different.
      textInputCell.textField.textColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];

    } else {
      // We must always handle the else case because cells can be reused.
      textInputCell.textField.textColor = [UIColor blackColor];
    }
  }
}

#pragma mark - NIRadioGroupDelegate

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  if (radioGroup == self.radioGroup) {
    NSLog(@"Radio group selection: %zd", identifier);
  } else if (radioGroup == self.subRadioGroup) {
    NSLog(@"Sub radio group selection: %zd", identifier);
  }
}

- (NSString *)radioGroup:(NIRadioGroup *)radioGroup textForIdentifier:(NSInteger)identifier {
  switch (identifier) {
    case SubRadioOption1:
      return @"Option 1";
    case SubRadioOption2:
      return @"Option 2";
    case SubRadioOption3:
      return @"Option 3";
  }
  return nil;
}

- (void)switchChanged:(UISwitch *)uiSwitch {
    NSLog(@"Switch changed to %@", uiSwitch.on ? @"YES" : @"NO");
}

#pragma mark - Gesture Recognizers

- (void)didTapTableView {
  [self.view endEditing:YES];
}

@end
