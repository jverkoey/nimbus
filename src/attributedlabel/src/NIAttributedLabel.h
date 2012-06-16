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

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

// In standard UI text alignment we do not have justify, however we can justify in CoreText
#ifndef UITextAlignmentJustify
#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)
#endif

@protocol NIAttributedLabelDelegate;

/**
 * A UILabel that utilizes NSAttributedString to format its text.
 *
 * A note on using lineBreakMode with NIAttributedLabel:
 * CoreText's line break mode functionality does not work the same way as UILabel.
 *
 * UILabel: when you use truncation modes with multiline labels, the text will be treated as
 * one continuous string. The documentation for each UILineBreakMode value applies correctly to
 * UILabels.
 *
 * NIAttributedLabel: when you use truncation modes with multiline labels, the modes behave
 * differently:
 *
 * - UILineBreakModeWordWrap, UILineBreakModeCharacterWrap: wraps the text over multiple lines with
 *   no truncation.
 * - UILineBreakModeHeadTruncation, UILineBreakModeTailTruncation, UILineBreakModeMiddleTruncation:
 *   will only break the text onto a new line when a \n character is encountered. Each line is
 *   truncated with the line break mode.
 *
 * In short: if you want to use truncation with a multiline attributed label then you need to
 * manually wrap the lines by using \n characters. If you don't need truncation then you can use
 * the word wrap and character wrap modes to have the text automatically wrap.
 *
 *      @ingroup NimbusAttributedLabel
 */
@interface NIAttributedLabel : UILabel

@property (nonatomic, copy) NSAttributedString* attributedString;

@property (nonatomic, assign) BOOL autoDetectLinks; // Default: NO
- (void)addLink:(NSURL *)urlLink range:(NSRange)range;
- (void)removeAllExplicitLinks; // Removes all links that were added by addLink:range:. Does not remove autodetected links.

@property (nonatomic, retain) UIColor* linkColor; // Default: [UIColor blueColor]
@property (nonatomic, retain) UIColor* highlightedLinkColor; // Default: [UIColor colorWithWhite:0.5 alpha:0.5
@property (nonatomic, assign) BOOL linksHaveUnderlines; // Default: NO

@property (nonatomic, assign) CTUnderlineStyle underlineStyle;
@property (nonatomic, assign) CTUnderlineStyleModifiers underlineStyleModifier;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, retain) UIColor* strokeColor;
@property (nonatomic, assign) CGFloat textKern;

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range;
- (void)setStrokeColor:(UIColor*)color range:(NSRange)range;
- (void)setTextKern:(CGFloat)kern range:(NSRange)range;

@property (nonatomic, assign) IBOutlet id<NIAttributedLabelDelegate> delegate;
@end

/**
 * The attributed label delegate used to inform of user interactions.
 *
 * @ingroup NimbusAttributedLabel-Protocol
 */
@protocol NIAttributedLabelDelegate <NSObject>
@optional

/**
 * Called when the user has tapped a link in the attributed label.
 */
- (void)attributedLabel:(NIAttributedLabel*)attributedLabel
          didSelectLink:(NSURL*)url
                atPoint:(CGPoint)point;

@end

/**
 * The attributed string that will be displayed.
 *
 * Setting this property explicitly will ignore the UILabel's existing style.
 *
 * If you would like to adopt the existing UILabel style then use setText:. The
 * attributedString will be created with the UILabel's style. You can then create a
 * mutable copy of the attributed string, modify it, and then assign the new attributed
 * string back to this label.
 *
 *      @fn NIAttributedLabel::attributedString
 */

/**
 * Whether to automatically detect links in the string.
 *
 * Link detection is deferred until the label is displayed for the first time. If the text changes
 * then all of the links will be cleared and re-detected when the label displays again.
 *
 *      @fn NIAttributedLabel::autoDetectLinks
 */

/**
 * Adds a link at a given range.
 *
 * Adding any links will immediately enable user interaction on this label. Explicitly added
 * links are removed whenever the text changes.
 *
 *      @fn NIAttributedLabel::addLink:range:
 */

/**
 * Removes all explicit links from the label.
 *
 * If you wish to remove automatically-detected links, set autoDetectLinks to NO.
 *
 *      @fn NIAttributedLabel::removeAllExplicitLinks
 */

/**
 * The color of detected links.
 *
 * If no color is set, the default is [UIColor blueColor].
 *
 *      @fn NIAttributedLabel::linkColor
 */

/**
 * The color of the link background when the link is highlighted.
 *
 * The default is [UIColor colorWithWhite:0.5 alpha:0.5].
 *
 * If you do not want to highlight links when touched, set this to [UIColor clearColor]
 * or set it to the same color as your view's background color.
 *
 *      @fn NIAttributedLabel::highlightedLinkColor
 */

/**
 * Whether or not links should have underlines.
 *
 * By default this is NO.
 *
 * This affects all links in the label.
 *
 *      @fn NIAttributedLabel::linksHaveUnderlines
 */

/**
 * The underline style for the whole text.
 *
 * Value:
 * - kCTUnderlineStyleNone (default)
 * - kCTUnderlineStyleSingle
 * - kCTUnderlineStyleThick
 * - kCTUnderlineStyleDouble
 *
 *      @fn NIAttributedLabel::underlineStyle
 */

/**
 * The underline style modifier for the whole text.
 *
 * Value:
 * - kCTUnderlinePatternSolid (default)
 * - kCTUnderlinePatternDot
 * - kCTUnderlinePatternDash
 * - kCTUnderlinePatternDashDot
 * - kCTUnderlinePatternDashDotDot
 *
 *      @fn NIAttributedLabel::underlineStyleModifier
 */

/**
 * The stroke width for the whole text.
 *
 * Positive numbers will render only the stroke, where as negative numbers are for stroke
 * and fill.
 *
 *      @fn NIAttributedLabel::strokeWidth
 */

/**
 * The stroke color for the whole text.
 *
 *      @fn NIAttributedLabel::strokeColor
 */

/**
 * The text kern for the whole text.
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away from and a negative kern indicates a
 * shift closer.
 *
 *      @fn NIAttributedLabel::textKern
 */

/**
 * Sets the text color for a given range.
 *
 * Note that this will not change the overall text Color value
 * and textColor will return the default text color.
 *
 *      @fn NIAttributedLabel::setTextColor:range:
 */

/** 
 * Sets the font for a given range.
 *
 * Note that this will not change the default font value and font will
 * return the default font.
 *
 *      @fn NIAttributedLabel::setFont:range:
 */

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
 *
 *      @fn NIAttributedLabel::setUnderlineStyle:modifier:range:
 */

/**
 * Modifies the stroke width for a given range.
 *
 * A positive number will render only the stroke, whereas negivive a number are for stroke
 * and fill.
 * A width of 3.0 is a good starting point.
 *
 *      @fn NIAttributedLabel::setStrokeWidth:range:
 */

/**
 * Modifies the stroke color for a given range.
 *
 * Normally you would use this in conjunction with setStrokeWidth:range: passing in the same
 * range for both.
 *
 *      @fn NIAttributedLabel::setStrokeColor:range:
 */

/**
 * Modifies the text kern for a given range.
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away and a negative kern indicates a
 * shift closer.
 *
 *      @fn NIAttributedLabel::setTextKern:range:
 */

/**
 * The attributed label notifies the delegate of any user interactions.
 *
 *      @fn NIAttributedLabel::delegate
 */
