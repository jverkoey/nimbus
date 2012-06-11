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
#ifndef UITextAlignmentJustify
#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)
#endif

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@protocol NIAttributedLabelDelegate;

/**
 * A UILabel that utilizes NSAttributedString to format its text.
 *
 *      @ingroup NimbusAttributedLabel
 */

@interface NIAttributedLabel : UILabel

/**
 * The attributed string that will be displayed.
 *
 * Setting this property explicitly will ignore the UILabel's existing style.
 *
 * If you would like to adopt the existing UILabel style then use setText:. The
 * attributedString will be created with the UILabel's style. You can then create a
 * mutable copy of the attributed string, modify it, and then assign the new attributed
 * string back to this label.
 */
@property (nonatomic, copy) NSAttributedString* attributedString;

/**
 * Whether to automatically detect links in the string.
 *
 * Link detection is deferred until the label is displayed for the first time. If the text changes
 * then all of the links will be cleared and re-detected when the label displays again.
 */
@property (nonatomic, assign) BOOL autoDetectLinks;

/**
 * Adds a link at a given range.
 *
 * Adding any links will immediately enable user interaction on this label. Explicitly added
 * links are removed whenever the text changes.
 */
- (void)addLink:(NSURL *)urlLink range:(NSRange)range;

/**
 * Removes all explicit links from the label.
 *
 * If you wish to remove automatically-detected links, set autoDetectLinks to NO.
 */
- (void)removeAllExplicitLinks;

/**
 * The color of detected links.
 *
 * If no color is set, the default is [UIColor blueColor].
 */
@property (nonatomic, retain) UIColor* linkColor;

/**
 * The color of the link's background when touched/highlighted.
 *
 * If no color is set, the default is [UIColor colorWithWhite:0.5 alpha:0.2]
 * If you do not want to highlight links when touched, set this to [UIColor clearColor]
 * or set it to the same color as your view's background color (opaque colors will perform
 * better).
 */
@property (nonatomic, retain) UIColor* linkHighlightColor;

/**
 * Whether or not links should have underlines.
 *
 * By default this is NO.
 *
 * This affects all links in the label.
 */
@property (nonatomic, assign) BOOL linksHaveUnderlines;

/**
 * The underline style for the whole text.
 *
 * Value:
 * - kCTUnderlineStyleNone (default)
 * - kCTUnderlineStyleSingle
 * - kCTUnderlineStyleThick
 * - kCTUnderlineStyleDouble
 */
@property (nonatomic, assign) CTUnderlineStyle underlineStyle;

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
@property (nonatomic, assign) CTUnderlineStyleModifiers underlineStyleModifier;


/**
 * The stroke width for the whole text.
 *
 * Positive numbers will render only the stroke, where as negative numbers are for stroke
 * and fill.
 */
@property (nonatomic, assign) CGFloat strokeWidth;

/**
 * The stroke color for the whole text.
 */
@property (nonatomic, retain) UIColor* strokeColor;

/**
 * The text kern for the whole text.
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away from and a negative kern indicates a
 * shift closer
 */
@property (nonatomic, assign) CGFloat textKern;

/**
 * Sets the text color for a given range.
 *
 * Note that this will not change the overall text Color value
 * and textColor will return the default text color.
 */
-(void)setTextColor:(UIColor *)textColor range:(NSRange)range;

/** 
 * Sets the font for a given range.
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
 * Modifies the stroke width for a given range.
 *
 * A positive number will render only the stroke, whereas negivive a number are for stroke
 * and fill.
 * A width of 3.0 is a good starting point.
 */
-(void)setStrokeWidth:(CGFloat)width range:(NSRange)range;

/**
 * Modifies the stroke color for a given range.
 *
 * Normally you would use this in conjunction with setStrokeWidth:range: passing in the same
 * range for both
 */
-(void)setStrokeColor:(UIColor*)color range:(NSRange)range;

/**
 * Modifies the text kern for a given range.
 *
 * The text kern indicates how many points the following character should be shifted from
 * its default offset.
 *
 * A positive kern indicates a shift farther away and a negative kern indicates a
 * shift closer.
 */
-(void)setTextKern:(CGFloat)kern range:(NSRange)range;

/**
 * The attributed label notifies the delegate of any user interactions.
 */
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
 * Called when the user taps and releases a detected link.
 */
-(void)attributedLabel:(NIAttributedLabel*)attributedLabel 
         didSelectLink:(NSURL*)url 
               atPoint:(CGPoint)point;

@end
