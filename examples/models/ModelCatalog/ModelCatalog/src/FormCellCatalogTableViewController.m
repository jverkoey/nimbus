//
// Copyright 2011 Jeff Verkoeyen
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

#import "FormCellCatalogTableViewController.h"

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

@interface FormCellCatalogTableViewController() <UITextFieldDelegate, NIRadioGroupDelegate>
@property (nonatomic, readwrite, retain) NITableViewModel* model;

// A radio group object allows us to easily maintain radio group-style interactions in the table
// view.
@property (nonatomic, readwrite, retain) NIRadioGroup* radioGroup;
@property (nonatomic, readwrite, retain) NIRadioGroup* subRadioGroup;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FormCellCatalogTableViewController

@synthesize model = _model;
@synthesize radioGroup = _radioGroup;
@synthesize subRadioGroup = _subRadioGroup;
@synthesize actions = _actions;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = NSLocalizedString(@"Form Cells", @"Controller Title: Form Cells");

    NISubtitleCellObject* radioObject1 = [NISubtitleCellObject cellWithTitle:@"Radio 1"
                                                                    subtitle:@"First option"];
    NISubtitleCellObject* radioObject2 = [NISubtitleCellObject cellWithTitle:@"Radio 2"
                                                                    subtitle:@"Second option"];
    NISubtitleCellObject* radioObject3 = [NISubtitleCellObject cellWithTitle:@"Radio 3"
                                                                    subtitle:@"Third option"];
    NITitleCellObject* button = [NITitleCellObject cellWithTitle:@"Button with alert"];

    NISubtitleCellObject* subRadioObject1 = [NISubtitleCellObject cellWithTitle:@"Sub Radio 1"
                                                                       subtitle:@"First option"];
    NISubtitleCellObject* subRadioObject2 = [NISubtitleCellObject cellWithTitle:@"Sub Radio 2"
                                                                       subtitle:@"Second option"];
    NISubtitleCellObject* subRadioObject3 = [NISubtitleCellObject cellWithTitle:@"Sub Radio 3"
                                                                       subtitle:@"Third option"];

    _subRadioGroup = [[NIRadioGroup alloc] initWithController:self];
    _subRadioGroup.cellTitle = @"Selection";
    _subRadioGroup.controllerTitle = @"Make a Selection";
    _subRadioGroup.delegate = self;
    [_subRadioGroup mapObject:subRadioObject1 toIdentifier:SubRadioOption1];
    [_subRadioGroup mapObject:subRadioObject2 toIdentifier:SubRadioOption2];
    [_subRadioGroup mapObject:subRadioObject3 toIdentifier:SubRadioOption3];
    _subRadioGroup.selectedIdentifier = SubRadioOption1;

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"Radio Cells",
     radioObject1, radioObject2, radioObject3,
     @"Sub Radio Groups",
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

     @"NIButtonFormElement",
     button,
     nil];

    _radioGroup = [[NIRadioGroup alloc] init];
    _radioGroup.delegate = self;
    [_radioGroup mapObject:radioObject1 toIdentifier:RadioOption1];
    [_radioGroup mapObject:radioObject2 toIdentifier:RadioOption2];
    [_radioGroup mapObject:radioObject3 toIdentifier:RadioOption3];
    _radioGroup.selectedIdentifier = RadioOption1;

    _actions = [[NITableViewActions alloc] initWithController:self];
    [_actions attachTapAction:^(id object, UIViewController *controller) {
      UIAlertView* alertView =
          [[[UIAlertView alloc] initWithTitle:@"This is an alert!"
                                     message:@"Don't panic."
                                    delegate:nil
                           cancelButtonTitle:@"Neat!"
                           otherButtonTitles:nil] autorelease];
      [alertView show];
      return YES;
    } toObject:button];

    // We let the Nimbus cell factory create the cells.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  // Only assign the table view's data source after the view has loaded.
  // You must be careful when you call self.tableView in general because it will call loadView
  // if the view has not been loaded yet. You do not need to clear the data source when the
  // view is unloaded (more importantly: you shouldn't, due to the reason just outlined
  // regarding loadView).
  self.tableView.dataSource = _model;

  self.tableView.delegate = [self.radioGroup forwardingTo:
                             [self.subRadioGroup forwardingTo:
                              [self.actions forwardingTo:self.tableView.delegate]]];

  // When including text editing cells in table views you should provide a means for the user to
  // stop editing the control. To do this we add a gesture recognizer to the table view.
  UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didTapTableView)];
  // We still want the table view to be able to process touch events when we tap.
  tap.cancelsTouchesInView = NO;
  [self.tableView addGestureRecognizer:tap];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (textField.tag == 1) {
    return NO;
  }
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
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



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIRadioGroupDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
  if (radioGroup == self.radioGroup) {
    NSLog(@"Radio group selection: %d", identifier);
  } else if (radioGroup == self.subRadioGroup) {
    NSLog(@"Sub radio group selection: %d", identifier);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Gesture Recognizers


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapTableView {
  [self.view endEditing:YES];
}

@end
