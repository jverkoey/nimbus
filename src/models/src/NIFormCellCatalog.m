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

static const CGFloat kSwitchLeftMargin = 10;
static const CGFloat kImageViewRightMargin = 10;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFormElement

@synthesize elementID = _elementID;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)elementWithID:(NSInteger)elementID {
  NIFormElement* element = [[[self alloc] init] autorelease];
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
- (void)dealloc {
  NI_RELEASE_SAFELY(_placeholderText);
  NI_RELEASE_SAFELY(_value);

  [super dealloc];
}


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
- (void)dealloc {
  NI_RELEASE_SAFELY(_labelText);

  [super dealloc];
}


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
#pragma mark -
#pragma mark Form Element Cells


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFormElementCell

@synthesize element = _element;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_element);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];
  
  NI_RELEASE_SAFELY(_element);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if (_element != object) {
    [_element release];
    _element = [object retain];

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
- (void)dealloc {
  NI_RELEASE_SAFELY(_textField);

  [super dealloc];
}


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
- (void)dealloc {
  NI_RELEASE_SAFELY(_switchControl);
  
  [super dealloc];
}


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
    [switchElement.didChangeTarget performSelector: switchElement.didChangeSelector
                                        withObject: _switchControl];
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
