//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import "NILauncherView.h"

const NSInteger NILauncherViewDynamic = -1;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherView

@synthesize maxNumberOfButtonsPerPage = _maxNumberOfButtonsPerPage;

@synthesize delegate    = _delegate;
@synthesize dataSource  = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pager);
  NI_RELEASE_SAFELY(_scrollView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _maxNumberOfButtonsPerPage = NILauncherViewDynamic;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces = YES;

    [self addSubview:_scrollView];

    _pager = [[UIPageControl alloc] init];

    // So, this is weird. Apparently if you don't set a background color on the pager control
    // then taps won't be handled anywhere but within the dot area. If you do set a background
    // color, however, then taps outside of the dot area DO change the selected page.
    //                  Kirby is confused \(o.o)/
    _pager.backgroundColor = [UIColor blackColor];

    // Hide the pager when there is only one page.
    _pager.hidesForSinglePage = YES;

    // Don't update the pager when the user taps until we've handled the tap ourselves.
    // This allows us to reset the page index forcefully if necessary without flickering the
    // pager's current selection.
    _pager.defersCurrentPageDisplay = YES;

    // When the user taps the pager control it fires a UIControlEventValueChanged notification.
    [_pager addTarget: self
               action: @selector(pageChanged:)
     forControlEvents: UIControlEventValueChanged];

    [self addSubview:_pager];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageWidthForLauncherFrame:(CGRect)frame {
  return frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];

  // TODO: Recalculate the rows and columns here using the data source if the methods are
  // implemented or dynamic calculations otherwise.

  [_pager sizeToFit];
  _pager.frame = CGRectMake(0, self.frame.size.height - _pager.frame.size.height,
                            self.frame.size.width,
                            _pager.frame.size.height);

  CGFloat pageWidth = [self pageWidthForLauncherFrame:self.frame];

  _scrollView.frame = CGRectMake(0, 0,
                                 pageWidth,
                                 self.frame.size.height - _pager.frame.size.height);

  _scrollView.contentSize = CGSizeMake(pageWidth * _numberOfPages,
                                       _scrollView.frame.size.height);

  _scrollView.contentOffset = CGPointMake([self pageWidthForLauncherFrame:frame]
                                          * _pager.currentPage,
                                          0);

  NSInteger ixPage = 0;
  for (UIView* subview in _scrollView.subviews) {
    if (subview.tag == 1337) {
      subview.frame = NIRectInset(CGRectMake(ixPage * pageWidth, 0,
                                             pageWidth, _scrollView.frame.size.height),
                                  UIEdgeInsetsMake(10, 10, 10, 10));
      ixPage++;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePageIndex {
  CGFloat pageWidth = _scrollView.frame.size.width;
  NSInteger pageIndex = roundf(_scrollView.contentOffset.x / pageWidth);
  _pager.currentPage = pageIndex;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self updatePageIndex];
  } // otherwise we update the page index when the scroll finishes decelerating.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self updatePageIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIPageControl Change Notifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pageChanged:(UIPageControl*)pager {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.2];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationBeginsFromCurrentState:YES];

  _scrollView.contentOffset = CGPointMake([self pageWidthForLauncherFrame:self.frame]
                                          * _pager.currentPage,
                                          _scrollView.contentOffset.y);

  [UIView commitAnimations];

  // Once we've handled the page change notification, notify the pager that it's ok to update
  // the page display.
  [_pager updateCurrentPageDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  _numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];

  _pager.numberOfPages = _numberOfPages;

  // TODO: Remember the current page?

  _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _numberOfPages,
                                       _scrollView.frame.size.height);

  // TODO: Consider turning this into a core method.
  for (UIView* subview in _scrollView.subviews) {
    if (subview.tag == 1337) {
      [subview removeFromSuperview];
    }
  }

  for (NSInteger ix = 0; ix < _numberOfPages; ++ix) {
    UIView* square = [[[UIView alloc] init] autorelease];
    square.tag = 1337;
    square.backgroundColor = [UIColor colorWithRed:((CGFloat)(rand()%255) / 255)
                                             green:((CGFloat)(rand()%255) / 255)
                                              blue:((CGFloat)(rand()%255) / 255)
                                             alpha:1];
    [_scrollView addSubview:square];
  }
}


@end
