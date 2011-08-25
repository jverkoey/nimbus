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
 * Returns the Attributed Label and the NSURL of the taped link.
 */
-(void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectLink:(NSURL*)url;
@end

/**
 * A UILabel that utilizes NSAttributedString
 *
 *      @ingroup NimbusAttributedLabel
 *
 *
 */

@interface NIAttributedLabel : UILabel {
  NSMutableAttributedString*  _attributedText;
  BOOL                        _autoDetectLinks;
  UIColor*                    _linkColor;
  UIColor*                    _linkHighlightColor;
  CTUnderlineStyle            _underlineStyle;
  CTUnderlineStyleModifiers   _underlineStyleModifier;
  
  CTFrameRef                  _textFrame;
	CGRect                      _drawingRect;
  NSTextCheckingResult*       _currentLink;
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
 */
@property(nonatomic, assign) CTUnderlineStyle underlineStyle;

/**
 * The underline style modifier for the whole text.
 */
@property(nonatomic, assign) CTUnderlineStyleModifiers underlineStyleModifier;

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
 * Note that rthis will not change the default underline style.
 */
-(void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;

/**
 * The attributed label notifies the delegate of any user interactions.
 */
@property(nonatomic, assign) IBOutlet id<NIAttributedLabelDelegate> delegate;

@end
