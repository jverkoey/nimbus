//
// Copyright 2011-2014 NimbusKit
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

#import "NILauncherPageView.h"
#import "NimbusPagingScrollView.h"
#import "NIPagingScrollView+Subclassing.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static NSString* const kPageReuseIdentifier = @"page";
const NSInteger NILauncherViewGridBasedOnButtonSize = -1;

static const CGFloat kDefaultButtonDimensions = 80;
static const CGFloat kDefaultPadding = 10;


@interface NILauncherView() <NIPagingScrollViewDataSource, NIPagingScrollViewDelegate>
@property (nonatomic, strong) NIPagingScrollView* pagingScrollView;
@property (nonatomic, strong) UIPageControl* pager;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, strong) NIViewRecycler* viewRecycler;
- (void)updateLayoutForPage:(NILauncherPageView *)page;
@end


@implementation NILauncherView



- (void)_configureDefaults {
  // We handle autoresizing ourselves.
  [self setAutoresizesSubviews:NO];

  _viewRecycler = [[NIViewRecycler alloc] init];

  _buttonSize = CGSizeMake(kDefaultButtonDimensions, kDefaultButtonDimensions);
  _numberOfColumns = NILauncherViewGridBasedOnButtonSize;
  _numberOfRows = NILauncherViewGridBasedOnButtonSize;

  _maxNumberOfButtonsPerPage = NSIntegerMax;
  _contentInsetForPages = UIEdgeInsetsMake(kDefaultPadding, kDefaultPadding, kDefaultPadding, kDefaultPadding);

  // The paging scroll view.
  _pagingScrollView = [[NIPagingScrollView alloc] initWithFrame:self.bounds];
  _pagingScrollView.dataSource = self;
  _pagingScrollView.delegate = self;

  [self addSubview:_pagingScrollView];

  // The pager displayed below the paging scroll view.
  _pager = [[UIPageControl alloc] init];
  _pager.hidesForSinglePage = YES;

  // So, this is weird. Apparently if you don't set a background color on the pager control
  // then taps won't be handled anywhere but within the dot area. If you do set a background
  // color, however, then taps outside of the dot area DO change the selected page.
  //                                  \(o.o)/
  _pager.backgroundColor = [UIColor blackColor];

  // Similarly for the scroll view anywhere there isn't a subview.
  // We update these background colors when the launcher view's own background color is set.
  _pagingScrollView.backgroundColor = [UIColor blackColor];

  // Don't update the pager when the user taps until we've animated to the new page.
  // This allows us to reset the page index forcefully if necessary without flickering the
  // pager's current selection.
  _pager.defersCurrentPageDisplay = YES;

  // When the user taps the pager control it fires a UIControlEventValueChanged notification.
  [_pager addTarget:self action:@selector(pagerDidChangePage:) forControlEvents:UIControlEventValueChanged];

  [self addSubview:_pager];
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self _configureDefaults];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self _configureDefaults];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [_pager sizeToFit];
  _pagingScrollView.frame = NIRectContract(self.bounds, 0, _pager.frame.size.height);
  _pager.frame = NIRectShift(self.bounds, 0, _pagingScrollView.frame.size.height);

  for (NILauncherPageView* pageView in self.pagingScrollView.visiblePages) {
    [self updateLayoutForPage:pageView];
  }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];

  self.pagingScrollView.backgroundColor = backgroundColor;
  self.pager.backgroundColor = backgroundColor;
}

- (void)calculateLayoutForFrame:(CGRect)frame
               buttonDimensions:(CGSize *)pButtonDimensions
                   numberOfRows:(NSInteger *)pNumberOfRows
                numberOfColumns:(NSInteger *)pNumberOfColumns
                  buttonMargins:(CGSize *)pButtonMargins {
  NIDASSERT(nil != pButtonDimensions);
  NIDASSERT(nil != pNumberOfRows);
  NIDASSERT(nil != pNumberOfColumns);
  NIDASSERT(nil != pButtonMargins);
  if (nil == pButtonDimensions
      || nil == pNumberOfRows
      || nil == pNumberOfColumns
      || nil == pButtonMargins) {
    return;
  }
  CGFloat pageWidth = frame.size.width - self.contentInsetForPages.left - self.contentInsetForPages.right;
  CGFloat pageHeight = frame.size.height - self.contentInsetForPages.top - self.contentInsetForPages.bottom;

  CGSize buttonDimensions = self.buttonSize;
  NSInteger numberOfColumns = self.numberOfColumns;
  NSInteger numberOfRows = self.numberOfRows;

  // Override point
  if ([self.dataSource respondsToSelector:@selector(numberOfRowsPerPageInLauncherView:)]) {
    numberOfRows = [self.dataSource numberOfRowsPerPageInLauncherView:self];
  }
  if ([self.dataSource respondsToSelector:@selector(numberOfColumnsPerPageInLauncherView:)]) {
    numberOfColumns = [self.dataSource numberOfColumnsPerPageInLauncherView:self];
  }

  if (NILauncherViewGridBasedOnButtonSize == numberOfColumns) {
    numberOfColumns = floorf(pageWidth / buttonDimensions.width);
  }
  if (NILauncherViewGridBasedOnButtonSize == numberOfRows) {
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
  pButtonMargins->width = buttonHorizontalSpacing;
  pButtonMargins->height = buttonVerticalSpacing;
}

- (void)updateLayoutForPage:(NILauncherPageView *)page {
  CGSize buttonDimensions = CGSizeZero;
  NSInteger numberOfRows = 0;
  NSInteger numberOfColumns = 0;
  CGSize buttonMargins = CGSizeZero;
  [self calculateLayoutForFrame:self.pagingScrollView.frame
               buttonDimensions:&buttonDimensions
                   numberOfRows:&numberOfRows
                numberOfColumns:&numberOfColumns
                  buttonMargins:&buttonMargins];
  
  page.contentInset = self.contentInsetForPages;
  page.viewSize = buttonDimensions;
  page.viewMargins = buttonMargins;
}

#pragma mark - UIPageControl Change Notifications


- (void)pagerDidChangePage:(UIPageControl*)pager {
  if ([self.pagingScrollView moveToPageAtIndex:pager.currentPage animated:YES]) {
    // Once we've handled the page change notification, notify the pager that it's ok to update
    // the page display.
    [self.pager updateCurrentPageDisplay];
  }
}

#pragma mark - Actions


/**
 * Find a button in the pages and retrieve its page and index.
 *
 * @param[in] searchButton  The button you are looking for.
 * @param[out] pPage        The resulting page, if found.
 * @param[out] pIndex       The resulting index, if found.
 * @returns YES if the button was found. NO otherwise.
 */
- (BOOL)pageAndIndexOfButton:(UIButton *)searchButton page:(NSInteger *)pPage index:(NSInteger *)pIndex {
  NIDASSERT(nil != pPage);
  NIDASSERT(nil != pIndex);
  if (nil == pPage
      || nil == pIndex) {
    return NO;
  }

  for (NILauncherPageView* pageView in self.pagingScrollView.visiblePages) {
    for (NSInteger buttonIndex = 0; buttonIndex < pageView.recyclableViews.count; ++buttonIndex) {
      UIView<NILauncherButtonView>* buttonView = [pageView.recyclableViews objectAtIndex:buttonIndex];
      if (buttonView.button == searchButton) {
        *pPage = pageView.pageIndex;
        *pIndex = buttonIndex;
        return YES;
      }
    }
  }

  return NO;
}

- (void)didTapButton:(UIButton *)tappedButton {
  NSInteger page = -1;
  NSInteger buttonIndex = 0;
  if ([self pageAndIndexOfButton:tappedButton
                            page:&page
                           index:&buttonIndex]) {

    if ([self.delegate respondsToSelector:@selector(launcherView:didSelectItemOnPage:atIndex:)]) {
      [self.delegate launcherView:self didSelectItemOnPage:page atIndex:buttonIndex];
    }

  } else {
    // How exactly did we tap a button that wasn't a part of the launcher view?
    NIDASSERT(NO);
  }
}

#pragma mark - NIPagingScrollViewDataSource


- (NSInteger)numberOfPagesInPagingScrollView:(NIPagingScrollView *)pagingScrollView {
  return self.numberOfPages;
}

- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  NILauncherPageView* page = (NILauncherPageView *)[self.pagingScrollView dequeueReusablePageWithIdentifier:kPageReuseIdentifier];
  if (nil == page) {
    page = [[NILauncherPageView alloc] initWithReuseIdentifier:kPageReuseIdentifier];
    page.viewRecycler = self.viewRecycler;
  }

  [self updateLayoutForPage:page];

  NSInteger numberOfButtons = [self.dataSource launcherView:self numberOfButtonsInPage:pageIndex];
  numberOfButtons = MIN(numberOfButtons, self.maxNumberOfButtonsPerPage);

  for (NSInteger buttonIndex = 0 ; buttonIndex < numberOfButtons; ++buttonIndex) {
    UIView<NILauncherButtonView>* buttonView = [self.dataSource launcherView:self buttonViewForPage:pageIndex atIndex:buttonIndex];
    NSAssert(nil != buttonView, @"A non-nil UIView must be returned.");
    [buttonView.button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [page addRecyclableView:(UIView<NIRecyclableView> *)buttonView];
  }

  return page;
}

#pragma mark - NIPagingScrollViewDelegate


- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView {
  self.pager.currentPage = pagingScrollView.centerPageIndex;
}

#pragma mark - Public


- (void)reloadData {
  if ([self.dataSource respondsToSelector:@selector(numberOfPagesInLauncherView:)]) {
    _numberOfPages = [self.dataSource numberOfPagesInLauncherView:self];

  } else {
    _numberOfPages = 1;
  }

  self.pager.numberOfPages = _numberOfPages;
  [self.pagingScrollView reloadData];
  [self setNeedsLayout];
}

- (UIView<NILauncherButtonView> *)dequeueReusableViewWithIdentifier:(NSString *)identifier {
  NIDASSERT(nil != identifier);
  if (nil == identifier) {
    return nil;
  }
  
  return (UIView<NILauncherButtonView> *)[self.viewRecycler dequeueReusableViewWithIdentifier:identifier];
}

- (void)setcontentInsetForPages:(UIEdgeInsets)contentInsetForPages {
  _contentInsetForPages = contentInsetForPages;

  for (NILauncherPageView* pageView in self.pagingScrollView.visiblePages) {
    pageView.contentInset = contentInsetForPages;
  }
}

- (void)setButtonSize:(CGSize)buttonSize {
  _buttonSize = buttonSize;

  for (NILauncherPageView* pageView in self.pagingScrollView.visiblePages) {
    pageView.viewSize = buttonSize;
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self.pagingScrollView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [self.pagingScrollView willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

@end
