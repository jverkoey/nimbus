//
// Copyright 2012 Edward Euan Lau
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

#import "NavigationAppearanceViewController.h"

#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a simple example of changing the navigation / status bar appearance when pushing
// a new controller to the navigation controller. To change the appearance, you need to push
// a NIAppearanceSnapshot to the appearance stack when the view appears. You also need to 
// restore the appearance snapshot when the view disappears.
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@implementation NavigationAppearanceViewController

@synthesize changeBarStyle;
@synthesize changeTintColor;
@synthesize changeBackgroundImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Navigation Appearance";
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Push the current navigation bar appearance onto the stack
  [NINavigationAppearance pushAppearanceForNavigationController:self.navigationController];

  // Change the navigation bar style if desired
  if (self.changeBarStyle) {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.translucent = YES;
  }
  
  // Change the navigation bar tint color if desired
  if (self.changeTintColor) {
    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
  }
  
  // Change the navigation bar background image if desired
  if (self.changeBackgroundImage) {
    // Background image can be changed in iOS 5 or later.
    if ([self.navigationController.navigationBar 
         respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
      [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar"]
                                                    forBarMetrics:UIBarMetricsDefault];
    }
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  // Restore the original navigation bar appearance by popping the stack
  [NINavigationAppearance popAppearanceForNavigationController:self.navigationController 
                                                      animated:animated];
}

@end
