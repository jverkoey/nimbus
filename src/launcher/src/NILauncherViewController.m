//
// Copyright 2011 Jeff Verkoeyen
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherViewController

@synthesize launcherView  = _launcherView;
@synthesize pages         = _pages;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pages);
  // _launcherView is retained by self.view and is released in viewDidUnload

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  _launcherView = [[[NILauncherView alloc] initWithFrame:self.view.bounds] autorelease];
  _launcherView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                    | UIViewAutoresizingFlexibleHeight);
  _launcherView.dataSource = self;
  _launcherView.delegate = self;
  [_launcherView reloadData];
  [self.view addSubview:_launcherView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _launcherView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NILauncherDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfRowsPerPageInLauncherView:(NILauncherView *)launcherView {
  // Replace this with NILauncherViewDynamic to allow the launcher view to calculate the number
  // of rows and columns automatically.
  return (NIIsPad()
          ? 4
          : (UIInterfaceOrientationIsPortrait(NIInterfaceOrientation())
             ? 3 : 2));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfColumnsPerPageInLauncherView:(NILauncherView *)launcherView {
  return (NIIsPad()
          ? 5
          : (UIInterfaceOrientationIsPortrait(NIInterfaceOrientation())
             ? 3 : 5));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView {
  return [_pages count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  return [[_pages objectAtIndex:page] count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIButton *)launcherView: (NILauncherView *)launcherView
             buttonForPage: (NSInteger)page
                   atIndex: (NSInteger)index {
  NILauncherButton* button = [[[NILauncherButton alloc] init] autorelease];

  NILauncherItemDetails* item = [[_pages objectAtIndex:page] objectAtIndex:index];
  [button setTitle:item.title forState:UIControlStateNormal];
  [button setImage: [UIImage imageWithContentsOfFile:item.imagePath]
          forState: UIControlStateNormal];

  return button;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NILauncherDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)launcherView: (NILauncherView *)launcher
     didSelectButton: (UIButton *)button
              onPage: (NSInteger)page
             atIndex: (NSInteger)index {
  UIAlertView* alert =
  [[[UIAlertView alloc] initWithTitle: @"Launcher button tapped"
                              message: [button titleForState:UIControlStateNormal]
                             delegate: nil
                    cancelButtonTitle: nil
                    otherButtonTitles: @"OK", nil]
   autorelease];
  [alert show];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPages:(NSArray *)pages {
  if (_pages != pages) {
    [_pages release];
    _pages = [pages mutableCopy];

    // If the view hasn't been loaded yet (entirely possible) then this will no-op and the
    // launcher view will load its data in viewDidLoad.
    [_launcherView reloadData];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)pages {
  return [NSArray arrayWithArray:_pages];
}


@end
