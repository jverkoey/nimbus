//
// Copyright 2011-2014 NimbusKit
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

#import "InterfaceBuilderAttributedLabelViewController.h"
#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller creates its view from the AttributedLabelMashup xib file found adjacent to this
// controller in the Xcode project. UILabel views are added to the interface and NIAttributedLabel
// is set as the custom class. We then configure the attributed labels further in viewDidLoad.
//
// You will find the following Nimbus features used:
//
// [attributedlabel]
// NIAttributedLabel
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// CoreText.framework
// QuartzCore.framework
//

@interface InterfaceBuilderAttributedLabelViewController() <NIAttributedLabelDelegate>
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet NIAttributedLabel* nimbusTitle;
@property (nonatomic, retain) IBOutlet NIAttributedLabel* label1;
@property (nonatomic, retain) IBOutlet NIAttributedLabel* label2;
@property (nonatomic, retain) IBOutlet NIAttributedLabel* label3;
@property (nonatomic, retain) IBOutlet NIAttributedLabel* label4;
@end

@implementation InterfaceBuilderAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:@"AttributedLabelMashup" bundle:nil])) {
    self.title = @"Interface Builder";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _nimbusTitle.strokeWidth = -3.0;
  _nimbusTitle.strokeColor = [UIColor blackColor];

  // Kerning modifies the spacing between letters.
  _nimbusTitle.textKern = 15.0;

  _label1.textAlignment = NSTextAlignmentJustified;

  _label2.underlineStyle = kCTUnderlineStyleDouble;
  _label2.underlineStyleModifier = kCTUnderlinePatternDot;

  _label3.autoDetectLinks = YES;
  _label3.linkColor = [UIColor purpleColor];
  _label3.highlightedLinkBackgroundColor = [UIColor orangeColor];
  _label3.linksHaveUnderlines = YES;

  _label4.textAlignment = NSTextAlignmentJustified;
  [_label4 setTextColor:[UIColor orangeColor]  range:[_label4.text rangeOfString:@"Nimbus"]];
  [_label4 setTextColor:[UIColor redColor]  range:[_label4.text rangeOfString:@"accelerates"]];
  [_label4 setFont:[UIFont boldSystemFontOfSize:22] range:[_label4.text rangeOfString:@"iOS"]];
  [_label4 setUnderlineStyle:kCTUnderlineStyleSingle modifier:kCTUnderlinePatternDash range:[_label4.text rangeOfString:@"documentation"]];
  [_label4 setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:17] range:[_label4.text rangeOfString:@"Nimbus" options:NSBackwardsSearch]];
  [_label4 addLink:[NSURL URLWithString:@"nimbus://custom/url"] range:[_label4.text rangeOfString:@"easy"]];

  self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(_label4.frame));
}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Link Selected" message:result.URL.relativeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
}

@end
