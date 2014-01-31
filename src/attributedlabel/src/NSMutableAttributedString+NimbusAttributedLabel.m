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

NI_FIX_CATEGORY_BUG(NSMutableAttributedStringNimbusAttributedLabel)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSMutableAttributedString (NimbusAttributedLabel)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight
                   range:(NSRange)range {
    
    CTParagraphStyleRef style;
    
    if ( lineHeight == 0 ) {
        CTParagraphStyleSetting paragraphStyles[2] = {
            {.spec = kCTParagraphStyleSpecifierAlignment,
                .valueSize = sizeof(CTTextAlignment),
                .value = (const void*)&textAlignment},
            {.spec = kCTParagraphStyleSpecifierLineBreakMode,
                .valueSize = sizeof(CTLineBreakMode),
                .value = (const void*)&lineBreakMode},
        };
        style = CTParagraphStyleCreate(paragraphStyles, 2);
    } else {
        CTParagraphStyleSetting paragraphStyles[4] = {
            {.spec = kCTParagraphStyleSpecifierAlignment,
                .valueSize = sizeof(CTTextAlignment),
                .value = (const void*)&textAlignment},
            {.spec = kCTParagraphStyleSpecifierLineBreakMode,
                .valueSize = sizeof(CTLineBreakMode),
                .value = (const void*)&lineBreakMode},
            {.spec = kCTParagraphStyleSpecifierMinimumLineHeight,
                .valueSize = sizeof(lineHeight),
                .value = (const void*)&lineHeight},
            {.spec = kCTParagraphStyleSpecifierMaximumLineHeight,
                .valueSize = sizeof(lineHeight),
                .value = (const void*)&lineHeight},
        };
        style = CTParagraphStyleCreate(paragraphStyles, 4);
    }
    [self addAttribute:(NSString *)kCTParagraphStyleAttributeName
                 value:(__bridge id)style
                 range:range];
    CFRelease(style);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextAlignment:(CTTextAlignment)textAlignment
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight {
    [self setTextAlignment:textAlignment
             lineBreakMode:lineBreakMode
                lineHeight:lineHeight
                     range:NSMakeRange(0, self.length)];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)color range:(NSRange)range {
  if (nil != color.CGColor) {
    [self removeAttribute:NSForegroundColorAttributeName range:range];

    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)color {
  [self setTextColor:color range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font range:(NSRange)range {
  if (nil != font) {
    [self removeAttribute:NSFontAttributeName range:range];
    [self addAttribute:NSFontAttributeName value:font range:range];
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
  [self removeAttribute:NSUnderlineStyleAttributeName range:range];
  [self addAttribute:NSUnderlineStyleAttributeName value:@((style|modifier)) range:range];
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
  [self removeAttribute:NSStrokeWidthAttributeName range:range];
  [self addAttribute:NSStrokeWidthAttributeName value:@(width) range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)width {
  [self setStrokeWidth:width range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)color range:(NSRange)range {
  if (nil != color.CGColor) {
    [self removeAttribute:NSStrokeColorAttributeName range:range];
    [self addAttribute:NSStrokeColorAttributeName value:color range:range];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)color {
  [self setStrokeColor:color range:NSMakeRange(0, self.length)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setKern:(CGFloat)kern range:(NSRange)range {
  [self removeAttribute:NSKernAttributeName range:range];
  [self addAttribute:NSKernAttributeName value:@(kern) range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setKern:(CGFloat)kern {
  [self setKern:kern range:NSMakeRange(0, self.length)];
}


@end
