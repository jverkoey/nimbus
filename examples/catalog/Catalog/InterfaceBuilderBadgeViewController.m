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

#import "InterfaceBuilderBadgeViewController.h"
#import "NimbusBadge.h"

//
// What's going on in this file:
//
// This controller shows how to add NIBadgeViews to a xib file and configure them from within
// Interface Builder (IB).
//
// To add a NIBadgeView to IB you will need to add a UIView object and specify NIBadgeView as the
// subclass.
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

@interface InterfaceBuilderBadgeViewController ()
@property (nonatomic, retain) IBOutlet NIBadgeView* badgeView;
@property (nonatomic, retain) IBOutlet NIBadgeView* badgeView2;
@end

@implementation InterfaceBuilderBadgeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:@"ApplicationBadges" bundle:nibBundleOrNil])) {
    self.title = @"Interface Builder";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // iOS 7-only.
  if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }

  self.badgeView.text = @"2";
  self.badgeView2.text = @"4";
  [self.badgeView sizeToFit];
  [self.badgeView2 sizeToFit];
}

@end
