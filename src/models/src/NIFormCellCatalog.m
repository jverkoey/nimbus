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
  return [NITextInputCell class];
}

@end


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
@implementation NITextInputCell

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
