//
// Copyright 2009-2011 Facebook
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

#import "NIMessageRecipientField.h"

// UI
#import "NIPickerTextField.h"
#import "NIMessageController.h"

#import "NimbusCore.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMessageRecipientField

@synthesize recipients = _recipients;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
    return [NSString stringWithFormat:@"%@ %@", _title, _recipients];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIMessageField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIPickerTextField*)createViewForController:(NIMessageController*)controller {
    NIPickerTextField* textField = [[NIPickerTextField alloc] init];
    textField.dataSource = (NITableViewSearchModel*)controller.dataSource;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.rightViewMode = UITextFieldViewModeAlways;
    
    if (controller.showsRecipientPicker) {
        UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [addButton addTarget:controller action:@selector(showRecipientPicker)
            forControlEvents:UIControlEventTouchUpInside];
        textField.rightView = addButton;
    }
    
    return textField;
}


@end
