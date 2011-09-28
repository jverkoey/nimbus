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
 * The Nimbus Attributed Label is a UILabel that uses NSAttributedString to provide
 * custom text styling. NIAttributedLabel uses Apple's CoreText framework to handle the
 * styling, resulting in a fast, iOS SDK-based solution for styled text.
 *
 * NIAttributedLabel will initially inherit the default styles set on the UILabel. You can 
 * use an attributed label within Interface Builder by creating a regualar UILabel and then
 * changing its class to NIAttributedLabel. This will allow you to set styles that apply to
 * the entire string, but if you want to style specific parts of the string then you will
 * need to do this formatting in code.
 *
 * <h2>Key Features</h2>
 *
 * - Link detection
 * - Custom links
 * - Setting custom styles for specific ranges
 * - Underline text
 * - Justify paragraph style
 * - Text stroking
 * - Text kerning
 *
 *  @image html NIAttributedLabelExample1.png "A mashup of possible label styles"
 *
 * <h2>Link Detection</h2>
 *
 * Link detection is achieved using NSDataDetector and therefore is only available in iOS 4.0
 * and later. If pre-iOS 4.0 support is required then a regex solution will likely
 * be used if NSDataDetector is not available, though this is not currently implemented.
 *
 * Link detection is off by default and must be enabled by setting autoDetectLinks to YES:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Enables link detection on the label.
 *    myLabel.autoDetectLinks = YES;
 * }
 * @endcode
 *
 * Enabling link detection will also enable user interation with the label view i.e. allow users 
 * to tap the detected links.
 *
 * Detected links will inherit the linkColor and linkHighlight color (highlights on tap).
 * These colors are both customizable:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Sets all links to to be colored purple.
 *    myLabel.linkColor = [UIColor purpleColor];
 *    // Set the on tap highlight color to orange.
 *    myLabel.linkHighlightColor = [UIColor orangeColor];
 * } 
 * @endcode
 *
 * In the mashup screenshot above you can see links in blue, which is the default color.
 *
 * linkColor and linkHighlightColor will also effect custom links (see below).
 *
 * Implementing NIAttributedLabelDelegate will alow you to take action when a link is tapped:
 *
 * @code
 * - (void)viewDidLoad {
 *    myLabel.delegate = self;
 * } 
 *
 * - (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectLink:(NSURL *)url {
 *    // TODO: send user to selected url
 * }
 * @endcode
 *
 * <h2>Custom Links</h2>
 *
 * Custom links behave the same as detected links but allow you to set any range of text to 
 * any URL. This is useful for internal links:
 * 
 * @code
 * - (void)viewDidLoad {
 *    // Add a custom link to the text 'nimbus'.
 *    [myLabel addLink:[NSURL URLWithString:@"nimbus://custom/url"]
 *               range:[myLabel.text rangeOfString:@"nimbus"]];
 * }
 * @endcode
 *
 * <h2>Underlined Text</h2>
 *
 * Simple example to underline a label:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Underline the whole label with a single line.
 *    myLabel.underlineStyle = kCTUnderlineStyleSingle;
 * }
 * @endcode
 *
 * Underline modifiers can also be added:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Underline the whole label with a dash dot single line.
 *    myLabel.underlineStyle = kCTUnderlineStyleSingle;
 *    myLabel.underlineStyleModifier = kCTUnderlinePatternDashDot;
 * }
 * @endcode
 *
 * Underline styles and modifiers can be mixed to create the desired effect, which is shown in
 * the following screenshot:
 *
 * @image html NIAttributedLabelExample2.png "Underline styles"
 *
 *    @remarks Underline style kCTUnderlineStyleThick seems to only render a single line, it's
 *             possible that it is not supported with Helvetica Neue and is font specific.
 *
 * <h2>Justified Paragraph Style</h2>
 *
 * Standard UILabel has support for left aligned, right aligned and centered text.
 * NIAttributtedLabel adds support for justified text.
 *
 * NIAttributtedLabel uses CoreText's CTTextAlignment under the hood for text alignment, however
 * for convenience and eases alignment can be set via the more common UIKit's UITextAlignment, just
 * like a regular UILabel. A UITextAlignmentJustify macro has been created to set justified text:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Label will be justified to the label's frame width.
 *    myLabel.textAlignment = UITextAlignmentJustify;
 * }
 * @endcode
 *
 * <h2>Text Stroke</h3>
 *
 * Text stroke styles can be set by setting the stroke width and stroke color:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Set the stroke width.
 *    myLabel.strokeWidth = 3.0;
 *    // Give the text a black stroke.
 *    myLabel.strokeColor = [UIColor blackColor];
 * }
 * @endcode
 *
 * If you give the stroke width a positive number then the label will ignore the text color and 
 * just render the given stroke:
 *
 * @image html NIAttributedLabelExample3.png "Black stroke of 3.0"
 *
 * If you use a negative number then it will add the stroke the same as before, but 
 * also render the fill color which will be the original text color:
 * 
 * @code
 * - (void)viewDidLoad {
 *    // set the stoke width and renders the fill color
 *    myLabel.strokeWidth = -3.0;
 *    myLabel.strokeColor = [UIColor blackColor];
 * }
 * @endcode
 *
 * @image html NIAttributedLabelExample4.png "Black stroke of -3.0"
 *
 * <h2>Text Kerning</h2>
 *
 * Text kerning is the space between characters. A value of 0 is the default spacing. A
 * positive number will increase the space and a negative number will decrease the space:
 *
 * @code
 * - (void)viewDidLoad {
 *    // Move the character spacing closer together.
 *    myLabel.textKern = -6.0;
 * }
 * @endcode
 *
 * @image html NIAttributedLabelExample5.png "Text kern of -6.0"
 *
 * <h2>Range Format Styles</h2>
 *
 * All styles that can be added to the whole label (as well as default UILabel styles like font and
 * text color) can be added to just a range of text as shown in the mashup screenshot above (last
 * paragraph):
 *
 * @code
 * - (void)viewDidLoad {
 *    // Change the text 'Nimbus' to orange.
 *    [myLabel setTextColor:[UIColor orangeColor] range:[myLabel.text rangeOfString:@"Nimbus"]];
 *    // Change the text 'iOS' to a larger font.
 *    [myLabel setFont:[UIFont boldSystemFontOfSize:22] range:[myLabel.text rangeOfString:@"iOS"]];
 *    // etc. etc.
 * }
 * @endcode
 *
 * All NIAttributedLabel format properties also have a method to set format with a NSRange.
 *
 * <h2>Example Project</h2>
 *
 * NIAttributedLabel should be very easy to get up and running. The easiest way to learn is to 
 * have a look at the BasicAttributedLabel project in the examples folder:
 *
 * <a
 * href="https://github.com/jverkoey/nimbus/tree/master/examples/attributedlabel/BasicAttributedLabel">
 * Example Project on GitHub</a>
 *
 * <h2>Planned Features</h2>
 *
 * There are still a few things missing, like line spacing, that we would like to support. We may
 * also add support for inline images in the future (not easy in CoreText). 
 *
 * We are planning to build a Markdown to NSAttributedString parser which will
 * make it easier to add rich text to your applications.
 *
 * @defgroup NimbusAttributedLabel-Protocol Protocol
 * @} */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NIAttributedLabel.h"
