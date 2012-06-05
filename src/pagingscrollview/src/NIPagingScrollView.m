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

#import "NIPagingScrollView.h"

#import "NIPagingScrollViewPage.h"
#import "NIPagingScrollViewDataSource.h"
#import "NIPagingScrollViewDelegate.h"
#import "NimbusCore.h"

#import <objc/runtime.h>

const NSInteger NIPagingScrollViewUnknownNumberOfPages = -1;
const CGFloat NIPagingScrollViewDefaultPageHorizontalMargin = 10;

@interface NIPagingScrollView()

@property (nonatomic, readwrite, retain) UIScrollView* pagingScrollView;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPagingScrollView

@synthesize visiblePages = _visiblePages;
@synthesize pagingScrollView = _pagingScrollView;
@synthesize pageHorizontalMargin = _pageHorizontalMargin;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize centerPageIndex = _centerPageIndex;
@synthesize numberOfPages = _numberOfPages;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pagingScrollView);

  NI_RELEASE_SAFELY(_visiblePages);
  NI_RELEASE_SAFELY(_viewRecycler);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)commonInit {
  // Default state.
  self.pageHorizontalMargin = NIPagingScrollViewDefaultPageHorizontalMargin;

  _firstVisiblePageIndexBeforeRotation = -1;
  _percentScrolledIntoFirstVisiblePage = -1;
  _centerPageIndex = -1;
  _numberOfPages = NIPagingScrollViewUnknownNumberOfPages;

  _viewRecycler = [[NIViewRecycler alloc] init];

  self.pagingScrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
  self.pagingScrollView.pagingEnabled = YES;

  self.pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                            | UIViewAutoresizingFlexibleHeight);

  self.pagingScrollView.delegate = self;

  // Ensure that empty areas of the scroll view are draggable.
  self.pagingScrollView.backgroundColor = [UIColor blackColor];

  self.pagingScrollView.showsVerticalScrollIndicator = NO;
  self.pagingScrollView.showsHorizontalScrollIndicator = NO;

  [self addSubview:self.pagingScrollView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self commonInit];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self commonInit];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];

  self.pagingScrollView.backgroundColor = self.superview.backgroundColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Page Layout


// The following three methods are from Apple's ImageScrollView example application and have
// been used here because they are well-documented and concise.


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
- (CGRect)frameForPageAtIndex:(NSInteger)pageIndex {
  // We have to use our paging scroll view's bounds, not frame, to calculate the page
  // placement. When the device is in landscape orientation, the frame will still be in
  // portrait because the pagingScrollView is the root view controller's view, so its
  // frame is in window coordinate space, which is never rotated. Its bounds, however,
  // will be in landscape because it has a rotation transform applied.
  CGRect bounds = self.pagingScrollView.bounds;
  CGRect pageFrame = bounds;

  // We need to counter the extra spacing added to the paging scroll view in
  // frameForPagingScrollView:
  pageFrame.size.width -= self.pageHorizontalMargin * 2;
  pageFrame.origin.x = (bounds.size.width * pageIndex) + self.pageHorizontalMargin;

  return pageFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSizeForPagingScrollView {
  // We have to use the paging scroll view's bounds to calculate the contentSize, for the
  // same reason outlined above.
  CGRect bounds = self.pagingScrollView.bounds;
  return CGSizeMake(bounds.size.width * _numberOfPages, bounds.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Visible Page Management


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isDisplayingPageForIndex:(NSInteger)pageIndex {
  BOOL foundPage = NO;

  // There will never be more than 3 visible pages in this array, so this lookup is
  // effectively O(C) constant time.
  for (id<NIPagingScrollViewPage> page in _visiblePages) {
    if (page.pageIndex == pageIndex) {
      foundPage = YES;
      break;
    }
  }

  return foundPage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)currentVisiblePageIndex {
  CGPoint contentOffset = self.pagingScrollView.contentOffset;
  CGSize boundsSize = self.pagingScrollView.bounds.size;

  // Whatever image is currently displayed in the center of the screen is the currently
  // visible image.
  return boundi((NSInteger)(floorf((contentOffset.x + boundsSize.width / 2) / boundsSize.width)
                            + 0.5f),
                0, self.numberOfPages - 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)visiblePageRange {
  if (0 >= _numberOfPages) {
    return NSMakeRange(0, 0);
  }

  NSInteger currentVisiblePageIndex = [self currentVisiblePageIndex];

  int firstVisiblePageIndex = boundi(currentVisiblePageIndex - 1, 0, _numberOfPages - 1);
  int lastVisiblePageIndex  = boundi(currentVisiblePageIndex + 1, 0, _numberOfPages - 1);

  return NSMakeRange(firstVisiblePageIndex, lastVisiblePageIndex - firstVisiblePageIndex + 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willDisplayPage:(UIView<NIPagingScrollViewPage> *)pageView atIndex:(NSInteger)pageIndex {
  pageView.pageIndex = pageIndex;
  [pageView setFrame:[self frameForPageAtIndex:pageIndex]];
  
  [self willDisplayPage:pageView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPage:(id<NIPagingScrollViewPage>)page {
  if ([page respondsToSelector:@selector(pageDidDisappear)]) {
    [page pageDidDisappear];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetSurroundingPages {
  for (id<NIPagingScrollViewPage> page in _visiblePages) {
    if (page.pageIndex != self.centerPageIndex) {
      [self resetPage:page];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NIPagingScrollViewPage> *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
  NIDASSERT(nil != identifier);
  if (nil == identifier) {
    return nil;
  }

  return (UIView<NIPagingScrollViewPage> *)[_viewRecycler dequeueReusableViewWithIdentifier:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)displayPageAtIndex:(NSInteger)pageIndex {
  UIView<NIPagingScrollViewPage>* page = [self.dataSource pagingScrollView:self
                                                          pageViewForIndex:pageIndex];
  NIDASSERT([page isKindOfClass:[UIView class]]);
  NIDASSERT([page conformsToProtocol:@protocol(NIPagingScrollViewPage)]);
  if (nil == page || ![page isKindOfClass:[UIView class]]
      || ![page conformsToProtocol:@protocol(NIPagingScrollViewPage)]) {
    // Bail out! This page is malformed.
    return;
  }

  // This will only be called once before the page is shown.
  [self willDisplayPage:page atIndex:pageIndex];

  [self.pagingScrollView addSubview:(UIView *)page];
  [_visiblePages addObject:page];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateVisiblePages {
  NSRange visiblePageRange = [self visiblePageRange];

  // Recycle no-longer-visible pages. We copy _visiblePages because we may modify it while we're
  // iterating over it.
  for (UIView<NIPagingScrollViewPage>* page in [[_visiblePages copy] autorelease]) {
    if (!NSLocationInRange(page.pageIndex, visiblePageRange)) {
      [_viewRecycler recycleView:page];
      [page removeFromSuperview];

      [self didRecyclePage:page];

      [_visiblePages removeObject:page];
    }
  }

  NSInteger oldCenterPageIndex = self.centerPageIndex;
    
  if (_numberOfPages > 0) {
    _centerPageIndex = [self currentVisiblePageIndex];
      
    // Prioritize displaying the currently visible page.
    if (![self isDisplayingPageForIndex:_centerPageIndex]) {
      [self displayPageAtIndex:_centerPageIndex];
    }
      
    // Add missing pages.
    for (int pageIndex = visiblePageRange.location;
         pageIndex < NSMaxRange(visiblePageRange); ++pageIndex) {
      if (![self isDisplayingPageForIndex:pageIndex]) {
        [self displayPageAtIndex:pageIndex];
      }
    }
  } else {
    _centerPageIndex = -1;
  }

  if (oldCenterPageIndex != _centerPageIndex
      && [self.delegate respondsToSelector:@selector(pagingScrollViewDidChangePages:)]) {
    [self.delegate pagingScrollViewDidChangePages:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutVisiblePages {
  for (UIView<NIPagingScrollViewPage>* page in _visiblePages) {
    CGRect pageFrame = [self frameForPageAtIndex:page.pageIndex];
    if ([page respondsToSelector:@selector(setFrameAndMaintainState:)]) {
      [page setFrameAndMaintainState:pageFrame];
      
    } else {
      [page setFrame:pageFrame];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)frame {
  // We have to modify this method because it eventually leads to changing the content offset
  // programmatically. When this happens we end up getting a scrollViewDidScroll: message
  // during which we do not want to modify the visible pages because this is handled elsewhere.

  // Don't lose the previous modification state if an animation is occurring when the
  // frame changes, like when the device changes orientation.
  BOOL wasModifyingContentOffset = _isModifyingContentOffset;
  _isModifyingContentOffset = YES;
  [super setFrame:frame];

  self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
  [self layoutVisiblePages];

  _isModifyingContentOffset = wasModifyingContentOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (!_isModifyingContentOffset) {
    // This method is called repeatedly as the user scrolls so updateVisiblePages must be
    // light-weight enough not to noticeably impact performance.
    [self updateVisiblePages];

    if ([self.delegate respondsToSelector:@selector(pagingScrollViewDidScroll:)]) {
      [self.delegate pagingScrollViewDidScroll:self];
    }
  }

  if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [self.delegate scrollViewDidScroll:scrollView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self resetSurroundingPages];
  }

  if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
    [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self resetSurroundingPages];
  
  if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
    [self.delegate scrollViewDidEndDecelerating:scrollView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward UIScrollViewDelegate Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelectorToDelegate:(SEL)aSelector {
  struct objc_method_description description;
  // Only forward the selector if it's part of the UIScrollViewDelegate protocol.
  description = protocol_getMethodDescription(@protocol(UIScrollViewDelegate),
                                              aSelector,
                                              NO,
                                              YES);

  BOOL isSelectorInScrollViewDelegate = (description.name != NULL && description.types != NULL);
  return (isSelectorInScrollViewDelegate
          && [self.delegate respondsToSelector:aSelector]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)aSelector {
  if ([super respondsToSelector:aSelector] == YES) {
    return YES;

  } else {
    return [self shouldForwardSelectorToDelegate:aSelector];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)forwardingTargetForSelector:(SEL)aSelector {
  if ([self shouldForwardSelectorToDelegate:aSelector]) {
    return self.delegate;

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Subclassing


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willDisplayPage:(UIView<NIPagingScrollViewPage> *)pageView {
  // No-op.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRecyclePage:(UIView<NIPagingScrollViewPage> *)pageView {
  // No-op
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  NIDASSERT(nil != _dataSource);

  // Remove any visible pages from the view before we release the sets.
  for (UIView<NIPagingScrollViewPage>* page in _visiblePages) {
    [_viewRecycler recycleView:page];
    [(UIView *)page removeFromSuperview];
  }

  NI_RELEASE_SAFELY(_visiblePages);

  // If there is no data source then we can't do anything particularly interesting.
  if (nil == _dataSource) {
    _isModifyingContentOffset = YES;
    self.pagingScrollView.contentSize = self.bounds.size;
    self.pagingScrollView.contentOffset = CGPointZero;
    _isModifyingContentOffset = NO;

    // May as well just get rid of all the views then.
    [_viewRecycler removeAllViews];

    return;
  }

  _visiblePages = [[NSMutableSet alloc] init];

  // Cache the number of pages.
  _numberOfPages = [_dataSource numberOfPagesInPagingScrollView:self];
  self.pagingScrollView.frame = [self frameForPagingScrollView];
  self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

  NSInteger oldCenterPageIndex = _centerPageIndex;
  if (oldCenterPageIndex >= 0) {
    _centerPageIndex = boundi(_centerPageIndex, 0, _numberOfPages - 1);

    // The content size is calculated based on the number of pages and the scroll view frame.
    _isModifyingContentOffset = YES;
    CGPoint offset = [self frameForPageAtIndex:_centerPageIndex].origin;
    offset.x -= self.pageHorizontalMargin;
    self.pagingScrollView.contentOffset = offset;
    _isModifyingContentOffset = NO;
  }

  // Begin requesting the page information from the data source.
  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  // Here, our pagingScrollView bounds have not yet been updated for the new interface
  // orientation. This is a good place to calculate the content offset that we will
  // need in the new orientation.
  CGFloat offset = self.pagingScrollView.contentOffset.x;
  CGFloat pageWidth = self.pagingScrollView.bounds.size.width;

  if (offset >= 0) {
    _firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
    _percentScrolledIntoFirstVisiblePage = ((offset
                                            - (_firstVisiblePageIndexBeforeRotation * pageWidth))
                                           / pageWidth);

  } else {
    _firstVisiblePageIndexBeforeRotation = 0;
    _percentScrolledIntoFirstVisiblePage = offset / pageWidth;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  BOOL wasModifyingContentOffset = _isModifyingContentOffset;

  // Recalculate contentSize based on current orientation.
  _isModifyingContentOffset = YES;
  self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
  _isModifyingContentOffset = wasModifyingContentOffset;

  [self layoutVisiblePages];

  // Adjust contentOffset to preserve page location based on values collected prior to location.
  CGFloat pageWidth = self.pagingScrollView.bounds.size.width;
  CGFloat newOffset = ((_firstVisiblePageIndexBeforeRotation * pageWidth)
                       + (_percentScrolledIntoFirstVisiblePage * pageWidth));
  _isModifyingContentOffset = YES;
  self.pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
  _isModifyingContentOffset = wasModifyingContentOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasNext {
  return (self.centerPageIndex < self.numberOfPages - 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasPrevious {
  return self.centerPageIndex > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAnimateToPage:(NSNumber *)pageIndex {
  _isAnimatingToPage = NO;

  // Reset the content offset once the animation completes, just to be sure that the
  // viewer sits on a page bounds even if we rotate the device while animating.
  CGPoint offset = [self frameForPageAtIndex:[pageIndex intValue]].origin;
  offset.x -= self.pageHorizontalMargin;

  _isModifyingContentOffset = YES;
  self.pagingScrollView.contentOffset = offset;
  _isModifyingContentOffset = NO;

  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated {
  if (_isAnimatingToPage) {
    // Don't allow re-entry for sliding animations.
    return;
  }

  CGPoint offset = [self frameForPageAtIndex:pageIndex].origin;
  offset.x -= self.pageHorizontalMargin;

  _isModifyingContentOffset = YES;
  [self.pagingScrollView setContentOffset:offset animated:animated];

  NSNumber* pageIndexNumber = [NSNumber numberWithInt:pageIndex];
  if (animated) {
    _isAnimatingToPage = YES;
    SEL selector = @selector(didAnimateToPage:);
    [NSObject cancelPreviousPerformRequestsWithTarget: self];

    // When the animation is finished we reset the content offset just in case the frame
    // changes while we're animating (like when rotating the device). To do this we need
    // to know the destination index for the animation.
    [self performSelector: selector
               withObject: pageIndexNumber
               afterDelay: 0.4];

  } else {
    [self didAnimateToPage:pageIndexNumber];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToNextAnimated:(BOOL)animated {
  if ([self hasNext]) {
    NSInteger pageIndex = self.centerPageIndex + 1;

    [self moveToPageAtIndex:pageIndex animated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPreviousAnimated:(BOOL)animated {
  if ([self hasPrevious]) {
    NSInteger pageIndex = self.centerPageIndex - 1;

    [self moveToPageAtIndex:pageIndex animated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPageIndex:(NSInteger)centerPageIndex {
  [self moveToPageAtIndex:centerPageIndex animated:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPageIndex:(NSInteger)centerPageIndex animated:(BOOL)animated {
  [self moveToPageAtIndex:centerPageIndex animated:animated];
}


@end
