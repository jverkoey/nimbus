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

#import "NIOverviewView.h"

#if defined(DEBUG) || defined(NI_DEBUG)

#import "NimbusCore.h"

#import "NIOverviewLogger.h"
#import "NIDeviceInfo.h"
#import "NIOverviewPageView.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIOverviewView()

- (CGFloat)pageHorizontalMargin;
- (CGRect)frameForPagingScrollView;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewView

@synthesize translucent = _translucent;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _pageViews = [[NSMutableArray alloc] init];

    _backgroundImage = [UIImage imageWithContentsOfFile:
                        NIPathForBundleResource(nil, @"NimbusOverviewer.bundle/gfx/blueprint.gif")];
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];

    _pagingScrollView = [[UIScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, self.pageHorizontalMargin,
                                                               0, self.pageHorizontalMargin);

    _pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                          | UIViewAutoresizingFlexibleHeight);

    [self addSubview:_pagingScrollView];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePages)
                                                 name:NIOverviewLoggerDidAddDeviceLog
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NIOverviewLoggerDidAddDeviceLog
                                                object:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Page Layout


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageHorizontalMargin {
  return 10;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPagingScrollView {
  CGRect frame = self.bounds;

  // We make the paging scroll view a little bit wider on the side edges so that there
  // there is space between the pages when flipping through them.
  frame.origin.x -= self.pageHorizontalMargin;
  frame.size.width += (2 * self.pageHorizontalMargin);

  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSizeForPagingScrollView {
  CGRect bounds = _pagingScrollView.bounds;
  return CGSizeMake(bounds.size.width * [_pageViews count], bounds.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPageAtIndex:(NSInteger)pageIndex {
  // We have to use our paging scroll view's bounds, not frame, to calculate the page
  // placement. When the device is in landscape orientation, the frame will still be in
  // portrait because the pagingScrollView is the root view controller's view, so its
  // frame is in window coordinate space, which is never rotated. Its bounds, however,
  // will be in landscape because it has a rotation transform applied.
  CGRect bounds = _pagingScrollView.bounds;
  CGRect pageFrame = bounds;

  // We need to counter the extra spacing added to the paging scroll view in
  // frameForPagingScrollView:
  pageFrame.size.width -= self.pageHorizontalMargin * 2;
  pageFrame.origin.x = (bounds.size.width * pageIndex) + self.pageHorizontalMargin;

  return pageFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutPages {
  _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

  for (NSUInteger ix = 0; ix < [_pageViews count]; ++ix) {
    UIView* pageView = [_pageViews objectAtIndex:ix];
    pageView.frame = [self frameForPageAtIndex:ix];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)visiblePageIndex {
  CGFloat offset = _pagingScrollView.contentOffset.x;
  CGFloat pageWidth = _pagingScrollView.bounds.size.width;

  return (NSInteger)(offset / pageWidth);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBounds:(CGRect)bounds {
  NSInteger visiblePageIndex = [self visiblePageIndex];

  [super setBounds:bounds];

  [self layoutPages];

  CGFloat pageWidth = _pagingScrollView.bounds.size.width;
  CGFloat newOffset = (visiblePageIndex * pageWidth);
  _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)frame {
  NSInteger visiblePageIndex = [self visiblePageIndex];
  
  [super setFrame:frame];
  
  [self layoutPages];
  
  CGFloat pageWidth = _pagingScrollView.bounds.size.width;
  CGFloat newOffset = (visiblePageIndex * pageWidth);
  _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTranslucent:(BOOL)translucent {
  if (_translucent != translucent) {
    _translucent = translucent;

    _pagingScrollView.indicatorStyle = (_translucent
                                        ? UIScrollViewIndicatorStyleWhite
                                        : UIScrollViewIndicatorStyleDefault);

    self.backgroundColor = (_translucent
                            ? [UIColor colorWithWhite:0 alpha:0.5f]
                            : [UIColor colorWithPatternImage:_backgroundImage]);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prependPageView:(NIOverviewPageView *)page {
  [_pageViews insertObject:page atIndex:0];
  [_pagingScrollView addSubview:page];

  [self layoutPages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addPageView:(NIOverviewPageView *)page {
  [_pageViews addObject:page];
  [_pagingScrollView addSubview:page];

  [self layoutPages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removePageView:(NIOverviewPageView *)page {
  [_pageViews removeObject:page];
  [page removeFromSuperview];

  [self layoutPages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePages {
  for (NIOverviewPageView* pageView in _pageViews) {
    [pageView update];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flashScrollIndicators {
  [_pagingScrollView flashScrollIndicators];
}


@end

#endif
