//
// Copyright 2011-2014 NimbusKit
// Originally created by Roger Chapman
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
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/**
 * For easier formatting of NSAttributedString.
 *
 * Most of these methods are called directly from NIAttributedLabel. Normally you should
 * not have to call these methods directly. Have a look at NIAttributedLabel first, it's most
 * likely what you're after.
 */
@interface NSMutableAttributedString (NimbusAttributedLabel)

/**
 * Sets the text alignment and line break mode for a given range.
 */
- (void)setTextAlignment:(CTTextAlignment)textAlignment 
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight
                   range:(NSRange)range;

/**
 * Sets the text alignment and the line break mode for the entire string.
 */
- (void)setTextAlignment:(CTTextAlignment)textAlignment 
           lineBreakMode:(CTLineBreakMode)lineBreakMode
              lineHeight:(CGFloat)lineHeight;

/**
 * Sets the text color for a given range.
 */
- (void)setTextColor:(UIColor *)color range:(NSRange)range;

/**
 * Sets the text color for the entire string.
 */
- (void)setTextColor:(UIColor *)color;

/**
 * Sets the font for a given range.
 */
- (void)setFont:(UIFont *)font range:(NSRange)range;

/**
 * Sets the font for the entire string.
 */
- (void)setFont:(UIFont *)font;

/**
 * Sets the underline style and modifier for a given range.
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier
                    range:(NSRange)range;
/**
 * Sets the underline style and modifier for the entire string.
 */
- (void)setUnderlineStyle:(CTUnderlineStyle)style
                 modifier:(CTUnderlineStyleModifiers)modifier;

/**
 * Sets the stroke width for a given range.
 */
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range;

/**
 * Sets the stroke width for the entire string.
 */
- (void)setStrokeWidth:(CGFloat)width;

/**
 * Sets the stroke color for a given range.
 */
- (void)setStrokeColor:(UIColor *)color range:(NSRange)range;

/**
 * Sets the stroke color for the entire string.
 */
- (void)setStrokeColor:(UIColor *)color;

/**
 * Sets the text kern for a given range.
 */
- (void)setKern:(CGFloat)kern range:(NSRange)range;

/**
 * Sets the text kern for the entire string.
 */
- (void)setKern:(CGFloat)kern;

@end
