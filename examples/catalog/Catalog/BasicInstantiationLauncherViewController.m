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

#import "BasicInstantiationLauncherViewController.h"
#import "NimbusLauncher.h"

static NSString* const kButtonReuseIdentifier = @"button";

@interface BasicInstantiationLauncherViewController ()
@end

@implementation BasicInstantiationLauncherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Basic Instantiation";
//    NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.launcherView.backgroundColor = [UIColor underPageBackgroundColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

#pragma mark - NILauncherDataSource

- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView {
  return 2;
}

- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  return 9;
}

- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)index {
  NILauncherButtonView* buttonView = (NILauncherButtonView *)[launcherView dequeueReusableViewWithIdentifier:kButtonReuseIdentifier];
  if (nil == buttonView) {
    buttonView = [[NILauncherButtonView alloc] initWithReuseIdentifier:kButtonReuseIdentifier];
  }

  NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
  UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];
  if (nil == image) {
    image = [UIImage imageWithContentsOfFile:imagePath];
    [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];
  }

  [buttonView.button setImage:image forState:UIControlStateNormal];
  buttonView.label.text = @"App";
  buttonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
  buttonView.label.layer.shadowOffset = CGSizeMake(0, 1);
  buttonView.label.layer.shadowOpacity = 1;
  buttonView.label.layer.shadowRadius = 1;

  return buttonView;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectButton:(UIButton *)button onPage:(NSInteger)page atIndex:(NSInteger)index {
  NSLog(@"Did tap button %d on page %d", index, page);
}

@end
