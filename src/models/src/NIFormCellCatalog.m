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

#import "NIFormCellCatalog.h"

#import "NITableViewModel+Private.h"

#import "NimbusCore.h"
#import <objc/message.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static const CGFloat kSwitchLeftMargin = 10;
static const CGFloat kImageViewRightMargin = 10;
static const CGFloat kSegmentedControlMargin = 5;
static const CGFloat kDatePickerTextFieldRightMargin = 5;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFormElement

@synthesize elementID = _elementID;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)elementWithID:(NSInteger)elementID {
  NIFormElement* element = [[self alloc] init];
  element.elementID = elementID;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  // You must implement cellClass in your subclass of this object.
  NIDASSERT(NO);
  return nil;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITextInputFormElement

@synthesize placeholderText = _placeholderText;
@synthesize value = _value;
@synthesize isPassword = _isPassword;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)textInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate {
  NITextInputFormElement* element = [super elementWithID:elementID];
  element.placeholderText = placeholderText;
  element.value = value;
  element.delegate = delegate;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)textInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value {
  return [self textInputElementWithID:elementID placeholderText:placeholderText value:value delegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)passwordInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate {
  NITextInputFormElement* element = [self textInputElementWithID:elementID placeholderText:placeholderText value:value delegate:delegate];
  element.isPassword = YES;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)passwordInputElementWithID:(NSInteger)elementID placeholderText:(NSString *)placeholderText value:(NSString *)value {
  return [self passwordInputElementWithID:elementID placeholderText:placeholderText value:value delegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  return [NITextInputFormElementCell class];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISwitchFormElement

@synthesize labelText = _labelText;
@synthesize value = _value;
@synthesize didChangeTarget = _didChangeTarget;
@synthesize didChangeSelector = _didChangeSelector;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)switchElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(BOOL)value didChangeTarget:(id)target didChangeSelector:(SEL)selector {
  NISwitchFormElement* element = [super elementWithID:elementID];
  element.labelText = labelText;
  element.value = value;
  element.didChangeTarget = target;
  element.didChangeSelector = selector;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)switchElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(BOOL)value {
  return [self switchElementWithID:elementID labelText:labelText value:value didChangeTarget:nil didChangeSelector:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  return [NISwitchFormElementCell class];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISliderFormElement

@synthesize labelText = _labelText;
@synthesize value = _value;
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize didChangeTarget = _didChangeTarget;
@synthesize didChangeSelector = _didChangeSelector;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)sliderElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(float)value minimumValue:(float)minimumValue maximumValue:(float)maximumValue didChangeTarget:(id)target didChangeSelector:(SEL)selector {
  NISliderFormElement* element = [super elementWithID:elementID];
  element.labelText = labelText;
  element.value = value;
  element.minimumValue = minimumValue;
  element.maximumValue = maximumValue;
  element.didChangeTarget = target;
  element.didChangeSelector = selector;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)sliderElementWithID:(NSInteger)elementID labelText:(NSString *)labelText value:(float)value minimumValue:(float)minimumValue maximumValue:(float)maximumValue {
  return [self sliderElementWithID:elementID labelText:labelText value:value minimumValue:minimumValue maximumValue:maximumValue didChangeTarget:nil didChangeSelector:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  return [NISliderFormElementCell class];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISegmentedControlFormElement

@synthesize labelText = _labelText;
@synthesize selectedIndex = _selectedIndex;
@synthesize segments = _segments;
@synthesize didChangeTarget = _didChangeTarget;
@synthesize didChangeSelector = _didChangeSelector;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)segmentedControlElementWithID:(NSInteger)elementID labelText:(NSString *)labelText segments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex didChangeTarget:(id)target didChangeSelector:(SEL)selector {
    NISegmentedControlFormElement *element = [super elementWithID:elementID];
    element.labelText = labelText;
    element.selectedIndex = selectedIndex;
    element.segments = segments;
    element.didChangeTarget = target;
    element.didChangeSelector = selector;
    return element;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)segmentedControlElementWithID:(NSInteger)elementID labelText:(NSString *)labelText segments:(NSArray *)segments selectedIndex:(NSInteger)selectedIndex {
    return [self segmentedControlElementWithID:elementID labelText:labelText segments:segments selectedIndex:selectedIndex didChangeTarget:nil didChangeSelector:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
    return [NISegmentedControlFormElementCell class];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIDatePickerFormElement

@synthesize labelText = _labelText;
@synthesize date = _date;
@synthesize datePickerMode = _datePickerMode;
@synthesize didChangeTarget = _didChangeTarget;
@synthesize didChangeSelector = _didChangeSelector;

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)datePickerElementWithID:(NSInteger)elementID labelText:(NSString *)labelText date:(NSDate *)date datePickerMode:(UIDatePickerMode)datePickerMode didChangeTarget:(id)target didChangeSelector:(SEL)selector {
    NIDatePickerFormElement *element = [super elementWithID:elementID];
    element.labelText = labelText;
    element.date = date;
    element.datePickerMode = datePickerMode;
    element.didChangeTarget = target;
    element.didChangeSelector = selector;
    return element;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)datePickerElementWithID:(NSInteger)elementID labelText:(NSString *)labelText date:(NSDate *)date datePickerMode:(UIDatePickerMode)datePickerMode {
    return [self datePickerElementWithID:elementID labelText:labelText date:date datePickerMode:datePickerMode didChangeTarget:nil didChangeSelector:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
    return [NIDatePickerFormElementCell class];
}

@end
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Form Element Cells


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFormElementCell

@synthesize element = _element;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.textLabel setAdjustsFontSizeToFitWidth:YES];
        if ([self.textLabel respondsToSelector:@selector(minimumScaleFactor)]) {
          self.textLabel.minimumScaleFactor = 0.5;
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
          [self.textLabel setMinimumFontSize:10.0f];
#endif
        }
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];
  
  _element = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if (_element != object) {
    _element = object;

    self.tag = _element.elementID;

    return YES;
  }

  return NO;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITextInputFormElementCell

@synthesize textField = _textField;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _textField = [[UITextField alloc] init];
    [_textField setTag:self.element.elementID];
    [_textField setAdjustsFontSizeToFitWidth:YES];
    [_textField setMinimumFontSize:10.0f];
    [_textField addTarget:self action:@selector(textFieldDidChangeValue) forControlEvents:UIControlEventAllEditingEvents];
    [self.contentView addSubview:_textField];

    [self.textLabel removeFromSuperview];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  _textField.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, NICellContentPadding());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  _textField.placeholder = nil;
  _textField.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NITextInputFormElement *)textInputElement {
  if ([super shouldUpdateCellWithObject:textInputElement]) {
    _textField.placeholder = textInputElement.placeholderText;
    _textField.text = textInputElement.value;
    _textField.delegate = textInputElement.delegate;
    _textField.secureTextEntry = textInputElement.isPassword;

    _textField.tag = self.tag;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidChangeValue {
  NITextInputFormElement* textInputElement = (NITextInputFormElement *)self.element;
  textInputElement.value = _textField.text;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISwitchFormElementCell

@synthesize switchControl = _switchControl;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _switchControl = [[UISwitch alloc] init];
    [_switchControl addTarget:self action:@selector(switchDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switchControl];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  UIEdgeInsets contentPadding = NICellContentPadding();
  CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.frame, contentPadding);

  [_switchControl sizeToFit];
  CGRect frame = _switchControl.frame;
  frame.origin.y = floorf((self.contentView.frame.size.height - frame.size.height) / 2);
  frame.origin.x = self.contentView.frame.size.width - frame.size.width - frame.origin.y;
  _switchControl.frame = frame;

  frame = self.textLabel.frame;
  CGFloat leftEdge = 0;
  // Take into account the size of the image view.
  if (nil != self.imageView.image) {
    leftEdge = self.imageView.frame.size.width + kImageViewRightMargin;
  }
  frame.size.width = (self.contentView.frame.size.width
                      - contentFrame.origin.x
                      - _switchControl.frame.size.width
                      - _switchControl.frame.origin.y
                      - kSwitchLeftMargin
                      - leftEdge);
  self.textLabel.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.textLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NISwitchFormElement *)switchElement {
  if ([super shouldUpdateCellWithObject:switchElement]) {
    _switchControl.on = switchElement.value;
    self.textLabel.text = switchElement.labelText;

    _switchControl.tag = self.tag;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)switchDidChangeValue {
  NISwitchFormElement* switchElement = (NISwitchFormElement *)self.element;
  switchElement.value = _switchControl.on;

  if (nil != switchElement.didChangeSelector && nil != switchElement.didChangeTarget
      && [switchElement.didChangeTarget respondsToSelector:switchElement.didChangeSelector]) {
    
    // This throws a warning a seclectors that the compiler do not know about cannot be
    // memory managed by ARC
    //[switchElement.didChangeTarget performSelector: switchElement.didChangeSelector
    //                                    withObject: _switchControl];
    
    // The following is a workaround to supress the warning and requires <objc/message.h>
    objc_msgSend(switchElement.didChangeTarget, 
                 switchElement.didChangeSelector, _switchControl);
  }
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISliderFormElementCell

@synthesize sliderControl = _sliderControl;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _sliderControl = [[UISlider alloc] init];
    [_sliderControl addTarget:self action:@selector(sliderDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_sliderControl];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  UIEdgeInsets contentPadding = NICellContentPadding();
  CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.frame, contentPadding);
  CGFloat labelWidth = contentFrame.size.width * 0.5f;

  CGRect frame = self.textLabel.frame;
  frame.size.width = labelWidth;
  self.textLabel.frame = frame;

  static const CGFloat kSliderLeftMargin = 8;
  [_sliderControl sizeToFit];
  frame = _sliderControl.frame;
  frame.origin.y = floorf((self.contentView.frame.size.height - frame.size.height) / 2);
  frame.origin.x = self.textLabel.frame.origin.x + self.textLabel.frame.size.width + kSliderLeftMargin;
  frame.size.width = contentFrame.size.width - frame.origin.x;
  _sliderControl.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.textLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NISliderFormElement *)sliderElement {
  if ([super shouldUpdateCellWithObject:sliderElement]) {
    _sliderControl.minimumValue = sliderElement.minimumValue;
    _sliderControl.maximumValue = sliderElement.maximumValue;
    _sliderControl.value = sliderElement.value;
    self.textLabel.text = sliderElement.labelText;

    _sliderControl.tag = self.tag;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sliderDidChangeValue {
  NISliderFormElement* sliderElement = (NISliderFormElement *)self.element;
  sliderElement.value = _sliderControl.value;

  if (nil != sliderElement.didChangeSelector && nil != sliderElement.didChangeTarget
      && [sliderElement.didChangeTarget respondsToSelector:sliderElement.didChangeSelector]) {

    // This throws a warning a seclectors that the compiler do not know about cannot be
    // memory managed by ARC
    //[sliderElement.didChangeTarget performSelector:sliderElement.didChangeSelector
    //                                    withObject:_sliderControl];

    // The following is a workaround to supress the warning and requires <objc/message.h>
    objc_msgSend(sliderElement.didChangeTarget, 
                 sliderElement.didChangeSelector, _sliderControl);
  }
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISegmentedControlFormElementCell

@synthesize segmentedControl = _segmentedControl;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _segmentedControl = [[UISegmentedControl alloc] init];
    [_segmentedControl addTarget:self action:@selector(selectedSegmentDidChangeValue) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.segmentedControl];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  UIEdgeInsets contentPadding = NICellContentPadding();
  CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.frame, contentPadding);

  [_segmentedControl sizeToFit];
  CGRect frame = _segmentedControl.frame;
  frame.size.height = self.contentView.frame.size.height - (2 * kSegmentedControlMargin);
  frame.origin.y = floorf((self.contentView.frame.size.height - frame.size.height) / 2);
  frame.origin.x = self.contentView.frame.size.width - frame.size.width - kSegmentedControlMargin;
  _segmentedControl.frame = frame;

  frame = self.textLabel.frame;
  CGFloat leftEdge = 0;
  // Take into account the size of the image view.
  if (nil != self.imageView.image) {
    leftEdge = self.imageView.frame.size.width + kImageViewRightMargin;
  }
  frame.size.width = (self.contentView.frame.size.width
                      - contentFrame.origin.x
                      - _segmentedControl.frame.size.width
                      - kSegmentedControlMargin
                      - kSwitchLeftMargin
                      - leftEdge);
  self.textLabel.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.textLabel.text = nil;
  [self.segmentedControl removeAllSegments];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NISegmentedControlFormElement *)segmentedControlElement {
  if ([super shouldUpdateCellWithObject:segmentedControlElement]) {
    self.textLabel.text = segmentedControlElement.labelText;
    [segmentedControlElement.segments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if ([obj isKindOfClass:[NSString class]]) {
        [_segmentedControl insertSegmentWithTitle:obj atIndex:idx animated:NO];

      } else if ([obj isKindOfClass:[UIImage class]]) {
        [_segmentedControl insertSegmentWithImage:obj atIndex:idx animated:NO];
      }
    }];
    _segmentedControl.tag = self.tag;
    _segmentedControl.selectedSegmentIndex = segmentedControlElement.selectedIndex;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectedSegmentDidChangeValue {
  NISegmentedControlFormElement *segmentedControlElement = (NISegmentedControlFormElement *)self.element;
  segmentedControlElement.selectedIndex = self.segmentedControl.selectedSegmentIndex;

  if (nil != segmentedControlElement.didChangeSelector && nil != segmentedControlElement.didChangeTarget
      && [segmentedControlElement.didChangeTarget respondsToSelector:segmentedControlElement.didChangeSelector]) {

    // [segmentedControlElement.didChangeTarget performSelector:segmentedControlElement.didChangeSelector
    //                                               withObject:_segmentedControl];

    // The following is a workaround to supress the warning and requires <objc/message.h>
    objc_msgSend(segmentedControlElement.didChangeTarget, 
                 segmentedControlElement.didChangeSelector, _segmentedControl);
  }
}

@end


@interface NIDatePickerFormElementCell()
@property (nonatomic, readwrite, NI_STRONG) UITextField* dumbDateField;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIDatePickerFormElementCell

@synthesize dumbDateField = _dumbDateField;
@synthesize dateField = _dateField;
@synthesize datePicker = _datePicker;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _datePicker = [[UIDatePicker alloc] init];
    [_datePicker addTarget:self 
                    action:@selector(selectedDateDidChange) 
          forControlEvents:UIControlEventValueChanged];

    _dateField = [[UITextField alloc] init];
    _dateField.delegate = self;
    _dateField.font = [UIFont systemFontOfSize:16.0f];
    _dateField.minimumFontSize = 10.0f;
    _dateField.backgroundColor = [UIColor clearColor];
    _dateField.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
    _dateField.textAlignment = UITextAlignmentRight;
#else
    _dateField.textAlignment = NSTextAlignmentRight;
#endif
    _dateField.inputView = _datePicker;
    [self.contentView addSubview:_dateField];

    _dumbDateField = [[UITextField alloc] init];
    _dumbDateField.hidden = YES;
    _dumbDateField.enabled = NO;
    [self.contentView addSubview:_dumbDateField];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  
  UIEdgeInsets contentPadding = NICellContentPadding();
  CGRect contentFrame = UIEdgeInsetsInsetRect(self.contentView.frame, contentPadding);
  
  [_dateField sizeToFit];
  CGRect frame = _dateField.frame;
  frame.origin.y = floorf((self.contentView.frame.size.height - frame.size.height) / 2);
  frame.origin.x = self.contentView.frame.size.width - frame.size.width - kDatePickerTextFieldRightMargin;
  _dateField.frame = frame;
  self.dumbDateField.frame = _dateField.frame;
  
  frame = self.textLabel.frame;
  CGFloat leftEdge = 0;
  // Take into account the size of the image view.
  if (nil != self.imageView.image) {
    leftEdge = self.imageView.frame.size.width + kImageViewRightMargin;
  }
  frame.size.width = (self.contentView.frame.size.width
                      - contentFrame.origin.x
                      - _dateField.frame.size.width
                      - _dateField.frame.origin.y
                      - leftEdge);
  self.textLabel.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];
  
  self.textLabel.text = nil;
  _dateField.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NIDatePickerFormElement *)datePickerElement {
  if ([super shouldUpdateCellWithObject:datePickerElement]) {
    self.textLabel.text = datePickerElement.labelText;
    self.datePicker.datePickerMode = datePickerElement.datePickerMode;
    self.datePicker.date = datePickerElement.date;
    
    switch (self.datePicker.datePickerMode) {
      case UIDatePickerModeDate:
        self.dateField.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date 
                                                             dateStyle:NSDateFormatterShortStyle 
                                                             timeStyle:NSDateFormatterNoStyle];
        break;
        
      case UIDatePickerModeTime:
        self.dateField.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date 
                                                             dateStyle:NSDateFormatterNoStyle 
                                                             timeStyle:NSDateFormatterShortStyle];
        break;
        
      case UIDatePickerModeCountDownTimer:
        if (self.datePicker.countDownDuration == 0) {
          self.dateField.text = NSLocalizedString(@"0 minutes", @"0 minutes");
        } else {
          int hours = (int)(self.datePicker.countDownDuration / 3600);
          int minutes = (int)((self.datePicker.countDownDuration - hours * 3600) / 60);
          
          self.dateField.text = [NSString stringWithFormat:
                                 NSLocalizedString(@"%d hours, %d min", 
                                                   @"datepicker countdown hours and minutes"), 
                                 hours, 
                                 minutes];
        }
        break;
        
      case UIDatePickerModeDateAndTime:
      default:
        self.dateField.text = [NSDateFormatter localizedStringFromDate:self.datePicker.date 
                                                             dateStyle:NSDateFormatterShortStyle 
                                                             timeStyle:NSDateFormatterShortStyle];
        break;
    }

    self.dumbDateField.text = self.dateField.text;
    
    _dateField.tag = self.tag;
    
    _datePicker.date = datePickerElement.date;
    _datePicker.tag = self.tag;
    
    [self setNeedsLayout];
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)selectedDateDidChange {
  switch (self.datePicker.datePickerMode) {
    case UIDatePickerModeDate:
      self.dateField.text = [NSDateFormatter localizedStringFromDate:_datePicker.date 
                                                           dateStyle:NSDateFormatterShortStyle 
                                                           timeStyle:NSDateFormatterNoStyle];
      break;
      
    case UIDatePickerModeTime:
      self.dateField.text = [NSDateFormatter localizedStringFromDate:_datePicker.date 
                                                           dateStyle:NSDateFormatterNoStyle 
                                                           timeStyle:NSDateFormatterShortStyle];
      break;
      
    case UIDatePickerModeCountDownTimer:
      if (self.datePicker.countDownDuration == 0) {
        self.dateField.text = NSLocalizedString(@"0 minutes", @"0 minutes");
      } else {
        int hours = (int)(self.datePicker.countDownDuration / 3600);
        int minutes = (int)((self.datePicker.countDownDuration - hours * 3600) / 60);
        
        self.dateField.text = [NSString stringWithFormat:
                               NSLocalizedString(@"%d hours, %d min", 
                                                 @"datepicker countdown hours and minutes"), 
                               hours, 
                               minutes];
      }
      break;
      
    case UIDatePickerModeDateAndTime:
    default:
      self.dateField.text = [NSDateFormatter localizedStringFromDate:_datePicker.date 
                                                           dateStyle:NSDateFormatterShortStyle 
                                                           timeStyle:NSDateFormatterShortStyle];
      break;
  }

  self.dumbDateField.text = self.dateField.text;

  NIDatePickerFormElement *datePickerElement = (NIDatePickerFormElement *)self.element;
  datePickerElement.date = _datePicker.date;
  
  if (nil != datePickerElement.didChangeSelector && nil != datePickerElement.didChangeTarget
      && [datePickerElement.didChangeTarget respondsToSelector:datePickerElement.didChangeSelector]) {
    // [datePickerElement.didChangeTarget performSelector:datePickerElement.didChangeSelector withObject:self.datePicker];

    // The following is a workaround to supress the warning and requires <objc/message.h>
    objc_msgSend(datePickerElement.didChangeTarget, 
                 datePickerElement.didChangeSelector, _datePicker);

  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  self.dumbDateField.delegate = self.dateField.delegate;
  self.dumbDateField.font = self.dateField.font;
  self.dumbDateField.minimumFontSize = self.dateField.minimumFontSize;
  self.dumbDateField.backgroundColor = self.dateField.backgroundColor;
  self.dumbDateField.adjustsFontSizeToFitWidth = self.dateField.adjustsFontSizeToFitWidth;
  self.dumbDateField.textAlignment = self.dateField.textAlignment;
  self.dumbDateField.textColor = self.dateField.textColor;

  textField.hidden = YES;
  self.dumbDateField.hidden = NO;
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textFieldDidEndEditing:(UITextField *)textField {
  textField.hidden = NO;
  self.dumbDateField.hidden = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  return NO;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModel (NIFormElementSearch)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)elementWithID:(NSInteger)elementID {
  for (NITableViewModelSection* section in self.sections) {
    for (NIFormElement* element in section.rows) {
      if (![element isKindOfClass:[NIFormElement class]]) {
        continue;
      }
      if (element.elementID == elementID) {
        return element;
      }
    }
  }
  return nil;
}


@end
