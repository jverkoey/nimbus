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

#import "CustomizingBadgesViewController.h"
#import "NimbusBadge.h"

//
// What's going on in this file:
//
// This controller shows how to customize the various NIBadgeView attributes.
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

@implementation CustomizingBadgesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Customizing Badges";
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

  NIBadgeView* badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
  badgeView.backgroundColor = self.view.backgroundColor;
  badgeView.text = @"White on blue";
  badgeView.tintColor = [UIColor blueColor];
  [badgeView sizeToFit];
  [self.view addSubview:badgeView];
  
  NIBadgeView* badgeView2 = [[NIBadgeView alloc] initWithFrame:CGRectZero];
  badgeView2.backgroundColor = self.view.backgroundColor;
  badgeView2.text = @"Black on orange";
  badgeView2.tintColor = [UIColor orangeColor];
  badgeView2.textColor = [UIColor blackColor];
  [badgeView2 sizeToFit];
  badgeView2.frame = CGRectMake(CGRectGetMaxX(badgeView.frame), 0, badgeView2.frame.size.width, badgeView2.frame.size.height);
  [self.view addSubview:badgeView2];
  
  NIBadgeView* badgeView3 = [[NIBadgeView alloc] initWithFrame:CGRectZero];
  badgeView3.backgroundColor = self.view.backgroundColor;
  badgeView3.text = @"Tiny";
  badgeView3.font = [UIFont systemFontOfSize:12];
  [badgeView3 sizeToFit];
  badgeView3.frame = CGRectMake(0, CGRectGetMaxY(badgeView.frame), badgeView3.frame.size.width, badgeView3.frame.size.height);
  [self.view addSubview:badgeView3];

  NIBadgeView* badgeView4 = [[NIBadgeView alloc] initWithFrame:CGRectZero];
  badgeView4.backgroundColor = self.view.backgroundColor;
  badgeView4.text = @"Zapfino Huge";
  badgeView4.font = [UIFont fontWithName:@"Zapfino" size:30];
  [badgeView4 sizeToFit];
  badgeView4.frame = CGRectMake(0, CGRectGetMaxY(badgeView3.frame), badgeView4.frame.size.width, badgeView4.frame.size.height);
  [self.view addSubview:badgeView4];
}

@end
