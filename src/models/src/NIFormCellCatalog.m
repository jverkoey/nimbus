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

static const CGFloat kSwitchLeftMargin = 10;
static const CGFloat kImageViewRightMargin = 10;

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
#pragma mark -
#pragma mark Form Element Cells


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFormElementCell

@synthesize element = _element;

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
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if ([super shouldUpdateCellWithObject:object]) {
    NITextInputFormElement* textInputElement = (NITextInputFormElement *)self.element;
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
  frame.origin.y = ceilf((self.contentView.frame.size.height - frame.size.height) / 2);
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
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if ([super shouldUpdateCellWithObject:object]) {
    NISwitchFormElement* switchElement = (NISwitchFormElement *)self.element;
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
  CGFloat labelWidth = contentFrame.size.width * 0.5;

  CGRect frame = self.textLabel.frame;
  frame.size.width = labelWidth;
  self.textLabel.frame = frame;

  static const CGFloat kSliderLeftMargin = 8;
  [_sliderControl sizeToFit];
  frame = _sliderControl.frame;
  frame.origin.y = ceilf((self.contentView.frame.size.height - frame.size.height) / 2);
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
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if ([super shouldUpdateCellWithObject:object]) {
    NISliderFormElement* sliderElement = (NISliderFormElement *)self.element;
    _sliderControl.minimumValue = sliderElement.minimumValue;
    _sliderControl.maximumValue = sliderElement.maximumValue;
    _sliderControl.value = sliderElement.value;
    self.textLabel.text = [NSString stringWithFormat:sliderElement.labelText, sliderElement.value];

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
  self.textLabel.text = [NSString stringWithFormat:sliderElement.labelText, sliderElement.value];

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
