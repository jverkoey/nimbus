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

@property (nonatomic, assign) NSInteger elementID;

@end

/**
 * A text input form element.
 *
 * This element is similar to HTML's &lt;input type="text">. It presents a simple text field
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

@property (nonatomic, copy) NSString* placeholderText;
@property (nonatomic, copy) NSString* value;
@property (nonatomic, assign) BOOL isPassword;
@property (nonatomic, assign) id<UITextFieldDelegate> delegate;

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

@property (nonatomic, copy) NSString* labelText;
@property (nonatomic, assign) BOOL value;
@property (nonatomic, assign) id didChangeTarget;
@property (nonatomic, assign) SEL didChangeSelector;

@end

/**
 * A slider form element.
 *
 * This element is a slider that can be embedded in a form. It shows a label with a switch
 * align to the right edge of the row. Label may contain %f format symbol.
 *
 * Bound to NISliderFormElementCell when using the @link TableCellFactory Nimbus cell factory@endlink.
 *
 *      @ingroup TableCellCatalog
 */
@interface NISliderFormElement : NIFormElement

// Designated initializer
+ (id)sliderElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(float)value minimumValue:(float)minimumValue maximumValue:(float)maximumValue didChangeTarget:(id)target didChangeSelector:(SEL)selector;
+ (id)sliderElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(float)value minimumValue:(float)minimumValue maximumValue:(float)maximumValue;

@property (nonatomic, copy) NSString* labelText;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) float minimumValue;
@property (nonatomic, assign) float maximumValue;
@property (nonatomic, NI_WEAK) id didChangeTarget;
@property (nonatomic, assign) SEL didChangeSelector;

@end

/**
 * A segmented control form element.
 *
 * This element presents a segmented control. You can initialize it with a label for the cell, an 
 * array of NSString or UIImage objects acting as segments for the segmented control and a 
 * selectedIndex. The selectedIndex can be -1 if you don't want to preselect a segment.
 *
 * A delegate method (didChangeSelector) will be called on the didChangeTarget once a different 
 * segment is selected. The segmented control will be passed as an argument to this method.
 *
 *      @ingroup TableCellCatalog
 */
@interface NISegmentedControlFormElement : NIFormElement

/**
 * Initializes a segmented control form cell with callback method for value change events.
 *
 *      @param elementID An ID for this element.
 *      @param labelText Text to show on the left side of the form cell.
 *      @param segments An array containing NSString or UIImage objects that will be used as 
 *                      segments of the control. The order in the array is used as order of the 
 *                      segments.
 *      @param selectedIndex Index of the selected segment. -1 if no segment is selected.
 *      @param target Receiver for didChangeSelector calls.
 *      @param selector Method that is called when a segment is selected.
 */
+ (id)segmentedControlElementWithID:(NSInteger)elementID labelText:(NSString *)labelText segments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex didChangeTarget:(id)target didChangeSelector:(SEL)selector ;

/**
 * Initializes a segmented control form cell.
 *
 *      @param elementID An ID for this element.
 *      @param labelText Text to show on the left side of the form cell.
 *      @param segments An array containing NSString or UIImage objects that will be used as 
 *                      segments of the control. The order in the array is used as order of the
 *                      segments.
 *      @param selectedIndex Index of the selected segment. -1 if no segment is selected.
 */
+ (id)segmentedControlElementWithID:(NSInteger)elementID labelText:(NSString *)labelText segments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex;

@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, NI_STRONG) NSArray *segments;
@property (nonatomic, NI_WEAK) id didChangeTarget;
@property (nonatomic, assign) SEL didChangeSelector;

@end

/**
 * A date picker form element.
 *
 * This element shows a date that can be modified.
 *
 * You can initialize it with a labelText showing on the left in the table cell, a date that will 
 * be used to initialize the date picker and a delegate target and method that gets called when a 
 * different date is selected.
 *
 * To change the date picker format you can access the datePicker property of the 
 * NIDatePickerFormElementCell sibling object.
 *
 *      @ingroup TableCellCatalog
 */
@interface NIDatePickerFormElement : NIFormElement

/**
 * Initializes a date picker form element with callback method for value changed events.
 *
 *      @param elementID An ID for this element.
 *      @param labelText Text to show on the left side of the form cell.
 *      @param date Initial date to show in the picker
 *      @param datePickerMode UIDatePickerMode to user for the date picker
 *      @param target Receiver for didChangeSelector calls.
 *      @param selector Method that is called when a segment is selected.
 */
+ (id)datePickerElementWithID:(NSInteger)elementID labelText:(NSString *)labelText date:(NSDate *)date datePickerMode:(UIDatePickerMode)datePickerMode didChangeTarget:(id)target didChangeSelector:(SEL)selector;

/**
 * Initializes a date picker form element with callback method for value changed events.
 *
 *      @param elementID An ID for this element.
 *      @param labelText Text to show on the left side of the form cell.
 *      @param date Initial date to show in the picker
 *      @param datePickerMode UIDatePickerMode to user for the date picker
 */
+ (id)datePickerElementWithID:(NSInteger)elementID labelText:(NSString *)labelText date:(NSDate *)date datePickerMode:(UIDatePickerMode)datePickerMode;

@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, NI_STRONG) NSDate *date;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, NI_WEAK) id didChangeTarget;
@property (nonatomic, assign) SEL didChangeSelector;

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
@property (nonatomic, readonly, NI_STRONG) NIFormElement* element;
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
@property (nonatomic, readonly, NI_STRONG) UITextField* textField;
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
@property (nonatomic, readonly, NI_STRONG) UISwitch* switchControl;
@end

/**
 * The cell sibling to NISliderFormElement.
 *
 * Displays a left-aligned label and a right-aligned slider.
 *
 * @image html NISliderFormElementCellExample1.png "Example of a NISliderFormElementCell."
 *
 *      @ingroup TableCellCatalog
 */
@interface NISliderFormElementCell : NIFormElementCell <UITextFieldDelegate>
@property (nonatomic, readonly, NI_STRONG) UISlider* sliderControl;
@end

@interface NITableViewModel (NIFormElementSearch)

// Finds an element in the static table view model with the given element id.
- (id)elementWithID:(NSInteger)elementID;

@end

/**
 * The cell sibling to NISegmentedControlFormElement.
 *
 * Displays a left-aligned label and a right-aligned segmented control.
 *
 *      @ingroup TableCellCatalog
 */
@interface NISegmentedControlFormElementCell : NIFormElementCell
@property (nonatomic, readonly, NI_STRONG) UISegmentedControl *segmentedControl;
@end

/**
 * The cell sibling to NIDatePickerFormElement
 *
 * Displays a left-aligned label and a right-aligned date.
 *
 *      @ingroup TableCellCatalog
 */
@interface NIDatePickerFormElementCell : NIFormElementCell <UITextFieldDelegate>
@property (nonatomic, readonly, NI_STRONG) UITextField *dateField;
@property (nonatomic, readonly, NI_STRONG) UIDatePicker *datePicker;
@end

