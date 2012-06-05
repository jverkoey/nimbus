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

#import "NIPreprocessorMacros.h" // For __NI_DEPRECATED_METHOD

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
@interface NIFormElement : NSObject <NICellObject>

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
 * Bound to NITextInputFormElementCell when using the @link TableCellFactory Nimbus cell factory@endlink.
 *
 *      @ingroup TableCellCatalog
 */
@interface NITextInputFormElement : NIFormElement

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

/**
 * A switch form element.
 *
 * This element is similar to the Settings app's switch fields. It shows a label with a switch
 * align to the right edge of the row.
 *
 * Bound to NISwitchFormElementCell when using the @link TableCellFactory Nimbus cell factory@endlink.
 *
 *      @ingroup TableCellCatalog
 */
@interface NISwitchFormElement : NIFormElement

// Designated initializer
+ (id)switchElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(BOOL)value didChangeTarget:(id)target didChangeSelector:(SEL)selector;
+ (id)switchElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(BOOL)value;

@property (nonatomic, readwrite, copy) NSString* labelText;
@property (nonatomic, readwrite, assign) BOOL value;
@property (nonatomic, readwrite, assign) id didChangeTarget;
@property (nonatomic, readwrite, assign) SEL didChangeSelector;

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
@interface NIFormElementCell : UITableViewCell <NICell>
@property (nonatomic, readonly, retain) NIFormElement* element;
@end

/**
 * The cell sibling to NITextInputFormElement.
 *
 * Displays a simple text field that fills the entire content view.
 *
 * @image html NITextInputCellExample1.png "Example of a NITextInputFormElementCell."
 *
 *      @ingroup TableCellCatalog
 */
@interface NITextInputFormElementCell : NIFormElementCell <UITextFieldDelegate>
@property (nonatomic, readonly, retain) UITextField* textField;
@end

/**
 * The cell sibling to NISwitchFormElement.
 *
 * Displays a left-aligned label and a right-aligned switch.
 *
 * @image html NISwitchFormElementCellExample1.png "Example of a NISwitchFormElementCell."
 *
 *      @ingroup TableCellCatalog
 */
@interface NISwitchFormElementCell : NIFormElementCell <UITextFieldDelegate>
@property (nonatomic, readonly, retain) UISwitch* switchControl;
@end

@interface NITableViewModel (NIFormElementSearch)

// Finds an element in the static table view model with the given element id.
- (id)elementWithID:(NSInteger)elementID;

@end
