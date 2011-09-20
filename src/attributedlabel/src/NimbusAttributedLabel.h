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
 * The Nimbus Attributed Label is a regular UILabel that utilizes the great power of
 * NSAttributtedString. In essence it transforms a simple label into a fully formattable
 * label using the CoreText framework.
 *
 * NIAttributedLabel will initially inherit the styles set on the original UILabel. You can 
 * use an attributed label within Interface Builder as a regualar UILabel can then change it's 
 * class to NIAttributtedLabel. Any special custom formatting can then be done in code.
 *
 * <h2>Key Features</h2>
 * 
 * Some of the features that are possible with NIAttributedLabel that you can't achieve with
 * a regular UILabel are:
 *
 * - Underlined text
 * - Justified paragraph style
 * - Link detection
 * - Text stroke
 * - Text kerning
 * - Custom links
 * - Range format styles
 *
 *  @image html NIAttributedLabelExample1.png "A mashup of possible label styles"
 *
 * <h2>Underlined Text</h2>
 * 
 * Simple example to add underline a label:
 *
 * @code
 * -(void)viewDidLoad {
 *    // underlines the whole label with a single line
 *    myLabel.underlineStyle = kCTUnderlineStyleSingle;
 * }
 * @endcode
 *
 * Underline modifiers can also be added:
 *
 * @code
 * -(void)viewDidLoad {
 *    // underlines the whole label with a dash dot single line
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
 *             possible that it is not supported with Helvetica Neue and is font specific!?
 *
 * <h2>Justified Paragraph Style</h2>
 *
 * Standard UILabel has support for left aligned, right aligned and centered text. NIAttributtedLabel
 * adds support for justified text.
 *
 * NIAttributtedLabel under the hood uses CoreText's CTTextAlignment for text alignment, however
 * for convenience and ease, alignment can be set via the more common UIKit's UITextAlignment, just
 * like a regular UILabel. A UITextAlignmentJustify macro has been created to set justified text:
 *
 * @code
 * -(void)viewDidLoad {
 *    // label will be justified to the labels frame width
 *    myLabel.textAlignment = UITextAlignmentJustify;
 * }
 * @endcode
 *
 * <h2>Link Detection</h2>
 *
 * Link detection is achieved use NSDataDetector and therefore is only availible in OS 4.0 and later.
 * If demand dictates for pre iOS 4.0 support then a regex solution will likely be used if
 * NSDataDetector is not available, but for now it is the only option.
 *
 * Link detection is off by default and must be enabled by calling:
 *
 * @code
 * -(void)viewDidLoad {
 *    // enables link detection on the label
 *    myLabel.autoDetectLinks = YES;
 * }
 * @endcode
 *
 * Enabling link detection will also enable user interation with the label view i.e. allow users 
 * to tap the detected links.
 *
 * Detected links will inherit the linkColor and linkHighlight color (highlights on tap). These colors
 * are both customizable:
 *
 * @code
 * -(void)viewDidLoad {
 *    // sets all links to to be colored purple
 *    myLabel.linkColor = [UIColor purpleColor];
 *    // set the on tap highlight color to orange
 *    myLabel.linkHighlightColor = [UIColor orangeColor];
 * } 
 * @endcode
 *
 * In the mashup screenshot above you can see links in blue, which is the default color.
 *
 * linkColor and linkHighlightColor will also effect custom links (see below).
 *
 * Implementing NIAttributedLabelDelegate will alow you to take action on any tapped links:
 *
 * @code
 * -(void)viewDidLoad {
 *    myLabel.delegate = self;
 * } 
 *
 * -(void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectLink:(NSURL *)url {
 *    // TODO: send user to selected url
 * }
 * @endcode
 *
 * <h2>Text Stroke</h3>
 *
 * Text stroke is achived by setting the stroke width and stroke color:
 *
 * @code
 * -(void)viewDidLoad {
 *    // set the stoke width
 *    myLabel.strokeWidth = 3.0;
 *    // gives the text a stroke of black
 *    myLabel.strokeColor = [UIColor blackColor];
 * }
 * @endcode
 *
 * If you give the stoke width a positive number then the label will ignore the text color and 
 * just render the given stroke:
 *
 * @image html NIAttributedLabelExample3.png "Black stroke of 3.0"
 *
 * However if you use a negitive number it will add the stroke exatly the same as before, but 
 * also render the fill color, which will be the original text color:
 * 
 * @code
 * -(void)viewDidLoad {
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
 * Text kerning is the space between characters. A value of 0 would be the default spaceing. A
 * positive number will increase the spaceing and a negitive number will decrease the spaceing:
 *
 * @code
 * -(void)viewDidLoad {
 *    // moves the character spacing closer together
 *    myLabel.textKern = -6.0;
 * }
 * @endcode
 *
 * @image html NIAttributedLabelExample5.png "Text kern of -6.0"
 *
 * <h2>Custom Links</h2>
 *
 * Custom links behave exactly the same as detected links however alow you to set any range of text to 
 * any type of URL. This is perticularly useful for internal links:
 * 
 * @code
 * -(void)viewDidLoad {
 *    // adds a custom link to the text 'numbus'
 *    [myLabel addLink:[NSURL URLWithString:@"nimbus://custom/url"] range:[myLabel.text rangeOfString:@"nimbus"]];
 * }
 * @endcode
 *
 * <h2>Range Format Styles</h2>
 *
 * All styles that can be added to the whole label (as well as default UILabel styles like font and
 * text color) can be added to just a range of text as shown in the mashup screenshot above (last
 * paragraph):
 *
 * @code
 * -(void)viewDidLoad {
 *    // Changes the text 'Nimbus' to orange
 *    [myLabel setTextColor:[UIColor orangeColor] range:[myLabel.text rangeOfString:@"Nimbus"]];
 *    // Changes the text 'iOS' to a larger font
 *    [myLabel setFont:[UIFont boldSystemFontOfSize:22] range:[myLabel.text rangeOfString:@"iOS"]];
 *    // etc. etc.
 * }
 * @endcode
 *
 * All NIAttributedLabel format properties also have a method to set per NSRange
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
 * <h2>Futures</h2>
 *
 * There are still a few things missing like line space that we would like to get in and possibly
 * inline image support (which is not easy in CoreText). 
 
 * Also we are planning a Markdown to NSAttributedString parser which will hopefully make it supper
 * easy to add rich text to your applications.
 *
 * @defgroup NimbusAttributedLabel-Protocol Protocol
 * @} */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NIAttributedLabel.h"
