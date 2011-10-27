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

#import "NimbusCore.h"
#import <objc/message.h>


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
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIButtonFormElement

@synthesize labelText = _labelText;
@synthesize tappedTarget = _tappedTarget;
@synthesize tappedSelector = _tappedSelector;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)buttonElementWithID:(NSInteger)elementID labelText:(NSString *)labelText tappedTarget:(id)target tappedSelector:(SEL)selector {
  NIButtonFormElement* element = [super elementWithID:elementID];
  element.labelText = labelText;
  element.tappedTarget = target;
  element.tappedSelector = selector;
  return element;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  return [NIButtonFormElementCell class];
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
    [_textField addTarget:self action:@selector(textFieldDidChangeValue) forControlEvents:UIControlEventAllEditingEvents];
    [self.contentView addSubview:_textField];

    [self.textLabel removeFromSuperview];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  _textField.frame = NIRectInset(self.contentView.bounds, NICellContentPadding());
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
  CGRect contentFrame = NIRectInset(self.contentView.frame, contentPadding);

  [_switchControl sizeToFit];
  CGRect frame = _switchControl.frame;
  frame.origin.y = ceilf((self.contentView.frame.size.height - frame.size.height) / 2);
  frame.origin.x = self.contentView.frame.size.width - frame.size.width - frame.origin.y;
  _switchControl.frame = frame;

  static const CGFloat kSwitchLeftMargin = 10;
  frame = self.textLabel.frame;
  frame.size.width = self.contentView.frame.size.width - contentFrame.origin.x - _switchControl.frame.size.width - _switchControl.frame.origin.y - kSwitchLeftMargin;
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
    
    // The following is a workarround to supress the warning and requires <objc/message.h>
    objc_msgSend(switchElement.didChangeTarget, 
                 switchElement.didChangeSelector, _switchControl);
  }
}

@end


@class NITableViewModelSection;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIButtonFormElementCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.textLabel.text = @"";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if ([super shouldUpdateCellWithObject:object]) {
    NIButtonFormElement* buttonElement = (NIButtonFormElement *)self.element;
    self.textLabel.text = buttonElement.labelText;

    [self setNeedsLayout];
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)buttonWasTapped:(id)sender {
  NIButtonFormElement* buttonElement = (NIButtonFormElement *)self.element;
  
  if (nil != buttonElement.tappedSelector && nil != buttonElement.tappedTarget
      && [buttonElement.tappedTarget respondsToSelector:buttonElement.tappedSelector]) {
    //[buttonElement.tappedTarget performSelector:buttonElement.tappedSelector];
    objc_msgSend(buttonElement.tappedTarget, buttonElement.tappedSelector, nil);
  }
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewModel (NIFormElementSearch)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)elementWithID:(NSInteger)elementID {
  for (NITableViewModelSection* section in _sections) {
    NSArray* rows = [section performSelector:@selector(rows)];
    for (NIFormElement* element in rows) {
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
