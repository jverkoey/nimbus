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

// Vertical alignments for NIAttributedLabel.
typedef enum {
  NIVerticalTextAlignmentTop = 0,
  NIVerticalTextAlignmentMiddle,
  NIVerticalTextAlignmentBottom,
} NIVerticalTextAlignment;

@protocol NIAttributedLabelDelegate;

/**
 * A UILabel that utilizes NSAttributedString to format its text.
 *
 * Differences between UILabel and NIAttributedLabel:
 *
 * - UILineBreakModeHeadTruncation, UILineBreakModeTailTruncation, and
 *   UILineBreakModeMiddleTruncation only apply to single lines and will not wrap the label
 *   regardless of the numberOfLines property. To wrap liines with any of these line break modes
 *   you must explicitly add \n characters to the string.
 * - When you assign an NSString to the text property the attributed label will create an
 *   attributed string that inherits all of the label's current styles.
 * - Text is aligned vertically to the top of the bounds rather than centered. You can change this
 *   using @link NIAttributedLabel::verticalTextAlignment verticalTextAlignment@endlink.
 *
 *      @ingroup NimbusAttributedLabel
 */
@interface NIAttributedLabel : UILabel

@property (nonatomic, copy) NSAttributedString* attributedString;

@property (nonatomic, assign) BOOL autoDetectLinks; // Default: NO
@property (nonatomic, assign) NSTextCheckingType dataDetectorTypes; // Default: NSTextCheckingTypeLink
@property (nonatomic, assign) BOOL deferLinkDetection; // Default: NO

- (void)addLink:(NSURL *)urlLink range:(NSRange)range;
- (void)removeAllExplicitLinks; // Removes all links that were added by addLink:range:. Does not remove autodetected links.

@property (nonatomic, retain) UIColor* linkColor; // Default: [UIColor blueColor]
@property (nonatomic, retain) UIColor* highlightedLinkColor; // Default: [UIColor colorWithWhite:0.5 alpha:0.5
@property (nonatomic, assign) BOOL linksHaveUnderlines; // Default: NO
@property (nonatomic, retain) NSDictionary *attributesForLinks; // Default: nil

@property (nonatomic, assign) NIVerticalTextAlignment verticalTextAlignment; // Default: NIVerticalTextAlignmentTop
@property (nonatomic, assign) CTUnderlineStyle underlineStyle;
@property (nonatomic, assign) CTUnderlineStyleModifiers underlineStyleModifier;
@property (nonatomic, assign) CGFloat shadowBlur; // Default: 0
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, retain) UIColor* strokeColor;
@property (nonatomic, assign) CGFloat textKern;

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range;
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range;
- (void)setStrokeColor:(UIColor *)color range:(NSRange)range;
- (void)setTextKern:(CGFloat)kern range:(NSRange)range;

@property (nonatomic, assign) IBOutlet id<NIAttributedLabelDelegate> delegate;
@end

/**
 * The attributed label delegate used to inform of user interactions.
 *
 * @ingroup NimbusAttributedLabel
 */
@protocol NIAttributedLabelDelegate <NSObject>
@optional

/**
 * Called when the user has tapped a link in the attributed label.
 */
- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point;

@end

/** @name Accessing the Text Attributes */

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

/** @name Accessing and Detecting Links */

/**
 * Whether to automatically detect links in the string.
 *
 * By default this is disabled.
 *
 * Link detection is deferred until the label is displayed for the first time. If the text changes
 * then all of the links will be cleared and re-detected when the label displays again.
 *
 * Note that link detection is an expensive operation. If you are planning to use attributed labels
 * in table views or similar high-performance situations then you should consider enabling defered
 * link detection by setting deferLinkDetection to YES.
 *
 *      @sa NIAttributedLabel::dataDetectorTypes
 *      @fn NIAttributedLabel::autoDetectLinks
 */

/**
 * Whether to defer link detection to a separate thread.
 *
 * By default this is disabled.
 *
 * When defering is enabled, link detection will be performed on a separate thread. This will cause
 * your label to appear without any links briefly before being redrawn with the detected links.
 * This offloads the data detection to a separate thread so that your labels can be displayed
 * faster.
 *
 *      @fn NIAttributedLabel::deferLinkDetection
 */

/**
 * The types of data that will be detected when autoDetectLinks is enabled.
 *
 * By default this is NSTextCheckingTypeLink. <a href="https://developer.apple.com/library/mac/#documentation/AppKit/Reference/NSTextCheckingResult_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40008798-CH1-DontLinkElementID_50">All available data detector types</a>.
 *
 *      @fn NIAttributedLabel::dataDetectorTypes
 */

/**
 * Adds a link to a URL at a given range.
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

/** @name Accessing Link Display Styles */

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
 * A dictionary of attributes to apply to links.
 *
 * This dictionary must contain CoreText properties. These attributes are applied after the color
 * and link styles have been applied to the link.
 *
 *      @fn NIAttributedLabel::attributesForLinks
 */

/** @name Modifying Rich Text Styles for All Text */

/**
 * The vertical alignment of the text within the label's bounds.
 *
 * @c NIVerticalTextAlignmentBottom will align the text to the bottom of the bounds, while
 * @c NIVerticalTextAlignmentMiddle will center the text vertically.
 *
 * The default is @c NIVerticalTextAlignmentTop. This is for performance reasons because the other
 * modes require more computation and aligning to the top is generally what you want anyway.
 *
 *      @fn NIAttributedLabel::verticalTextAlignment
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
 * A non-negative number specifying the amount of blur to apply to the label's shadow.
 *
 * By default this is zero. In practice this is often the desired amount of blurring to apply to a
 * label shadow.
 *
 *      @fn NIAttributedLabel::shadowBlur
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

/** @name Modifying Rich Text Styles in Ranges */

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
 * Note that this will not change the default font value and font will return the default font.
 *
 *      @fn NIAttributedLabel::setFont:range:
 */

/**
 * Sets the underline style and modifier for a given range.
 *
 * Note that this will not change the default underline style.
 *
 * Style Values:
 *
 * - kCTUnderlineStyleNone (default)
 * - kCTUnderlineStyleSingle
 * - kCTUnderlineStyleThick
 * - kCTUnderlineStyleDouble
 *
 * Modifier Values:
 *
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
 * A positive number will draw only the stroke.
 * A negative number wlll draw the stroke and fill.
 *
 *      @fn NIAttributedLabel::setStrokeWidth:range:
 */

/**
 * Modifies the stroke color for a given range.
 *
 * Normally you would use this in conjunction with setStrokeWidth:range:, passing in the same
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

/** @name Accessing the Delegate */

/**
 * The attributed label notifies the delegate of any user interactions.
 *
 *      @fn NIAttributedLabel::delegate
 */
