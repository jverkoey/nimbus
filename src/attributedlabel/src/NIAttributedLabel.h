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

// In standard UI text alignment we do not have justify, however we can justify in CoreText
#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NSAttributedString+NimbusAttributedLabel.h"

@class NIAttributedLabel;
/**
 * The attributed label delegate used to inform of user interactions.
 *
 * @ingroup NimbusAttributedLabel-Protocol
 */
@protocol NIAttributedLabelDelegate <NSObject>
@optional
/**
 * Called when the user taps and releases a detected link.
 * 
 * .
 */
-(void)attributedLabel:(NIAttributedLabel*)attributedLabel 
         didSelectLink:(NSURL*)url 
               atPoint:(CGPoint)point;
@end

/**
 * A UILabel that utilizes NSAttributedString
 *
 *      @ingroup NimbusAttributedLabel
 *
 */

@interface NIAttributedLabel : UILabel {
  NSMutableAttributedString*  _attributedText;
  BOOL                        _autoDetectLinks;
  UIColor*                    _linkColor;
  UIColor*                    _linkHighlightColor;
  CTUnderlineStyle            _underlineStyle;
  CTUnderlineStyleModifiers   _underlineStyleModifier;
  CGFloat                     _strokeWidth;
  UIColor*                    _strokeColor;
  CGFloat                     _textKern;
  
  CTFrameRef                  _textFrame;
	CGRect                      _drawingRect;
  NSTextCheckingResult*       _currentLink;
  
  NSMutableArray*             _customLinks;
}

/**
 * The attributted string to display.
 *
 * Use this instead of the inherited text property on UILabel.
 * If text is used the text will inherit the UILabel properties and
 * be convertied to NSAttributedString.
 */
@property(nonatomic, copy) NSAttributedString* attributedText;

/**
 * Whether links are automatically detected in the text.
 *
 * When set to true links will be detected and displayed as touchable.
 * Detected links will also have a linkColor and linkHighlightedColor.
 */
@property(nonatomic, assign) BOOL autoDetectLinks;

/**
 * The color of detected links.
 *
 * If no color is set, the default is [UIColor blueColor].
 */
@property(nonatomic, retain) UIColor* linkColor;

/**
 * The color of the links background when touched/highlighted.
 *
 * If no color is set, the default is [UIColor colorWithWhite:0.5 alpha:0.2]
 * If you do not want to highlight links when touched, set this to [UIColor clearColor]
 * or set it to the same color as your views background color (opaque colors have better
 * performance).
 */
@property(nonatomic, retain) UIColor* linkHighlightColor;

/**
 * The underline style for the whole text.
 *
 * Value:
 * - kCTUnderlineStyleNone (default)
 * - kCTUnderlineStyleSingle
 * - kCTUnderlineStyleThick
 * - kCTUnderlineStyleDouble
 */
@property(nonatomic, assign) CTUnderlineStyle underlineStyle;

/**
 * The underline style modifier for the whole text.
 *
 * Value:
 * - kCTUnderlinePatternSolid (default)
 * - kCTUnderlinePatternDot
 * - kCTUnderlinePatternDash
 * - kCTUnderlinePatternDashDot
 * - kCTUnderlinePatternDashDotDot	
 */
@property(nonatomic, assign) CTUnderlineStyleModifiers underlineStyleModifier;


/**
 * The stroke width for the whole text
 *
 * Positive numbers will render only the stroke, where as negivive numbers are for stroke
 * and fill.
 * A width of 3.0 is a good starting point.
 */
@property(nonatomic, assign) CGFloat strokeWidth;

/**
 * The stroke color for the whole text
 */
@property(nonatomic, retain) UIColor* strokeColor;

/**
 * The text kern for the whole text
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away from and a negative kern indicates a
 * shift closer
 */
@property(nonatomic, assign) CGFloat textKern;

/**
 * Sets the text color for a given range.
 *
 * Note that this will not change the overall text Color value
 * and textColor will return the default text color.
 */
-(void)setTextColor:(UIColor *)textColor range:(NSRange)range;

/** 
 * Sets the font for a given range
 *
 * Note that this will not change the default font value and font will
 * return the default font.
 */
-(void)setFont:(UIFont *)font range:(NSRange)range;

/**
 * Sets the underline style and modifier for a given range.
 *
 * Note that this will not change the default underline style.
 *
 * Style Values:
 * - kCTUnderlineStyleNone (default)
 * - kCTUnderlineStyleSingle
 * - kCTUnderlineStyleThick
 * - kCTUnderlineStyleDouble
 *
 * Modifier Values:
 * - kCTUnderlinePatternSolid (default)
 * - kCTUnderlinePatternDot
 * - kCTUnderlinePatternDash
 * - kCTUnderlinePatternDashDot
 * - kCTUnderlinePatternDashDotDot
 */
-(void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;

/**
 * The stroke width for the given range
 *
 * A positive number will render only the stroke, whereas negivive a number are for stroke
 * and fill.
 * A width of 3.0 is a good starting point.
 */
-(void)setStrokeWidth:(CGFloat)width range:(NSRange)range;

/**
 * The stroke color for the given range
 *
 * Normally you would use this in conjunction with setStrokeWidth:range: passing in the same
 * range for both
 */
-(void)setStrokeColor:(UIColor*)color range:(NSRange)range;

/**
 * The text kern for a given range
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away from and a negative kern indicates a
 * shift closer
 */
-(void)setTextKern:(CGFloat)kern range:(NSRange)range;

/**
 * Adds a custom tappable link.
 *
 * Link will take on properties defined in linkColor and linkHighlightColor. Also, add a link
 * will set en
 */
-(void)addLink:(NSURL*)urlLink range:(NSRange)range;

/**
 * The attributed label notifies the delegate of any user interactions.
 */
@property(nonatomic, assign) IBOutlet id<NIAttributedLabelDelegate> delegate;

@end
