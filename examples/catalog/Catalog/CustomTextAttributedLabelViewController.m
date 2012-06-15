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

#import "CustomTextAttributedLabelViewController.h"
#import "NimbusAttributedLabel.h"

// This import is not included by NimbusAttributedLabel.h because it is a category and we want to
// make it explicit that you are augmenting a class.
#import "NSMutableAttributedString+NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller shows how to create an NSAttributedString object, modify its style, and assign
// it to an NIAttributedLabel for display.
//
// You will find the following Nimbus features used:
//
// [attributedlabel]
// NIAttributedLabel
// NSMutableAttributedString additions (via NSMutableAttributedString+NimbusAttributedLabel.h).
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// CoreText.framework
// QuartzCore.framework
//

@implementation CustomTextAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Customizing Text";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSString* string =
  @"For 20 years she has ventured into the dark horizon. "
  @"At long last, a planet grows in the distance. "
  @"\"Hello world!\" she exclaims.";

  // We're going to customize the words "hello" and "world" in the string above to make them stand
  // out in our text.
  NSRange rangeOfHello = [string rangeOfString:@"Hello"];
  NSRange rangeOfWorld = [string rangeOfString:@"world!"];

  // We must create a mutable attributed string in order to set the CoreText properties.
  NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:string];

  // See http://iosfonts.com/ for a list of all fonts supported out of the box on iOS.
  UIFont* font = [UIFont fontWithName:@"Futura-MediumItalic" size:30];

  // The following set of methods are all category methods added by the [attributedlabel] feature.
  // Each method has a final argument for specifying a range. If you don't specify a range then the
  // modification will be applied to the entire string.
  [text setFont:font range:rangeOfHello];
  [text setFont:font range:rangeOfWorld];
  [text setUnderlineStyle:kCTUnderlineStyleSingle
                 modifier:kCTUnderlinePatternSolid
                    range:rangeOfHello];
  [text setTextColor:[UIColor redColor] range:rangeOfHello];

  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];

  // We want this label to wrap over multiple lines. With CoreText we have to use either word or
  // character wrapping in order to have a paragraph wrap over multiple lines. Truncation modes
  // will only work for single lines of text and would require us to explicitly break the lines up
  // with newline (\n) characters.
  label.numberOfLines = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  label.lineBreakMode = UILineBreakModeWordWrap;
#else
  label.lineBreakMode = NSLineBreakByWordWrapping;
#endif

  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  label.frame = CGRectInset(self.view.bounds, 20, 20);

  // When we assign the attributed text to the label it copies the attributed text object into the
  // label. If we want to make any further stylistic changes then we must either use the label's
  // methods or assign a modified attributed string object again.
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  label.attributedString = text;
#else
  label.attributedText = text;
#endif

  [self.view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
