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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FormCellCatalogTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  // The model is a retained object in this controller, so we must release it when the controller
  // is deallocated.
  [_model release]; _model = nil;
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = NSLocalizedString(@"Form Cells", @"Controller Title: Form Cells");

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"NITextInputFormElement",
     [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:nil],
     [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:@"Initial value"],
     [NITextInputFormElement textInputElementWithID:1 placeholderText:nil value:@"Disabled input field" delegate:self],
     [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:nil],
     [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:@"Password"],

     @"NISwitchFormElement",
     [NISwitchFormElement switchElementWithID:0 labelText:@"Switch" value:NO],
     [NISwitchFormElement switchElementWithID:0 labelText:@"Switch with a really long label that will be cut off" value:YES],
     nil];

    // This controller creates the table view cells.
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
      textInputCell.textField.textColor = nil;
    }
  }
}


@end
