//
// Copyright 2011-2012 Jeff Verkoeyen
// Copyright 2012 Manu Cornet (vertical layouts)
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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

const NSInteger NIPagingScrollViewUnknownNumberOfPages = -1;
const CGFloat NIPagingScrollViewDefaultPageMargin = 10;

@interface NIPagingScrollView()  {
@private
  NIViewRecycler* _viewRecycler;

  // State Information
  NSInteger _firstVisiblePageIndexBeforeRotation;
  CGFloat _percentScrolledIntoFirstVisiblePage;
  BOOL _isModifyingContentOffset;
  BOOL _isAnimatingToPage;
  BOOL _isKillingAnimation;
  NSInteger _animatingToPageIndex;
}

@property (nonatomic, retain) UIScrollView* pagingScrollView;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPagingScrollView

@synthesize visiblePages = _visiblePages;
@synthesize pagingScrollView = _pagingScrollView;
@synthesize pageMargin = _pageMargin;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize centerPageIndex = _centerPageIndex;
@synthesize numberOfPages = _numberOfPages;
@synthesize type = _type;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)commonInit {
  // Default state.
  self.pageMargin = NIPagingScrollViewDefaultPageMargin;

  _firstVisiblePageIndexBeforeRotation = -1;
  _percentScrolledIntoFirstVisiblePage = -1;
  _centerPageIndex = -1;
  _numberOfPages = NIPagingScrollViewUnknownNumberOfPages;
  _type = NIPagingScrollViewHorizontal;

  _viewRecycler = [[NIViewRecycler alloc] init];

  self.pagingScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  self.pagingScrollView.pagingEnabled = YES;
  self.pagingScrollView.scrollsToTop = NO;

  self.pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                            | UIViewAutoresizingFlexibleHeight);

  self.pagingScrollView.delegate = self;

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
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Page Layout


// The following three methods are from Apple's ImageScrollView example application and have
// been used here because they are well-documented and concise.


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPagingScrollView {
  CGRect frame = self.bounds;

  if (NIPagingScrollViewHorizontal == self.type) {
    // We make the paging scroll view a little bit wider on the side edges so that there
    // there is space between the pages when flipping through them.
    frame.origin.x -= self.pageMargin;
    frame.size.width += (2 * self.pageMargin);

  } else if (NIPagingScrollViewVertical == self.type) {
    frame.origin.y -= self.pageMargin;
    frame.size.height += (2 * self.pageMargin);
  }

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
  
  if (NIPagingScrollViewHorizontal == self.type) {
    // We need to counter the extra spacing added to the paging scroll view in
    // frameForPagingScrollView:
    pageFrame.size.width -= self.pageMargin * 2;
    pageFrame.origin.x = (bounds.size.width * pageIndex) + self.pageMargin;

  } else if (NIPagingScrollViewVertical == self.type) {
    pageFrame.size.height -= self.pageMargin * 2;
    pageFrame.origin.y = (bounds.size.height * pageIndex) + self.pageMargin;
  }

  return pageFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSizeForPagingScrollView {
  // We have to use the paging scroll view's bounds to calculate the contentSize, for the
  // same reason outlined above.
  CGRect bounds = self.pagingScrollView.bounds;
  if (NIPagingScrollViewHorizontal == self.type) {
    return CGSizeMake(bounds.size.width * _numberOfPages, bounds.size.height);

  } else if (NIPagingScrollViewVertical == self.type) {
    return CGSizeMake(bounds.size.width, bounds.size.height * self.numberOfPages);
  }
  return CGSizeZero;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)adjustOffsetWithMargin:(CGPoint)offset {
  if (NIPagingScrollViewHorizontal == self.type) {
    offset.x -= self.pageMargin;

  } else if (NIPagingScrollViewVertical == self.type) {
    offset.y -= self.pageMargin;
  }
  return offset;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageScrollableDimension {
  if (NIPagingScrollViewHorizontal == self.type) {
    return self.pagingScrollView.bounds.size.width;
    
  } else if (NIPagingScrollViewVertical == self.type) {
    return self.pagingScrollView.bounds.size.height;
  }
  
  return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)contentOffsetFromOffset:(CGFloat)offset {
  if (NIPagingScrollViewHorizontal == self.type) {
    return CGPointMake(offset, 0);

  } else if (NIPagingScrollViewVertical == self.type) {
    return CGPointMake(0, offset);
  }
  
  return CGPointMake(0, 0);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)scrolledPageOffset {
  if (NIPagingScrollViewHorizontal == self.type) {
    return self.pagingScrollView.contentOffset.x;

  } else if (NIPagingScrollViewVertical == self.type) {
    return self.pagingScrollView.contentOffset.y;
  }
  
  return 0;
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
  
  if (NIPagingScrollViewHorizontal == self.type) {
    // Whatever image is currently displayed in the center of the screen is the currently
    // visible image.
    return boundi((NSInteger)(floorf((contentOffset.x + boundsSize.width / 2) / boundsSize.width)
                              + 0.5f),
                  0, self.numberOfPages - 1);
    
  } else if (NIPagingScrollViewVertical == self.type) {
    return boundi((NSInteger)(floorf((contentOffset.y + boundsSize.height / 2) / boundsSize.height)
                              + 0.5f),
                  0, self.numberOfPages - 1);
  }
  
  return 0;
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
- (void)updateVisiblePagesShouldNotifyDelegate:(BOOL)shouldNotifyDelegate {
  NSRange visiblePageRange = [self visiblePageRange];

  // Recycle no-longer-visible pages. We copy _visiblePages because we may modify it while we're
  // iterating over it.
  for (UIView<NIPagingScrollViewPage>* page in [_visiblePages copy]) {
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
         pageIndex < (NSInteger)NSMaxRange(visiblePageRange); ++pageIndex) {
      if (![self isDisplayingPageForIndex:pageIndex]) {
        [self displayPageAtIndex:pageIndex];
      }
    }
  } else {
    _centerPageIndex = -1;
  }

  if (shouldNotifyDelegate && oldCenterPageIndex != _centerPageIndex
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
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self updateVisiblePagesShouldNotifyDelegate:YES];
  _isKillingAnimation = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (!_isModifyingContentOffset) {
    if ([self.delegate respondsToSelector:@selector(pagingScrollViewDidScroll:)]) {
      [self.delegate pagingScrollViewDidScroll:self];
    }
  }

  if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
    [self.delegate scrollViewDidScroll:scrollView];
  }

  if (_isKillingAnimation) {
    // The content size is calculated based on the number of pages and the scroll view frame.
    _isModifyingContentOffset = YES;
    CGPoint offset = [self frameForPageAtIndex:_centerPageIndex].origin;
    offset = [self adjustOffsetWithMargin:offset];
    self.pagingScrollView.contentOffset = offset;
    _isModifyingContentOffset = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  _isKillingAnimation = NO;

  if (!decelerate) {
    [self updateVisiblePagesShouldNotifyDelegate:YES];
    [self resetSurroundingPages];
  }

  if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
    [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self updateVisiblePagesShouldNotifyDelegate:YES];
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

  _visiblePages = nil;

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
    offset = [self adjustOffsetWithMargin:offset];
    self.pagingScrollView.contentOffset = offset;
    _isModifyingContentOffset = NO;

    _isKillingAnimation = YES;
  }

  // Begin requesting the page information from the data source.
  [self updateVisiblePagesShouldNotifyDelegate:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  // Here, our pagingScrollView bounds have not yet been updated for the new interface
  // orientation. This is a good place to calculate the content offset that we will
  // need in the new orientation.
  CGFloat offset = [self scrolledPageOffset];
  CGFloat pageScrollableDimension = [self pageScrollableDimension];

  if (offset >= 0) {
    _firstVisiblePageIndexBeforeRotation = (NSInteger)floorf(offset / pageScrollableDimension);
    _percentScrolledIntoFirstVisiblePage = ((offset
        - (_firstVisiblePageIndexBeforeRotation * pageScrollableDimension))
        / pageScrollableDimension);

  } else {
    _firstVisiblePageIndexBeforeRotation = 0;
    _percentScrolledIntoFirstVisiblePage = offset / pageScrollableDimension;
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
  CGFloat pageScrollableDimension = [self pageScrollableDimension];
  CGFloat newOffset = ((_firstVisiblePageIndexBeforeRotation * pageScrollableDimension)
                       + (_percentScrolledIntoFirstVisiblePage * pageScrollableDimension));
  _isModifyingContentOffset = YES;
  self.pagingScrollView.contentOffset = [self contentOffsetFromOffset:newOffset];
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
  if (_animatingToPageIndex != -1 && _animatingToPageIndex != [pageIndex integerValue]) {
    [self moveToPageAtIndex:_animatingToPageIndex animated:YES];
    return;
  }

  // Reset the content offset once the animation completes, just to be sure that the
  // viewer sits on a page bounds even if we rotate the device while animating.
  CGPoint offset = [self frameForPageAtIndex:[pageIndex intValue]].origin;
  offset = [self adjustOffsetWithMargin:offset];

  _isModifyingContentOffset = YES;
  self.pagingScrollView.contentOffset = offset;
  _isModifyingContentOffset = NO;

  [self updateVisiblePagesShouldNotifyDelegate:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)moveToPageAtIndex:(NSInteger)pageIndex animated:(BOOL)animated {
  if (_isAnimatingToPage) {
    // Don't allow re-entry for sliding animations.
    _animatingToPageIndex = pageIndex;
    return NO;
  }
  _isKillingAnimation = NO;
  _animatingToPageIndex = -1;

  CGPoint offset = [self frameForPageAtIndex:pageIndex].origin;
  offset = [self adjustOffsetWithMargin:offset];

  _isModifyingContentOffset = YES;
  [self.pagingScrollView setContentOffset:offset animated:animated];

  NSNumber* pageIndexNumber = [NSNumber numberWithInt:pageIndex];
  if (animated) {
    _isAnimatingToPage = YES;
    SEL selector = @selector(didAnimateToPage:);
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    // When the animation is finished we reset the content offset just in case the frame
    // changes while we're animating (like when rotating the device). To do this we need
    // to know the destination index for the animation.
    [self performSelector:selector withObject:pageIndexNumber afterDelay:0.4];

  } else {
    [self didAnimateToPage:pageIndexNumber];
  }
  return YES;
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
- (UIView<NIPagingScrollViewPage> *)centerPageView {
  for (UIView<NIPagingScrollViewPage>* page in _visiblePages) {
    if (page.pageIndex == self.centerPageIndex) {
      return page;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterPageIndex:(NSInteger)centerPageIndex {
  [self moveToPageAtIndex:centerPageIndex animated:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setType:(NIPagingScrollViewType)type {
  if (_type != type) {
    _type = type;
    self.pagingScrollView.scrollsToTop = (type == NIPagingScrollViewVertical);
  }
}


@end
