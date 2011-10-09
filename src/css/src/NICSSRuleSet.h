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

#import <Foundation/Foundation.h>

@interface NICSSRuleSet : NSObject {
@private
  NSMutableDictionary* _ruleSet;

  UIColor* _textColor;
  UITextAlignment _textAlignment;
  UIFont* _font;
  UIColor* _textShadowColor;
  CGSize _textShadowOffset;
  UILineBreakMode _lineBreakMode;
  NSInteger _numberOfLines;
  CGFloat _minimumFontSize;
  BOOL _adjustsFontSize;
  UIBaselineAdjustment _baselineAdjustment;
  CGFloat _opacity;

  union {
    struct {
      int TextColor : 1;
      int TextAlignment : 1;
      int Font : 1;
      int TextShadowColor : 1;
      int TextShadowOffset : 1;
      int LineBreakMode : 1;
      int NumberOfLines : 1;
      int MinimumFontSize : 1;
      int AdjustsFontSize : 1;
      int BaselineAdjustment : 1;
      int Opacity : 1;
    } cached;
    int _data;
  } _is;
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (BOOL)hasTextColor;
- (UIColor *)textColor;

- (BOOL)hasTextAlignment;
- (UITextAlignment)textAlignment;

- (BOOL)hasFont;
- (UIFont *)font;

- (BOOL)hasTextShadowColor;
- (UIColor *)textShadowColor;

- (BOOL)hasTextShadowOffset;
- (CGSize)textShadowOffset;

- (BOOL)hasLineBreakMode;
- (UILineBreakMode)lineBreakMode;

- (BOOL)hasNumberOfLines;
- (NSInteger)numberOfLines;

- (BOOL)hasMinimumFontSize;
- (CGFloat)minimumFontSize;

- (BOOL)hasAdjustsFontSize;
- (BOOL)adjustsFontSize;

- (BOOL)hasBaselineAdjustment;
- (UIBaselineAdjustment)baselineAdjustment;

- (BOOL)hasOpacity;
- (CGFloat)opacity;

@end
