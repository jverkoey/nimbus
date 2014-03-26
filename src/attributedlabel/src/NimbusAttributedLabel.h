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

/**
 * @defgroup NimbusAttributedLabel Nimbus Attributed Label
 * @{
 *
 * <div id="github" feature="attributedlabel"></div>
 *
 * The Nimbus Attributed Label is a UILabel that uses NSAttributedString to render rich text labels
 * with links using CoreText.
 *
 *  @image html NIAttributedLabelExample1.png "A mashup of possible label styles"
 *
 * <h2>Minimum Requirements</h2>
 *
 * Required frameworks:
 *
 * - Foundation.framework
 * - UIKit.framework
 * - CoreText.framework
 * - QuartzCore.framework
 *
 * Minimum Operating System: <b>iOS 6.0</b>
 *
 * Source located in <code>src/attributedlabel/src</code>
 *
@code
#import "NimbusAttributedLabel.h"
@endcode
 *
 * <h2>Basic Use</h2>
 *
 * NIAttributedLabel is a subclass of UILabel. The attributed label maintains an <a href="http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSAttributedString_Class/Reference/Reference.html">NSAttributedString</a>
 * object internally which is used in conjunction with CoreText to draw rich-text labels. A number
 * of helper methods for modifying the text style are provided. If you need to directly modify the
 * internal NSAttributedString you may do so by accessing the @c attributedText property.
 *
@code
NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];

// The internal NSAttributedString will inherit all of UILabel's text attributes when we assign
// text.
label.text = @"Nimbus";
@endcode
 *
 *
 * <h2>Interface Builder</h2>
 *
 * You can use an attributed label within Interface Builder by creating a UILabel and changing its
 * class to NIAttributedLabel. This will allow you to set styles that apply to
 * the entire string. If you want to style specific parts of the string then you will
 * need to do this in code.
 *
 *  @image html NIAttributedLabelIB.png "Configuring an attributed label in Interface Builder"
 *
 *
 * <h2>Feature Overview</h2>
 *
 * - Automatic link detection using data detectors
 * - Link attributes
 * - Explicit links
 * - Underlining
 * - Justifying paragraphs
 * - Stroking
 * - Kerning
 * - Setting rich text styles at specific ranges
 *
 *
 * <h3>Automatic Link Detection</h3>
 *
 * Automatic link detection is provided using <a href="https://developer.apple.com/library/mac/#documentation/Foundation/Reference/NSDataDetector_Class/Reference/Reference.html">NSDataDetector</a>.
 * Link detection is off by default and can be enabled by setting
 * @link NIAttributedLabel::autoDetectLinks autoDetectLinks@endlink to YES. You may configure
 * the types of data that are detected by modifying the
 * @link NIAttributedLabel::dataDetectorTypes dataDetectorTypes@endlink property. By default only
 * urls will be detected.
 *
 * @attention NIAttributedLabel is not designed to detect html anchor tags (i.e. &lt;a>). If
 *                 you want to attach a URL to a given range of text you must use
 *                 @link NIAttributedLabel::addLink:range: addLink:range:@endlink.
 *                 You can add links to the attributed string using the attribute
 *                 NIAttributedLabelLinkAttributeName. The NIAttributedLabelLinkAttributeName value
 *                 must be a NSTextCheckingResult.
 *
 * @image html NIAttributedLabel_autoDetectLinksOff.png "Before enabling autoDetectLinks"
 *
@code
// Enable link detection on the label.
myLabel.autoDetectLinks = YES;
@endcode
 *
 * @image html NIAttributedLabel_autoDetectLinksOn.png "After enabling autoDetectLinks"
 *
 * Enabling automatic link detection will automatically enable user interation with the label view
 * so that the user can tap the detected links.
 *
 * <h3>Link Attributes</h3>
 *
 * Detected links will use @link NIAttributedLabel::linkColor linkColor@endlink and
 * @link NIAttributedLabel::highlightedLinkColor highlightedLinkColor@endlink to differentiate
 * themselves from standard text. highlightedLinkColor is the color of the highlighting frame
 * around the text. You can easily add underlines to links by enabling
 * @link NIAttributedLabel::linksHaveUnderlines linksHaveUnderlines@endlink. You can customize link
 * attributes in more detail by directly modifying the
 * @link NIAttributedLabel::attributesForLinks attributesForLinks@endlink property.
 *
 *  @image html NIAttributedLabelLinkAttributes.png "Link attributes"
 *
 * <h4>A note on performance</h4>
 *
 * Automatic link detection is expensive. You can choose to defer automatic link detection by
 * enabling @link NIAttributedLabel::deferLinkDetection deferLinkDetection@endlink. This will move
 * the link detection to a separate background thread. Once the links have been detected the label
 * will be redrawn.
 *
 *
 * <h3>Handling Taps on Links</h3>
 *
 * The NIAttributedLabelDelegate protocol allows you to handle when the user taps on a given link.
 * The protocol methods provide the tap point as well as the data pertaining to the tapped link.
 *
@code
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  [[UIApplication sharedApplication] openURL:result.URL];
}
@endcode
 *
 * <h3>Explicit Links</h3>
 *
 * Links can be added explicitly using
 * @link NIAttributedLabel::addLink:range: addLink:range:@endlink.
 * 
@code
// Add a link to the string 'nimbus' in myLabel.
[myLabel addLink:[NSURL URLWithString:@"nimbus://custom/url"]
           range:[myLabel.text rangeOfString:@"nimbus"]];
@endcode
 *
 *
 * <h3>Underlining Text</h3>
 *
 * To underline an entire label:
 *
@code
// Underline the whole label with a single line.
myLabel.underlineStyle = kCTUnderlineStyleSingle;
@endcode
 *
 * Underline modifiers can also be added:
 *
@code
// Underline the whole label with a dash dot single line.
myLabel.underlineStyle = kCTUnderlineStyleSingle;
myLabel.underlineStyleModifier = kCTUnderlinePatternDashDot;
@endcode
 *
 * Underline styles and modifiers can be mixed to create the desired effect, which is shown in
 * the following screenshot:
 *
 * @image html NIAttributedLabelExample2.png "Underline styles"
 *
 *    @remarks Underline style kCTUnderlineStyleThick only over renders a single line.
 *
 *
 * <h3>Justifying Paragraphs</h3>
 *
 * NIAttributedLabel supports justified text using UITextAlignmentJustify.
 *
@code
 myLabel.textAlignment = UITextAlignmentJustify;
@endcode
 *
 *
 * <h3>Stroking Text</h3>
 *
@code
myLabel.strokeWidth = 3.0;
myLabel.strokeColor = [UIColor blackColor];
@endcode
 *
 * A positive stroke width will render only the stroke.
 *
 * @image html NIAttributedLabelExample3.png "Black stroke of 3.0"
 *
 * A negative number will fill the stroke with textColor:
 * 
@code
myLabel.strokeWidth = -3.0;
myLabel.strokeColor = [UIColor blackColor];
@endcode
 *
 * @image html NIAttributedLabelExample4.png "Black stroke of -3.0"
 *
 *
 * <h3>Kerning Text</h3>
 *
 * Kerning is the space between characters in points. A positive kern will increase the space
 * between letters. Correspondingly a negative number will decrease the space.
 *
@code
myLabel.textKern = -6.0;
@endcode
 *
 * @image html NIAttributedLabelExample5.png "Text kern of -6.0"
 *
 *
 * <h3>Setting Rich Text styles at specific ranges</h3>
 *
 * All styles that can be added to the whole label (as well as default UILabel styles like font and
 * text color) can be added to just a range of text.
 *
@code
[myLabel setTextColor:[UIColor orangeColor] range:[myLabel.text rangeOfString:@"Nimbus"]];
[myLabel setFont:[UIFont boldSystemFontOfSize:22] range:[myLabel.text rangeOfString:@"iOS"]];
@endcode
 * @}
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NIAttributedLabel.h"
