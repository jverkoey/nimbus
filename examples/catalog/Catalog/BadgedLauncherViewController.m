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

#import "BadgedLauncherViewController.h"

#import "BadgedLauncherButtonView.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This controller shows the use of two separate Nimbus features: [launcher] and [badge]. We've
// created a subclass of NILauncherViewObject and NILauncherButtonView called
// BadgedLauncherViewObject and BadgedLauncherButtonView, respectively. You can find these classes
// in BadgedLauncherButtonView.h/m. These subclasses allow us to provide a badge number for the
// launcher button and then display this badge in the launcher button's top right corner.
//
// A badged launcher button is not part of Nimbus itself because it depends on two independent
// Nimbus features. This sort of composite functionality generally does not get added directly to
// Nimbus.
//
// You will find the following Nimbus features used:
//
// [badge]
// NIBadgeView
//
// [launcher]
// NILauncherViewController
// NILauncherViewModel
// NILauncherViewModelDelegate
// NILauncherDataSource
// NILauncherDelegate
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// QuartzCore.framework
//

@interface BadgedLauncherViewController () <NILauncherViewModelDelegate>
@property (nonatomic, retain) NILauncherViewModel* model;
@end

@implementation BadgedLauncherViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Badges";

    // Load the Nimbus app icon.
    NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
    UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];
    if (nil == image) {
      image = [UIImage imageWithContentsOfFile:imagePath];
      [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];
    }

    // We can provide different launcher objects in the model to show different types of launcher
    // buttons. In this example we'll mix the default NILauncherViewObject with
    // BadgedLauncherViewObject, which displays a launcher button with a badge number.
    NSArray* contents =
    [NSArray arrayWithObjects:
     [NSArray arrayWithObjects:
      // Shows a button with a badge showing the number 12.
      [BadgedLauncherViewObject objectWithTitle:@"Nimbus" image:image badgeNumber:12],
      [NILauncherViewObject objectWithTitle:@"Nimbus 2" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 3" image:image],

      // Will not display a badge because the number is 0.
      [BadgedLauncherViewObject objectWithTitle:@"Nimbus 4" image:image badgeNumber:0],

      // The badge number will become @"99+".
      [BadgedLauncherViewObject objectWithTitle:@"Nimbus 6" image:image badgeNumber:103],
      nil],
     nil];

    _model = [[NILauncherViewModel alloc] initWithArrayOfPages:contents delegate:self];
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

  self.launcherView.dataSource = self.model;
}

#pragma mark - NILauncherViewModelDelegate

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object {
  // BadgedLauncherViewObject is a subclass of NILauncherButtonView so we can still safely cast
  // without worrying about crashes.
  NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;

  launcherButtonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
  launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
  launcherButtonView.label.layer.shadowOpacity = 1;
  launcherButtonView.label.layer.shadowRadius = 1;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
  id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];

  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                  message:[@"Did tap button with title: " stringByAppendingString:object.title]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

@end
