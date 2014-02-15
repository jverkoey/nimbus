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

#import "ModelLauncherViewController.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This controller shows how to use NILauncherViewModel to store the launcher object information.
// This model object greatly simplifies your interactions with the launcher view data source
// compared to the BasicIntantiation launcher example.
//
// This example shows how to create a model that lasts the lifetime of this controller and never
// changes. In the Modifying example you will learn how to modify the model by adding more pages to
// it.
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
//

@interface ModelLauncherViewController () <NILauncherViewModelDelegate>
@property (nonatomic, retain) NILauncherViewModel* model;
@end

@implementation ModelLauncherViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Model";

    // Load the Nimbus app icon.
    NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
    UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];
    if (nil == image) {
      image = [UIImage imageWithContentsOfFile:imagePath];
      [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];
    }

    // We populate the launcher model with an array of arrays of NILauncherViewObject objects.
    // Each sub array is a single page of the launcher view. The default NILauncherViewObject object
    // allows you to provide a title and image.
    NSArray* contents =
    [NSArray arrayWithObjects:
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Nimbus" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 2" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 3" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 5" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 6" image:image],
      nil],

     // A new page.
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Page 2" image:image],
      nil],

     // A third page.
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Page 3" image:image],
      nil],
     nil];

    // Create the model object with the contents array. We provide self as the delegate so that
    // we can customize what the buttons look like.
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

  // Because the model implements the NILauncherViewDataSource protocol we can simply assign the
  // model to the dataSource property and everything will magically work. Wicked!
  self.launcherView.dataSource = self.model;
}

#pragma mark - NILauncherViewModelDelegate

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object {

  // The NILauncherViewObject object always creates a NILauncherButtonView so we can safely cast
  // here and update the label's style to add the nice blurred shadow we saw in the
  // BasicInstantiation example.
  NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;

  launcherButtonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
  launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
  launcherButtonView.label.layer.shadowOpacity = 1;
  launcherButtonView.label.layer.shadowRadius = 1;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
  // Now that we're using a model we can easily refer back to which object was selected when we
  // receive a selection notification.
  id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];

  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                  message:[@"Did tap button with title: " stringByAppendingString:object.title]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

@end
