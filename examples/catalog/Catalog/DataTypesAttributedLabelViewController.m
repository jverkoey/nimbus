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

#import "DataTypesAttributedLabelViewController.h"
#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller shows the various data types that an attributed label may display and handle.
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

@interface DataTypesAttributedLabelViewController() <NIAttributedLabelDelegate>
@end

@implementation DataTypesAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Data Types";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.numberOfLines = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  label.lineBreakMode = UILineBreakModeWordWrap;
#else
  label.lineBreakMode = NSLineBreakByWordWrapping;
#endif
  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  label.frame = CGRectInset(self.view.bounds, 20, 20);
  label.font = [UIFont fontWithName:@"Optima-Regular" size:20];
  label.delegate = self;
  label.autoDetectLinks = YES;

  // Turn on all available data detectors. This includes phone numbers, email addresses, and
  // addresses.
  label.dataDetectorTypes = NSTextCheckingAllSystemTypes;

  label.text = @"She presses a button next to the display and it flickers once more."
  @"\n\nUpon the arrival at Gliese 581 g, initiate contact with the following:"
  @"\n\nCall: 555-0131"
  @"\nEmail: hello@nimbuskit.info"
  @"\nMail: 123 Nimbus Ln.";

  [self.view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  NSURL* url = nil;

  // We can receive many different types of data types now, so we have to handle each one a little
  // differently.
  if (NSTextCheckingTypePhoneNumber == result.resultType) {
    // Opens the phone app if it exists.
    url = [NSURL URLWithString:[@"tel://" stringByAppendingString:result.phoneNumber]];

  } else if (NSTextCheckingTypeLink == result.resultType) {
    // Simply open the URL that was tapped. emails count as URLs as well and are automatically
    // prefixed with @"mailto:".
    url = result.URL;

  } else if (NSTextCheckingTypeAddress == result.resultType) {
    // Open the Maps application or Safari if the maps application isn't installed.
    url = [NSURL URLWithString:[@"http://maps.google.com/maps?q=" stringByAppendingString:[[result.addressComponents objectForKey:NSTextCheckingStreetKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
  }

  if (nil != url) {
    if (![[UIApplication sharedApplication] openURL:url]) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:[@"No application was found that could open this url: " stringByAppendingString:url.absoluteString]
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
    }

  } else {
    NSLog(@"Unsupported data type");
  }
}

@end
