//
// Copyright 2011-2012 Jeff Verkoeyen
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

@synthesize scrollView;
@synthesize nimbusTitle;
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:@"AttributedLabelMashup" bundle:nil])) {
    self.title = @"Interface Builder";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  nimbusTitle.strokeWidth = -3.0;
  nimbusTitle.strokeColor = [UIColor blackColor];

  // Kerning modifies the spacing between letters.
  nimbusTitle.textKern = 15.0;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  label1.textAlignment = UITextAlignmentJustify;
#else
  label1.textAlignment = NSTextAlignmentJustified;
#endif

  label2.underlineStyle = kCTUnderlineStyleDouble;
  label2.underlineStyleModifier = kCTUnderlinePatternDot;

  label3.autoDetectLinks = YES;
  label3.linkColor = [UIColor purpleColor];
  label3.highlightedLinkBackgroundColor = [UIColor orangeColor];
  label3.linksHaveUnderlines = YES;
  
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  label4.textAlignment = UITextAlignmentJustify;
#else
  label4.textAlignment = NSTextAlignmentJustified;
#endif
  [label4 setTextColor:[UIColor orangeColor]  range:[label4.text rangeOfString:@"Nimbus"]];
  [label4 setTextColor:[UIColor redColor]  range:[label4.text rangeOfString:@"accelerates"]];
  [label4 setFont:[UIFont boldSystemFontOfSize:22] range:[label4.text rangeOfString:@"iOS"]];
  [label4 setUnderlineStyle:kCTUnderlineStyleSingle modifier:kCTUnderlinePatternDash range:[label4.text rangeOfString:@"documentation"]];
  [label4 setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:17] range:[label4.text rangeOfString:@"Nimbus" options:NSBackwardsSearch]];
  [label4 addLink:[NSURL URLWithString:@"nimbus://custom/url"] range:[label4.text rangeOfString:@"easy"]];

  self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(label4.frame));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Link Selected" message:result.URL.relativeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  [alert show];
}


@end
