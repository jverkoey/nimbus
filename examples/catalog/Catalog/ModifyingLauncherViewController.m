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

#import "ModifyingLauncherViewController.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This controller shows how to modify a NILauncherViewModel by adding new pages every time the +
// button is tapped.
//
// You will find the following Nimbus features used:
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

@interface ModifyingLauncherViewController () <NILauncherViewModelDelegate>
@property (nonatomic, retain) NILauncherViewModel* model;
@end

@implementation ModifyingLauncherViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Modifying";

    // We'll start off with a completely empty model.
    _model = [[NILauncherViewModel alloc] initWithArrayOfPages:nil delegate:self];

    // We want to add a button to the navigation bar that, when tapped, adds a new page of launcher
    // buttons to the launcher view.
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(didTapAddButton:)];
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

#pragma mark - User Actions

- (void)didTapAddButton:(UIBarButtonItem *)barButtonItem {
  // When the user taps the + button we are going to create a new page filled with a random number
  // of buttons with random titles.

  // Start by loading the Nimbus app icon.
  NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
  UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];
  if (nil == image) {
    image = [UIImage imageWithContentsOfFile:imagePath];
    [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];
  }

  // Now we create a page with 1-9 randomly titled objects.
  NSInteger randomNumberOfItems = arc4random_uniform(8) + 1;
  NSMutableArray* objects = [NSMutableArray array];
  for (NSInteger ix = 0; ix < randomNumberOfItems; ++ix) {
    [objects addObject:[NILauncherViewObject objectWithTitle:[NSString stringWithFormat:@"Nimbus %d", arc4random_uniform(1000)] image:image]];
  }

  // appendPage should be pretty self-explanatory.
  [self.model appendPage:objects];

  // Now that we've modified the model we need to reload the data for our changes to become visible.
  // The cool thing about Nimbus' launcher view is that it only reloads the visible data, so
  // reloadData is a relatively lightweight operation, just like UITableView.
  [self.launcherView reloadData];
}

@end
