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

#import "NICellFactory.h"

#pragma mark Form Elements

/**
 * A single element of a form with an ID property.
 *
 * Each form element has, at the very least, an element ID property which can be used to
 * differentiate the form elements when change notifications are received. Each element cell
 * will assign the element ID to the tag property of its views.
 *
 *      @ingroup TableCellCatalog
 */
@interface NIFormElement : NSObject <NICellObject> {
@private
  NSInteger _elementId;
}

// Designated initializer
+ (id)elementWithID:(NSInteger)elementID;

@property (nonatomic, readwrite, assign) NSInteger elementID;

@end

/**
 * A text input form element.
 *
 * This element is similar to HTML's <input type="text">. It presents a simple text field
 * control with optional placeholder text. You can assign a delegate to this object that will
 * be assigned to the text field, allowing you to receive text field delegate notifications.
 *
 * Bound to NITextInputCell when using the @link TableCellFactory Nimbus cell factory@endlink.
 *
 *      @ingroup TableCellCatalog
 */
@interface NITextInputFormElement : NIFormElement {
@private
  NSString* _placeholderText;
  NSString* _value;
  BOOL _isPassword;
  id<UITextFieldDelegate> _delegate;
}

// Designated initializer
+ (id)textInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate;
+ (id)textInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value;

+ (id)passwordInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate;
+ (id)passwordInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value;

@property (nonatomic, readwrite, copy) NSString* placeholderText;
@property (nonatomic, readwrite, copy) NSString* value;
@property (nonatomic, readwrite, assign) BOOL isPassword;
@property (nonatomic, readwrite, assign) id<UITextFieldDelegate> delegate;

@end


#pragma mark -
#pragma mark Form Element Cells

/**
 * The base class for form element cells.
 *
 * Doesn't do anything particularly interesting other than retaining the element.
 *
 *      @ingroup TableCellCatalog
 */
@interface NIFormElementCell : UITableViewCell <NICell> {
@private
  NIFormElement* _element;
}
@property (nonatomic, readonly, retain) NIFormElement* element;
@end

/**
 * The cell sibling to NITextInputFormElement.
 *
 * Displays a simple text field that fills the entire content view.
 *
 * @image html NITextInputCellExample1.png "Example of an NITextInputCell."
 *
 *      @ingroup TableCellCatalog
 */
@interface NITextInputCell : NIFormElementCell <UITextFieldDelegate> {
@private
  UITextField* _textField;
}
@property (nonatomic, readonly, retain) UITextField* textField;
@end
