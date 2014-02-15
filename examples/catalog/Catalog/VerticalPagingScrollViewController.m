//
// Copyright 2012 Manu Cornet
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

#import "VerticalPagingScrollViewController.h"

#import "SamplePageView.h"
#import "NimbusPagingScrollView.h"

//
// What's going on in this file:
//
// This controller demonstrates how to create a vertical paging scroll view by simply changing the
// type of the paging scroll view instance to NIPagingScrollViewVertical.
//
// You will find the following Nimbus features used:
//
// [pagingscrollview]
// NIPagingScrollView
// NIPagingScrollViewDataSource
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

static NSString* const kPageReuseIdentifier = @"SamplePageIdentifier";

@interface VerticalPagingScrollViewController () <NIPagingScrollViewDataSource>
@property (nonatomic, retain) NIPagingScrollView* pagingScrollView;
@end

@implementation VerticalPagingScrollViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Vertical Scroll View";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // iOS 7-only.
  if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }
  self.view.backgroundColor = [UIColor blackColor];

  self.pagingScrollView = [[NIPagingScrollView alloc] initWithFrame:self.view.bounds];

  // This is the only change from the BasicInstantiation example.
  self.pagingScrollView.type = NIPagingScrollViewVertical;

  self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  self.pagingScrollView.dataSource = self;
  [self.view addSubview:self.pagingScrollView];
  [self.pagingScrollView reloadData];
}

- (void)didReceiveMemoryWarning {
  self.pagingScrollView = nil;
  
  [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NIIsSupportedOrientation(interfaceOrientation);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                          duration:duration];
}

#pragma mark - NIPagingScrollViewDataSource

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  return 10;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
  SamplePageView *page = (SamplePageView *)[pagingScrollView dequeueReusablePageWithIdentifier:kPageReuseIdentifier];
  if (nil == page) {
    page = [[SamplePageView alloc] initWithReuseIdentifier:kPageReuseIdentifier];
  }
  return page;
}

@end
