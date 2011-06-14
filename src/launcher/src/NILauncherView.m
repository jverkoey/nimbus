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

static const CGFloat kDefaultButtonDimensions = 80;
static const CGFloat kDefaultPadding          = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NILauncherView()

- (void)layoutPages;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherView

@synthesize maxNumberOfButtonsPerPage = _maxNumberOfButtonsPerPage;

@synthesize padding = _padding;

@synthesize delegate    = _delegate;
@synthesize dataSource  = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pager);
  NI_RELEASE_SAFELY(_scrollView);
  NI_RELEASE_SAFELY(_pagesOfButtons);
  NI_RELEASE_SAFELY(_pagesOfScrollViews);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _maxNumberOfButtonsPerPage = NILauncherViewDynamic;
    _padding = UIEdgeInsetsMake(kDefaultPadding, kDefaultPadding,
                                kDefaultPadding, kDefaultPadding);

    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.bounces = YES;

    [self addSubview:_scrollView];

    _pager = [[UIPageControl alloc] init];

    // So, this is weird. Apparently if you don't set a background color on the pager control
    // then taps won't be handled anywhere but within the dot area. If you do set a background
    // color, however, then taps outside of the dot area DO change the selected page.
    //                                  \(o.o)/
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
- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];

  _scrollView.backgroundColor = backgroundColor;
  _pager.backgroundColor = backgroundColor;
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

  [self layoutPages];

  [[_pagesOfScrollViews objectAtIndex:_pager.currentPage] flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updatePageIndex {
  CGFloat pageWidth = _scrollView.frame.size.width;
  NSInteger pageIndex = roundf(_scrollView.contentOffset.x / pageWidth);
  _pager.currentPage = pageIndex;

  [[_pagesOfScrollViews objectAtIndex:pageIndex] flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)calculateLayoutForFrame: (CGRect)frame
               buttonDimensions: (CGSize *)pButtonDimensions
                   numberOfRows: (NSInteger *)pNumberOfRows
                numberOfColumns: (NSInteger *)pNumberOfColumns
        buttonHorizontalSpacing: (CGFloat *)pButtonHorizontalSpacing
          buttonVerticalSpacing: (CGFloat *)pButtonVerticalSpacing {
  NIDASSERT(nil != pButtonDimensions);
  NIDASSERT(nil != pNumberOfRows);
  NIDASSERT(nil != pNumberOfColumns);
  NIDASSERT(nil != pButtonHorizontalSpacing);
  NIDASSERT(nil != pButtonVerticalSpacing);
  if (nil == pButtonDimensions
      || nil == pNumberOfRows
      || nil == pNumberOfColumns
      || nil == pButtonHorizontalSpacing
      || nil == pButtonVerticalSpacing) {
    return;
  }
  CGFloat pageWidth = frame.size.width - _padding.left - _padding.right;
  CGFloat pageHeight = frame.size.height - _padding.top - _padding.bottom;

  CGSize buttonDimensions = CGSizeMake(kDefaultButtonDimensions, kDefaultButtonDimensions);
  if ([self.dataSource respondsToSelector:@selector(buttonDimensionsInLauncherView:)]) {
    CGSize dataSourceButtonDimensions = [self.dataSource buttonDimensionsInLauncherView:self];

    NIDASSERT(dataSourceButtonDimensions.width > 0 && dataSourceButtonDimensions.height > 0);
    if (dataSourceButtonDimensions.width > 0 && dataSourceButtonDimensions.height > 0) {
      buttonDimensions = dataSourceButtonDimensions;
    }
  }

  NSInteger numberOfColumns = NILauncherViewDynamic;
  NSInteger numberOfRows = NILauncherViewDynamic;

  if ([self.dataSource respondsToSelector:@selector(numberOfColumnsPerPageInLauncherView:)]) {
    numberOfColumns = [self.dataSource numberOfColumnsPerPageInLauncherView:self];
  }
  if ([self.dataSource respondsToSelector:@selector(numberOfRowsPerPageInLauncherView:)]) {
    numberOfRows = [self.dataSource numberOfRowsPerPageInLauncherView:self];
  }

  if (NILauncherViewDynamic == numberOfColumns) {
    numberOfColumns = floorf(pageWidth / buttonDimensions.width);
  }
  if (NILauncherViewDynamic == numberOfRows) {
    numberOfRows = floorf(pageHeight / buttonDimensions.height);
  }
  NIDASSERT(numberOfRows > 0);
  NIDASSERT(numberOfColumns > 0);
  numberOfRows = MAX(1, numberOfRows);
  numberOfColumns = MAX(1, numberOfColumns);

  CGFloat totalButtonWidth = numberOfColumns * buttonDimensions.width;
  CGFloat buttonHorizontalSpacing = 0;
  if (numberOfColumns > 1) {
    buttonHorizontalSpacing = floorf((pageWidth - totalButtonWidth) / (numberOfColumns - 1));
  }
  CGFloat totalButtonHeight = numberOfRows * buttonDimensions.height;
  CGFloat buttonVerticalSpacing = 0;
  if (numberOfRows > 1) {
    buttonVerticalSpacing = floorf((pageHeight - totalButtonHeight) / (numberOfRows - 1));
  }

  *pButtonDimensions = buttonDimensions;
  *pNumberOfRows = numberOfRows;
  *pNumberOfColumns = numberOfColumns;
  *pButtonHorizontalSpacing = buttonHorizontalSpacing;
  *pButtonVerticalSpacing = buttonVerticalSpacing;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutPages {
  if (nil == _scrollView || CGRectIsEmpty(_scrollView.frame)) {
    // Bail out early; the scroll view hasn't been laid out yet.
    return;
  }

  CGSize buttonDimensions = CGSizeZero;
  NSInteger numberOfRows = 0;
  NSInteger numberOfColumns = 0;
  CGFloat buttonHorizontalSpacing = 0;
  CGFloat buttonVerticalSpacing = 0;
  [self calculateLayoutForFrame: _scrollView.frame
               buttonDimensions: &buttonDimensions
                   numberOfRows: &numberOfRows
                numberOfColumns: &numberOfColumns
        buttonHorizontalSpacing: &buttonHorizontalSpacing
          buttonVerticalSpacing: &buttonVerticalSpacing];

  NIDASSERT(numberOfRows > 0);
  NIDASSERT(numberOfColumns > 0);

  CGFloat pageWidth = _scrollView.frame.size.width;

  for (NSInteger ixPage = 0; ixPage < [_pagesOfButtons count]; ++ixPage) {
    CGFloat pageOffset = ixPage * pageWidth;

    NSArray* page = [_pagesOfButtons objectAtIndex:ixPage];

    CGFloat pageBottom = 0;

    for (NSInteger ixItem = 0; ixItem < [page count]; ++ixItem) {
      NSInteger col = ixItem % numberOfColumns;
      NSInteger row = ixItem / numberOfColumns;

      NILauncherButton* button = [page objectAtIndex:ixItem];
      button.frame = CGRectMake(_padding.left + col * buttonDimensions.width
                                + (col * buttonHorizontalSpacing),
                                _padding.top + row * buttonDimensions.height
                                + (row * buttonVerticalSpacing),
                                buttonDimensions.width, buttonDimensions.height);

      pageBottom = MAX(pageBottom, CGRectGetMaxY(button.frame));
    }

    UIScrollView* pageScrollView = [_pagesOfScrollViews objectAtIndex:ixPage];
    pageScrollView.frame = CGRectMake(pageOffset, 0, pageWidth, _scrollView.frame.size.height);
    pageScrollView.contentSize = CGSizeMake(pageWidth, pageBottom + _padding.bottom);
  }
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
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(updatePageIndex)];

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
#pragma mark Actions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)pageAndIndexOfButton: (UIButton *)searchButton
                        page: (NSInteger *)pPage
                       index: (NSInteger *)pIndex {
  NIDASSERT(nil != pPage);
  NIDASSERT(nil != pIndex);
  if (nil == pPage
      || nil == pIndex) {
    return NO;
  }

  for (NSInteger ixPage = 0; ixPage < [_pagesOfButtons count]; ++ixPage) {
    NSArray* page = [_pagesOfButtons objectAtIndex:ixPage];
    for (NSInteger ixButton = 0; ixButton < [page count]; ++ixButton) {
      UIButton* button = [page objectAtIndex:ixButton];
      if (button == searchButton) {
        *pPage = ixPage;
        *pIndex = ixButton;
        return YES;
      }
    }
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapButton:(UIButton *)tappedButton {
  NSInteger page = -1;
  NSInteger index = 0;
  if ([self pageAndIndexOfButton:tappedButton
                            page:&page
                           index:&index]) {
    if ([self.delegate respondsToSelector:
         @selector(launcherView:didSelectButton:onPage:atIndex:)]) {
      [self.delegate launcherView: self
                  didSelectButton: tappedButton
                           onPage: page
                          atIndex: index];
    }
  }
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

  NI_RELEASE_SAFELY(_pagesOfButtons);
  NI_RELEASE_SAFELY(_pagesOfScrollViews);

  _pagesOfButtons = [[NSMutableArray alloc] initWithCapacity:_numberOfPages];
  _pagesOfScrollViews = [[NSMutableArray alloc] initWithCapacity:_numberOfPages];
  for (NSInteger ixPage = 0; ixPage < _numberOfPages; ++ixPage) {
    NSInteger numberOfItems = [self.dataSource launcherView: self
                                      numberOfButtonsInPage: ixPage];
    NSMutableArray* page = [[[NSMutableArray alloc] initWithCapacity:numberOfItems]
                            autorelease];

    UIScrollView* pageScrollView = [[[UIScrollView alloc] init] autorelease];
    pageScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    for (NSInteger ixItem = 0 ; ixItem < numberOfItems; ++ixItem) {
      UIButton* item = [self.dataSource launcherView: self
                                       buttonForPage: ixPage
                                             atIndex: ixItem];
      [item       addTarget: self
                     action: @selector(didTapButton:)
           forControlEvents: UIControlEventTouchUpInside];
      [page addObject:item];
      [pageScrollView addSubview:item];
    }

    [_scrollView addSubview:pageScrollView];

    [_pagesOfScrollViews addObject:pageScrollView];
    [_pagesOfButtons addObject:page];
  }

  [self layoutPages];
}


@end
