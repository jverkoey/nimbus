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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pages);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    _pages = [[NSMutableArray alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  _launcherView = [[[NILauncherView alloc] initWithFrame:self.view.bounds] autorelease];
  _launcherView.dataSource = self;
  _launcherView.delegate = self;
  [self.view addSubview:_launcherView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _launcherView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NILauncherDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInLauncherView:(NILauncherView *)launcherView {
  return [_pages count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)launcherView:(NILauncherView *)launcherView numberOfButtonsInPage:(NSInteger)page {
  return [[_pages objectAtIndex:page] count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NILauncherButton *)launcherView: (NILauncherView *)launcherView
                     buttonForPage: (NSInteger)page
                           atIndex: (NSInteger)index {
  NILauncherButton* button = [[[NILauncherButton alloc] init] autorelease];

  NILauncherItemDetails* item = [[_pages objectAtIndex:page] objectAtIndex:index];
  item = item;

  return button;
}


@end
