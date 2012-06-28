//
// Copyright 2012 Manu Cornet
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

#import "VerticalPagingScrollViewController.h"

#import "SamplePageView.h"
#import "NimbusPagingScrollView.h"

static NSString* const kPageReuseIdentifier = @"SamplePageIdentifier";

@interface VerticalPagingScrollViewController () <NIPagingScrollViewDataSource>
@property (nonatomic, readwrite, retain) NIPagingScrollView* pagingScrollView;
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

  self.view.backgroundColor = [UIColor blackColor];

  self.pagingScrollView = [[NIVerticalPagingScrollView alloc] initWithFrame:self.view.bounds];
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
  
  // The paging scroll view implements autorotation internally so that the current visible page
  // index is maintained correctly. It also provides an opportunity for each visible page view to
  // maintain zoom information correctly.
  [self.pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  
  // The second part of the paging scroll view's autorotation functionality. Both of these methods
  // must be called in order for the paging scroll view to rotate itself correctly.
  [self.pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                          duration:duration];
}

// The paging scroll view data source works similarly to UITableViewDataSource. We will return
// the total number of pages in the scroll view as well as each page as it is about to be displayed.
#pragma mark - NIPagingScrollViewDataSource

- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  // For the sake of this example we'll show a fixed number of pages.
  return 10;
}

// Similar to UITableViewDataSource, we create each page view on demand as the user is scrolling
// through the page view.
// Unlike UITableViewDataSource, this method requests a UIView that conforms to a protocol, rather
// than requiring a specific subclass of a type of view. This allows you to use any UIView as long
// as it conforms to NIPagingScrollView.
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
  // Check the reusable page queue.
  SamplePageView *page = (SamplePageView *)[pagingScrollView dequeueReusablePageWithIdentifier:kPageReuseIdentifier];
  // If no page was in the reusable queue, we need to create one.
  if (nil == page) {
    page = [[SamplePageView alloc] initWithReuseIdentifier:kPageReuseIdentifier];
  }
  return page;
}

@end
