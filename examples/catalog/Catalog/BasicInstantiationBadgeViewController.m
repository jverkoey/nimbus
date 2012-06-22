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

#import "BasicInstantiationBadgeViewController.h"
#import "NimbusBadge.h"

//
// What's going on in this file:
//
// This controller shows how to instantiate a simple NIBadgeView and add it to a view hierarchy.
// Within this example we also show that you should call sizeToFit to properly size the NIBadgeView
// after it has been instantiated.
//
// You will find the following Nimbus features used:
//
// [badge]
// NIBadgeView
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@implementation BasicInstantiationBadgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Basic Instantiation";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // The default view background color is transparent, so let's make sure the badge view has a
  // non-transparent background color when we assign it further down.
  self.view.backgroundColor = [UIColor whiteColor];

  // We don't know what the initial frame will be, so pass the empty rect.
  NIBadgeView* badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];

  // Avoid using transparency whenever possible. The badgeView backgroundColor is black by default.
  badgeView.backgroundColor = self.view.backgroundColor;

  // We can set any arbitrary text to the badge view.
  badgeView.text = @"7";

  // Once we've set the text we allow the badge view to size itself to fit the contents of the
  // text. If we wanted to we could explicitly set the frame of the badge view to something larger,
  // but in nearly all cases the sizeToFit rect will be the one you want to use.
  [badgeView sizeToFit];

  [self.view addSubview:badgeView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
