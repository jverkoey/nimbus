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

#import "NimbusCore.h"

const NSInteger NILauncherViewDynamic = -1;

static const CGFloat kDefaultButtonDimensions = 80;
static const CGFloat kDefaultPadding          = 10;
static const NSTimeInterval kAnimateToPageDuration = 0.2;


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
- (void)_initialize {
  _maxNumberOfButtonsPerPage = NSIntegerMax;
  _padding = UIEdgeInsetsMake(kDefaultPadding, kDefaultPadding,
                              kDefaultPadding, kDefaultPadding);

  // The paging scroll view.
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.delegate = self;
  _scrollView.pagingEnabled = YES;

  // We don't need scroll indicators because we have a pager. Vertical scrolling is handled
  // by each page's scroll view.
  _scrollView.showsVerticalScrollIndicator = NO;
  _scrollView.showsHorizontalScrollIndicator = NO;

  [self addSubview:_scrollView];

  // The pager displayed at the bottom of the scroll view.
  _pager = [[UIPageControl alloc] init];
  _pager.hidesForSinglePage = YES;

  // So, this is weird. Apparently if you don't set a background color on the pager control
  // then taps won't be handled anywhere but within the dot area. If you do set a background
  // color, however, then taps outside of the dot area DO change the selected page.
  //                                  \(o.o)/
  _pager.backgroundColor = [UIColor blackColor];
  // Similarly for the scroll view anywhere there isn't a subview.
  _scrollView.backgroundColor = [UIColor blackColor];
  // We update these background colors when the launcher view's own background color is set.

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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self _initialize];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self _initialize];
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

  // Lay out the pager first. The remaining space is used for the launcher scroll view.
  [_pager sizeToFit];
  _pager.frame = CGRectMake(0, self.frame.size.height - _pager.frame.size.height,
                            self.frame.size.width,
                            _pager.frame.size.height);

  CGFloat pageWidth = [self pageWidthForLauncherFrame:self.frame];

  // The scroll view frame takes up the entire launcher view, minus the pager.
  _scrollView.frame = CGRectMake(0, 0,
                                 pageWidth,
                                 self.frame.size.height - _pager.frame.size.height);

  // We never want the paging scroll view to scroll vertically, so make sure the content size
  // is always exactly the scroll view height.
  _scrollView.contentSize = CGSizeMake(pageWidth * _numberOfPages,
                                       _scrollView.frame.size.height);

  // We update the content offset so that the scroll view sits on an integral page boundary.
  // This is most useful when switching device orientations.
  _scrollView.contentOffset = CGPointMake([self pageWidthForLauncherFrame:frame]
                                          * _pager.currentPage,
                                          0);

  // The dimensions of the scroll view may have changed, so lay out all of the pages.
  [self layoutPages];

  // Example: When switching from a 3x4 grid of 12 items to a 5x2 grid of 10, there will be
  // leftover items and the page will be too tall to fit everything as a result. We flash
  // the scroll indicators when this happens to indicate to the user that some buttons have been
  // hidden.
  [[_pagesOfScrollViews objectAtIndex:_pager.currentPage] flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Update the pager's current page based on the scroll view's content offset.
 *
 * Flashes the scroll indicators if the page index changes.
 */
- (void)updatePageIndex {
  CGFloat pageWidth = _scrollView.frame.size.width;
  NSInteger pageIndex = roundf(_scrollView.contentOffset.x / pageWidth);
  if (_pager.currentPage != pageIndex) {
    _pager.currentPage = pageIndex;

    [[_pagesOfScrollViews objectAtIndex:pageIndex] flashScrollIndicators];
  }
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

      UIButton* button = [page objectAtIndex:ixItem];
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
- (void)flashCurrentPageScrollIndicators {
  [[_pagesOfScrollViews objectAtIndex:_pager.currentPage] flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pageChanged:(UIPageControl*)pager {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:kAnimateToPageDuration];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(flashCurrentPageScrollIndicators)];

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
/**
 * Find a button in the pages and retrieve its page and index.
 *
 * @param[in] searchButton  The button you are looking for.
 * @param[out] pPage        The resulting page, if found.
 * @param[out] pIndex       The resulting index, if found.
 * @returns YES if the button was found. NO otherwise.
 */
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
  NSInteger buttonIndex = 0;
  if ([self pageAndIndexOfButton:tappedButton
                            page:&page
                           index:&buttonIndex]) {

    if ([self.delegate respondsToSelector:
         @selector(launcherView:didSelectButton:onPage:atIndex:)]) {
      [self.delegate launcherView: self
                  didSelectButton: tappedButton
                           onPage: page
                          atIndex: buttonIndex];
    }

  } else {
    // How exactly did we tap a button that wasn't a part of the launcher view?
    NIDASSERT(NO);
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

  // FEATURE: Remember the current page?

  _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _numberOfPages,
                                       _scrollView.frame.size.height);

  // Remove the views from the view hierarchy before we clobber the collections.
  for (NSArray* page in _pagesOfButtons) {
    for (UIButton* button in page) {
      [button removeFromSuperview];
    }
  }
  for (UIScrollView* scrollView in _pagesOfScrollViews) {
    [scrollView removeFromSuperview];
  }

  NI_RELEASE_SAFELY(_pagesOfButtons);
  NI_RELEASE_SAFELY(_pagesOfScrollViews);

  // We query the data source for all of the button views. Each page of buttons lives within
  // a scroll view that will scroll vertically if there are too many buttons for the page.

  _pagesOfButtons = [[NSMutableArray alloc] initWithCapacity:_numberOfPages];
  _pagesOfScrollViews = [[NSMutableArray alloc] initWithCapacity:_numberOfPages];
  for (NSInteger ixPage = 0; ixPage < _numberOfPages; ++ixPage) {
    NSInteger numberOfItems = MIN(_maxNumberOfButtonsPerPage,
                                  [self.dataSource launcherView: self
                                          numberOfButtonsInPage: ixPage]);

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
