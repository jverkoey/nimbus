//
// Copyright 2011 Roger Chapman
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

#import "NSMutableAttributedString+NimbusAttributedLabel.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(NSAttributedStringNimbusAttributedLabel)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSMutableAttributedString (NimbusAttributedLabel)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextAlignment:(CTTextAlignment)textAlignment 
           lineBreakMode:(CTLineBreakMode)lineBreakMode 
                   range:(NSRange)range {
  CTParagraphStyleSetting paragraphStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment,
      .valueSize = sizeof(CTTextAlignment),
      .value = (const void*)&textAlignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode,
      .valueSize = sizeof(CTLineBreakMode),
      .value = (const void*)&lineBreakMode},
	};
	CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyles, 2);
  [self addAttribute:(NSString*)kCTParagraphStyleAttributeName
               value:(__bridge id)style 
               range:range];
  CFRelease(style);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextAlignment:(CTTextAlignment)textAlignment 
           lineBreakMode:(CTLineBreakMode)lineBreakMode {
  [self setTextAlignment:textAlignment 
           lineBreakMode:lineBreakMode 
                   range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)color range:(NSRange)range {
  if (nil != color) {
    [self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range];

    [self addAttribute:(NSString*)kCTForegroundColorAttributeName
                 value:(id)color.CGColor
                 range:range];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)color {
  [self setTextColor:color range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font range:(NSRange)range {
  if (nil != font) {
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range];

    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, nil);
    [self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:range];
    CFRelease(fontRef);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  [self setFont:font range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range {
  [self removeAttribute:(NSString*)kCTUnderlineColorAttributeName range:range]; 
  [self addAttribute:(NSString*)kCTUnderlineStyleAttributeName 
               value:[NSNumber numberWithInt:(style|modifier)]
               range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style 
                modifier:(CTUnderlineStyleModifiers)modifier {
  [self setUnderlineStyle:style 
                 modifier:modifier
                    range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range {
  [self removeAttribute:(NSString*)kCTStrokeWidthAttributeName range:range]; 
  [self addAttribute:(NSString*)kCTStrokeWidthAttributeName 
               value:[NSNumber numberWithFloat:width] 
               range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)width {
  [self setStrokeWidth:width range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)color range:(NSRange)range {
  if (nil != color) {
    [self removeAttribute:(NSString*)kCTStrokeColorAttributeName range:range];

    [self addAttribute:(NSString*)kCTStrokeColorAttributeName
                 value:(id)color.CGColor 
                 range:range];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)color {
  [self setStrokeColor:color range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setKern:(CGFloat)kern range:(NSRange)range {
  [self removeAttribute:(NSString*)kCTKernAttributeName range:range]; 
  [self addAttribute:(NSString*)kCTKernAttributeName 
               value:[NSNumber numberWithFloat:kern] 
               range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setKern:(CGFloat)kern {
  [self setKern:kern range:NSMakeRange(0, self.length)];
}


@end
