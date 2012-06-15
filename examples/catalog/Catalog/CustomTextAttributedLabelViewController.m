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

#import "NSMutableAttributedString+NimbusAttributedLabel.h"

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
  @"For years our hero has explored the dark horizon. "
  @"At long last, a planet grows in the distance. "
  @"\"Hello world!\" she exclaims.";

  // Find the ranges of the two words so that we can style them individually.
  NSRange rangeOfHello = [string rangeOfString:@"Hello"];
  NSRange rangeOfWorld = [string rangeOfString:@"world!"];

  NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:string];

  // See http://iosfonts.com/ for a list of all fonts supported out of the box on iOS.
  UIFont* font = [UIFont fontWithName:@"Futura-MediumItalic" size:30];
  [text setFont:font range:rangeOfHello];
  [text setFont:font range:rangeOfWorld];
  [text setUnderlineStyle:kCTUnderlineStyleSingle
                 modifier:kCTUnderlinePatternSolid
                    range:rangeOfHello];
  [text setTextColor:[UIColor blueColor] range:rangeOfHello];

  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  label.attributedText = text;
  label.frame = CGRectInset(self.view.bounds, 20, 20);

  [self.view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
