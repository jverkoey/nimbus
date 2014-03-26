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

#import "LongTapAttributedLabelViewController.h"

#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller shows how to disable long taps in attributed labels.
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

@interface LongTapAttributedLabelViewController () <NIAttributedLabelDelegate>
@end

@implementation LongTapAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Long Tap";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // iOS 7-only.
  if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
  self.view.backgroundColor = [UIColor whiteColor];

  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.numberOfLines = 0;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  label.frame = CGRectInset(self.view.bounds, 20, 20);
  label.font = [UIFont fontWithName:@"AmericanTypewriter" size:15];
  label.delegate = self;
  label.autoDetectLinks = YES;

  label.text = @"Nimbus' latest documentation is always available at http://latest.docs.nimbuskit.info/";

  [self.view addSubview:label];
}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  [[UIApplication sharedApplication] openURL:result.URL];
}

- (BOOL)attributedLabel:(NIAttributedLabel *)attributedLabel shouldPresentActionSheet:(UIActionSheet *)actionSheet withTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
  // Returning NO here will disable the long-tap action sheet from appearing.
  return NO;
}

@end
