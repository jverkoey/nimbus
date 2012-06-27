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

#import "PagingScrollViewController.h"

static NSString* kPageReuseIdentifier = @"SamplePageIdentifier";

@interface SamplePageView : UIView<NIPagingScrollViewPage> {
@private
  UILabel* _label;
  int _pageIndex;
  NSString* _reuseIdentifier;
}

- (void)renderForPageIndex:(int)pageIndex;

@end

@implementation SamplePageView

@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithFrame:(CGRect)frame {
  NSLog(@"Initing view %@", self);
  if ((self = [super initWithFrame:frame])) {
    _label = [[UILabel alloc] init];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.font = [UIFont systemFontOfSize:26];
    _label.textAlignment = UITextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];

    [self addSubview:_label];
  }
  return self;
}

- (void)renderForPageIndex:(int)pageIndex {
  _pageIndex = pageIndex;
  _label.text = [NSString stringWithFormat:@"This is page %i", pageIndex];

  UIColor* bgColor;
  UIColor* textColor;
  // Change the background and text color depending on the index.
  switch (pageIndex % 4) {
    case 0:
      bgColor = [UIColor redColor];
      textColor = [UIColor whiteColor];
      break;
    case 1:
      bgColor = [UIColor blueColor];
      textColor = [UIColor whiteColor];
      break;
    case 2:
      bgColor = [UIColor yellowColor];
      textColor = [UIColor blackColor];
      break;
    case 3:
      bgColor = [UIColor greenColor];
      textColor = [UIColor blackColor];
      break;
  }
  self.backgroundColor = bgColor;
  _label.textColor = textColor;
  [self setNeedsLayout];
}

- (void)prepareForReuse {
  _label.text = @"";
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation PagingScrollViewController

#pragma mark -
#pragma mark UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor blackColor];
  _pagingScrollView = [[NIPagingScrollView alloc] initWithFrame:self.view.bounds];
  _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
      UIViewAutoresizingFlexibleHeight;
  _pagingScrollView.delegate = self;
  _pagingScrollView.dataSource = self;
  _pagingScrollView.backgroundColor = [UIColor yellowColor];
  [self.view addSubview:_pagingScrollView];
  [_pagingScrollView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [_pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [_pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                                      duration:duration];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPagingScrollViewDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  return 10;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
  SamplePageView *page =
      (SamplePageView*)[pagingScrollView dequeueReusablePageWithIdentifier:kPageReuseIdentifier];
  if (!page) {
    NSLog(@"Page doesn't exist, creating it");
    page = [[SamplePageView alloc] initWithFrame:CGRectZero];
    page.reuseIdentifier = kPageReuseIdentifier;
  }
  NSLog(@"Setting page text to %i", pageIndex);
  [page renderForPageIndex:pageIndex];
  return page;
}

@end
