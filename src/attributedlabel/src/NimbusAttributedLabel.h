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

/**
 * @defgroup NimbusAttributedLabel Nimbus Attributed Label
 * @{
 *
 * The Nimbus Attributed Label is a UILabel that uses NSAttributedString to render
 * rich text labels with links using CoreText.
 *
 * NIAttributedLabel requires CoreText.framework, QuartzCore.framework, and iOS 4.0.
 *
 * <h2>Basic Use</h2>
 *
 * You can use an NIAttributedLabel just as you would use a UILabel. The attributed label creates
 * an attributed string behind the scenes when you assign a string to the text property. The label
 * then uses this attributed string to maintain and eventually present the rich text properties.
 *
@code
NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];

// The internal NSAttributedString will inherit all of the UILabel properties when we assign text.
label.text = @"Nimbus";
@endcode
 *
 *
 * <h2>Interface Builder</h2>
 *
 * You can use an attributed label within Interface Builder by creating a regualar UILabel and
 * changing its class to NIAttributedLabel. This will allow you to set styles that apply to
 * the entire string. If you want to style specific parts of the string then you will
 * need to do this in code.
 *
 *
 * <h2>Feature Overview</h2>
 *
 * - Automatic link detection using data detectors
 * - Explicit links
 * - Underlining
 * - Justifying paragraphs
 * - Stroking
 * - Kerning
 * - Setting rich text styles at specific ranges
 *
 *  @image html NIAttributedLabelExample1.png "A mashup of possible label styles"
 *
 *
 * <h3>Automatic Link Detection</h3>
 *
 * Automatic link detection is provided using the NSDataDetector facilities of iOS 4.0.
 * It is off by default and can be enabled by setting
 * @link NIAttributedLabel::autoDetectLinks autoDetectLinks@endlink to YES. You may configure
 * the types of data that are detected by modifying the
 * @link NIAttributedLabel::dataDetectorTypes dataDetectorTypes@endlink property.
 *
@code
// Enable link detection on the label.
myLabel.autoDetectLinks = YES;
@endcode
 *
 * Enabling automatic link detection will enable user interation with the label view so that the
 * user can tap the detected links.
 *
 * Detected links will use @link NIAttributedLabel::linkColor linkColor@endlink and
 * @link NIAttributedLabel::highlightedLinkColor highlightedLinkColor@endlink to differentiate
 * themselves from standard text. highlightedLinkColor is the color of the highlighting frame
 * around the text.
 *
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
 *
 * <h3>Explicit Links</h3>
 *
 * It is easy to add explicit links by using the
 * @link NIAttributedLabel::addLink:range: addLink:range:@endlink method.
 * 
@code
- (void)viewDidLoad {
  [super viewDidLoad];

  // Add a custom link to the text 'nimbus'.
  [myLabel addLink:[NSURL URLWithString:@"nimbus://custom/url"]
             range:[myLabel.text rangeOfString:@"nimbus"]];
}
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
 *    @remarks Underline style kCTUnderlineStyleThick only over renders a single line. It's
 *             possible that it is not supported with Helvetica Neue and is font specific.
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
 */

/**
 * @defgroup NimbusAttributedLabel-Protocol Protocol
 * @}
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NIAttributedLabel.h"
