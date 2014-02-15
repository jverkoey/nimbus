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

#import "BasicInstantiationLauncherViewController.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This controller shows a simple subclass implementation of NILauncherViewController and the
// NILauncherDataSource and NILauncherDelegate protocol methods. This controller shows a single
// page of four launcher icons and handles selection notifications by showing an alert view.
//
// You will find the following Nimbus features used:
//
// [launcher]
// NILauncherViewController
// NILauncherDataSource
// NILauncherDelegate
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// QuartzCore.framework
//

// The reuse identifier for buttons in the launcher view.
static NSString* const kButtonReuseIdentifier = @"button";

@implementation BasicInstantiationLauncherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Basic Instantiation";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // iOS 7-only.
  if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }

  self.view.backgroundColor = [UIColor underPageBackgroundColor];
}

// Similar to UITableViewController, NILauncherViewController automatically sets the dataSource and
// delegate properties of self.launcherView to self. We simply have to implement the methods and
// the launcher view will do the rest.
#pragma mark - NILauncherDataSource

- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  // For the purposes of this simple example we are going to return a constant number of identical
  // buttons.
  return 4;
}

// This method works exactly like UITableViewDataSource's tableView:cellForRowAtIndexPath:. The
// basic principal is to try to fetch a reusable view from the launcher view's recyclable view
// queue. If no reusable view is available, we create one. We then configure the view for being
// displayed and return the view object.
- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)index {

  // Start by attempting to dequeue a reusable view from the launcher view. Note that since we're
  // only going to create and return NILauncherButtonView views, so we can safely cast to
  // NILauncherButtonView without type checking first.
  NILauncherButtonView* buttonView = (NILauncherButtonView *)[launcherView dequeueReusableViewWithIdentifier:kButtonReuseIdentifier];

  // If the launcher view didn't have a reusable view then we will need to create one.
  if (nil == buttonView) {
    // We must create a UIView that conforms to the NILauncherButtonView protocol. Thankfully the
    // launcher features comes with a stock launcher view that we can use!
    buttonView = [[NILauncherButtonView alloc] initWithReuseIdentifier:kButtonReuseIdentifier];

    // We're going to load the Nimbus application icon and store it in the Nimbus image cache.
    NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");

    // Try to load it from memory first.
    UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];

    if (nil == image) {
      // The image wasn't in memory, so let's load it from disk.
      image = [UIImage imageWithContentsOfFile:imagePath];

      // And then store it in memory.
      [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];

      // The above logic of checking whether an image is in memory, loading it from disk when it's
      // not in memory, and then storing the image in memory is a common pattern that you should
      // consider using whenever loading static images throughout your application. Because the
      // Nimbus image memory cache implements an efficient least-recently-used cache it can expire
      // images that haven't been used recently when memory warnings are received.
    }

    // Add the image to the button view.
    [buttonView.button setImage:image forState:UIControlStateNormal];

    buttonView.label.text = @"Nimbus";

    // Configure our label to show a nice blurred text shadow.
    buttonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
    buttonView.label.layer.shadowOffset = CGSizeMake(0, 1);
    buttonView.label.layer.shadowOpacity = 1;
    buttonView.label.layer.shadowRadius = 1;
  }

  return buttonView;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                  message:
                        [NSString stringWithFormat:@"Did tap button index %d on page %d",
                         index, page]
                                          delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

@end
