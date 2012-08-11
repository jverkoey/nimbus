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

#import "NILauncherViewController.h"
#import "NILauncherView.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NILauncherViewController()
@property (nonatomic, readwrite, assign) BOOL shouldReloadData;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherViewController

@synthesize shouldReloadData = _shouldReloadData;
@synthesize launcherView = _launcherView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.launcherView = [[NILauncherView alloc] initWithFrame:self.view.bounds];
  self.launcherView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  self.launcherView.dataSource = self;
  self.launcherView.delegate = self;

  self.view = self.launcherView;

  self.shouldReloadData = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  self.launcherView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.view && self.shouldReloadData) {
    [self.launcherView reloadData];
    self.shouldReloadData = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.launcherView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.launcherView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NILauncherDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NILauncherButtonView> *)launcherView:(NILauncherView *)launcherView buttonViewForPage:(NSInteger)page atIndex:(NSInteger)buttonIndex {
  return nil;
}


@end
