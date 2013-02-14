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
#import <UIKit/UIKit.h>

/**
 * Currently, for size units we only support pixels (resolution independent)
 * and percentage (of superview)
 */
typedef enum {
	CSS_PIXEL_UNIT,
	CSS_PERCENTAGE_UNIT,
  CSS_AUTO_UNIT
} NICSSUnitType;

/**
 * Width, height, top, left, right, bottom can be expressed in various units.
 */
typedef struct {
	NICSSUnitType type;
	CGFloat value;
} NICSSUnit;

/**
 * A simple translator from raw CSS rulesets to Objective-C values.
 *
 *      @ingroup NimbusCSS
 *
 * Objective-C values are created on-demand and cached. These ruleset objects are cached
 * by NIStylesheet for a given CSS scope. When a memory warning is received, all ruleset objects
 * are removed from every stylesheet.
 */
@interface NICSSRuleset : NSObject {
@private
  NSMutableDictionary* _ruleset;
  
  UIColor* _textColor;
  UIColor* _highlightedTextColor;
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
  UIColor* _backgroundColor;
  CGFloat _borderRadius;
  UIColor *_borderColor;
  CGFloat _borderWidth;
  UIColor *_tintColor;
  UIActivityIndicatorViewStyle _activityIndicatorStyle;
  UIViewAutoresizing _autoresizing;
  UITableViewCellSeparatorStyle _tableViewCellSeparatorStyle;
  UIScrollViewIndicatorStyle _scrollViewIndicatorStyle;
  UITextAlignment _frameHorizontalAlign;
  UIViewContentMode _frameVerticalAlign;
  
  NICSSUnit _width;
  NICSSUnit _height;
  NICSSUnit _top;
  NICSSUnit _bottom;
  NICSSUnit _left;
  NICSSUnit _right;
  
  union {
    struct {
      int TextColor : 1;
      int HighlightedTextColor: 1;
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
      int BackgroundColor : 1;
      int BorderRadius : 1;
      int BorderColor : 1;
      int BorderWidth : 1;
      int TintColor : 1;
      int ActivityIndicatorStyle : 1;
      int Autoresizing : 1;
      int TableViewCellSeparatorStyle : 1;
      int ScrollViewIndicatorStyle : 1;
      int Width : 1;
      int Height : 1;
      int Top : 1;
      int Bottom : 1;
      int Left : 1;
      int Right : 1;
      int FrameHorizontalAlign: 1;
      int FrameVerticalAlign: 1;
    } cached;
    int64_t _data;
  } _is;
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

- (BOOL)hasTextColor;
- (UIColor *)textColor; // color

- (BOOL)hasHighlightedTextColor;
- (UIColor *)highlightedTextColor;

- (BOOL)hasTextAlignment;
- (UITextAlignment)textAlignment; // text-align

- (BOOL)hasFont;
- (UIFont *)font; // font, font-family, font-size, font-style, font-weight

- (BOOL)hasTextShadowColor;
- (UIColor *)textShadowColor; // text-shadow

- (BOOL)hasTextShadowOffset;
- (CGSize)textShadowOffset; // text-shadow

- (BOOL)hasLineBreakMode;
- (UILineBreakMode)lineBreakMode; // -ios-line-break-mode

- (BOOL)hasNumberOfLines;
- (NSInteger)numberOfLines; // -ios-number-of-lines

- (BOOL)hasMinimumFontSize;
- (CGFloat)minimumFontSize; // -ios-minimum-font-size

- (BOOL)hasAdjustsFontSize;
- (BOOL)adjustsFontSize; // -ios-adjusts-font-size

- (BOOL)hasBaselineAdjustment;
- (UIBaselineAdjustment)baselineAdjustment; // -ios-baseline-adjustment

- (BOOL)hasOpacity;
- (CGFloat)opacity; // opacity

- (BOOL)hasBackgroundColor;
- (UIColor *)backgroundColor; // background-color

- (BOOL)hasBorderRadius;
- (CGFloat)borderRadius; // border-radius

- (BOOL)hasBorderColor;
- (UIColor *)borderColor; // border, border-color

- (BOOL)hasBorderWidth;
- (CGFloat)borderWidth; // border, border-width

- (BOOL)hasWidth;
- (NICSSUnit)width; // width

- (BOOL)hasHeight;
- (NICSSUnit)height; // height

- (BOOL)hasTop;
- (NICSSUnit)top; // top

- (BOOL)hasBottom;
- (NICSSUnit)bottom; // bottom

- (BOOL)hasLeft;
- (NICSSUnit)left; // left

- (BOOL)hasRight;
- (NICSSUnit)right; // right

- (BOOL)hasFrameHorizontalAlign;
- (UITextAlignment)frameHorizontalAlign; // -ios-halign

- (BOOL)hasFrameVerticalAlign;
- (UIViewContentMode)frameVerticalAlign; // -ios-valign

- (BOOL)hasTintColor;
- (UIColor *)tintColor; // -ios-tint-color

- (BOOL)hasActivityIndicatorStyle;
- (UIActivityIndicatorViewStyle)activityIndicatorStyle; // -ios-activity-indicator-style

- (BOOL)hasAutoresizing;
- (UIViewAutoresizing)autoresizing; // -ios-autoresizing

- (BOOL)hasTableViewCellSeparatorStyle;
- (UITableViewCellSeparatorStyle)tableViewCellSeparatorStyle; // -ios-table-view-cell-separator-style

- (BOOL)hasScrollViewIndicatorStyle;
- (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle; // -ios-scroll-view-indicator-style

@end

/**
 * Adds a raw CSS ruleset to this ruleset object.
 *
 *      @fn NICSSRuleset::addEntriesFromDictionary:
 */

/**
 * Returns YES if the ruleset has a 'color' property.
 *
 *      @fn NICSSRuleset::hasTextColor
 */

/**
 * Returns the text color.
 *
 *      @fn NICSSRuleset::textColor
 */

/**
 * Returns YES if the ruleset has a 'text-align' property.
 *
 *      @fn NICSSRuleset::hasTextAlignment
 */

/**
 * Returns the text alignment.
 *
 *      @fn NICSSRuleset::textAlignment
 */

/**
 * Returns YES if the ruleset has a value for any of the following properties:
 * font, font-family, font-size, font-style, font-weight.
 *
 * Note: You can't specify bold or italic with a font-family due to the way fonts are
 * constructed. You also can't specify a font that is both bold and italic. In order to do
 * either of these things you must specify the font-family that corresponds to the bold or italic
 * version of your font.
 *
 *      @fn NICSSRuleset::hasFont
 */

/**
 * Returns the font.
 *
 *      @fn NICSSRuleset::font
 */

/**
 * Returns YES if the ruleset has a 'text-shadow' property.
 *
 *      @fn NICSSRuleset::hasTextShadowColor
 */

/**
 * Returns the text shadow color.
 *
 *      @fn NICSSRuleset::textShadowColor
 */

/**
 * Returns YES if the ruleset has a 'text-shadow' property.
 *
 *      @fn NICSSRuleset::hasTextShadowOffset
 */

/**
 * Returns the text shadow offset.
 *
 *      @fn NICSSRuleset::textShadowOffset
 */

/**
 * Returns YES if the ruleset has an '-ios-line-break-mode' property.
 *
 *      @fn NICSSRuleset::hasLineBreakMode
 */

/**
 * Returns the line break mode.
 *
 *      @fn NICSSRuleset::lineBreakMode
 */

/**
 * Returns YES if the ruleset has an '-ios-number-of-lines' property.
 *
 *      @fn NICSSRuleset::hasNumberOfLines
 */

/**
 * Returns the number of lines.
 *
 *      @fn NICSSRuleset::numberOfLines
 */

/**
 * Returns YES if the ruleset has an '-ios-minimum-font-size' property.
 *
 *      @fn NICSSRuleset::hasMinimumFontSize
 */

/**
 * Returns the minimum font size.
 *
 *      @fn NICSSRuleset::minimumFontSize
 */

/**
 * Returns YES if the ruleset has an '-ios-adjusts-font-size' property.
 *
 *      @fn NICSSRuleset::hasAdjustsFontSize
 */

/**
 * Returns the adjustsFontSize value.
 *
 *      @fn NICSSRuleset::adjustsFontSize
 */

/**
 * Returns YES if the ruleset has an '-ios-baseline-adjustment' property.
 *
 *      @fn NICSSRuleset::hasBaselineAdjustment
 */

/**
 * Returns the baseline adjustment.
 *
 *      @fn NICSSRuleset::baselineAdjustment
 */

/**
 * Returns YES if the ruleset has an 'opacity' property.
 *
 *      @fn NICSSRuleset::hasOpacity
 */

/**
 * Returns the opacity.
 *
 *      @fn NICSSRuleset::opacity
 */

/**
 * Returns YES if the ruleset has a 'background-color' property.
 *
 *      @fn NICSSRuleset::hasBackgroundColor
 */

/**
 * Returns the background color.
 *
 *      @fn NICSSRuleset::backgroundColor
 */

/**
 * Returns YES if the ruleset has a 'border-radius' property.
 *
 *      @fn NICSSRuleset::hasBorderRadius
 */

/**
 * Returns the border radius.
 *
 *      @fn NICSSRuleset::borderRadius
 */

/**
 * Returns YES if the ruleset has a 'border' or 'border-color' property.
 *
 *      @fn NICSSRuleset::hasBorderColor
 */

/**
 * Returns the border color.
 *
 *      @fn NICSSRuleset::borderColor
 */

/**
 * Returns YES if the ruleset has a 'border' or 'border-width' property.
 *
 *      @fn NICSSRuleset::hasBorderWidth
 */

/**
 * Returns the border width.
 *
 *      @fn NICSSRuleset::borderWidth
 */

/**
 * Returns YES if the ruleset has an '-ios-tint-color' property.
 *
 *      @fn NICSSRuleset::hasTintColor
 */

/**
 * Returns the tint color.
 *
 *      @fn NICSSRuleset::tintColor
 */

/**
 * Returns YES if the ruleset has a 'width' property.
 *
 *      @fn NICSSRuleset::hasWidth
 */

/**
 * Returns the width.
 *
 *      @fn NICSSRuleset::width
 */

