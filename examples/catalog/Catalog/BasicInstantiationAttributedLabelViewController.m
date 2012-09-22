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

#import "BasicInstantiationAttributedLabelViewController.h"

#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This is a simple hello world example of the NIAttributedLabel object from the [attributedlabel]
// feature of Nimbus. It is a simple view controller that instantiates and styles a single
// NIAttributedLabel that says "Hello World!" with an orange stroke.
//
// You will find the following Nimbus features used:
//
// [core]
// UIViewAutoresizingFlexibleDimensions
// RGBCOLOR
// RGBACOLOR
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

@implementation BasicInstantiationAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Basic Instantiation";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // We create an NIAttributedLabel the same way we would a UILabel.
  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];

  // In practice we set the text before applying any CoreText style. Modifying the text after
  // setting the styles will clear any existing CoreText-specific styles.
  //
  // Peeking under the hood: NIAttributedLabel creates an NSMutableAttributedString object when we
  // set this text. The NSMutableAttributedString object is initially styled with whatever values
  // were set on the UILabel. For example, if we set the textColor to blue and then set the text to
  // @"Nimbus", the label would correctly display the text as blue. This allows you to treat
  // NIAttributedLabel as a UILabel but still easily be able to style its attributed string with
  // additional CoreText properties.
  label.text = @"An explorer's tale";

  // UIViewAutoresizingFlexibleDimensions is a Nimbus autoresizing mask that causes the view to
  // grow and shrink with its super view. When we want to a view to fill its super view this is
  // generally the mask that we'll use.
  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;

  // These are standard UILabel styles. We can set these whenever we like and the attributed label
  // will apply them to entire string even if we change the text again.
  label.font = [UIFont fontWithName:@"Zapfino" size:25];

  // Set the text color to the bright Nimbus orange. This will be the "fill" color when we specify
  // a negative stroke width below.
  label.textColor = RGBCOLOR(0xFF, 0x9F, 0x00);

  // Set a CoreText stroke color to a dark orange with 40% opacity.
  label.strokeColor = RGBACOLOR(0x93, 0x36, 0x00, 0.4);

  // A negative stroke width means that we also want to fill the stroke with the textColor.
  // A postiive stroke would leave the fill as the background color.
  label.strokeWidth = -3;

  // Fill the view with the label, but give the label a 20 pixel margins on all sides.
  label.frame = CGRectInset(self.view.bounds, 20, 20);

  [self.view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
