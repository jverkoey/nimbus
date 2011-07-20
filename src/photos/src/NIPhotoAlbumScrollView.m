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

#import "NIPhotoAlbumScrollView.h"

#import "NIPhotoScrollView.h"

const NSInteger NIPhotoAlbumScrollViewUnknownNumberOfPhotos = -1;
const CGFloat NIPhotoAlbumScrollViewDefaultPageHorizontalMargin = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoAlbumScrollView

@synthesize loadingImage = _loadingImage;
@synthesize pageHorizontalMargin = _pageHorizontalMargin;
@synthesize zoomingIsEnabled = _zoomingIsEnabled;
@synthesize zoomingAboveOriginalSizeIsEnabled = _zoomingAboveOriginalSizeIsEnabled;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize currentCenterPhotoIndex = _currentCenterPhotoIndex;
@synthesize numberOfPhotos = _numberOfPages;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _pagingScrollView = nil;

  NI_RELEASE_SAFELY(_loadingImage);

  NI_RELEASE_SAFELY(_visiblePages);
  NI_RELEASE_SAFELY(_recycledPages);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Default state.
    self.pageHorizontalMargin = NIPhotoAlbumScrollViewDefaultPageHorizontalMargin;
    self.zoomingIsEnabled = YES;
    self.zoomingAboveOriginalSizeIsEnabled = YES;

    _firstVisiblePageIndexBeforeRotation = -1;
    _percentScrolledIntoFirstVisiblePage = -1;
    _currentCenterPhotoIndex = -1;
    _numberOfPages = NIPhotoAlbumScrollViewUnknownNumberOfPhotos;

    _pagingScrollView = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    _pagingScrollView.pagingEnabled = YES;

    _pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                          | UIViewAutoresizingFlexibleHeight);

    _pagingScrollView.delegate = self;

    // Ensure that empty areas of the scroll view are draggable.
    _pagingScrollView.backgroundColor = [UIColor blackColor];

    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;

    [self addSubview:_pagingScrollView];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)notifyDelegatePhotoDidLoadAtIndex:(NSInteger)photoIndex {
  if (photoIndex == (self.currentCenterPhotoIndex + 1)
      && [self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidLoadNextPhoto:)]) {
    [self.delegate photoAlbumScrollViewDidLoadNextPhoto:self];

  } else if (photoIndex == (self.currentCenterPhotoIndex - 1)
             && [self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidLoadPreviousPhoto:)]) {
    [self.delegate photoAlbumScrollViewDidLoadPreviousPhoto:self];
  }
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
- (CGRect)frameForPageAtIndex:(NSInteger)index {
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
  pageFrame.origin.x = (bounds.size.width * index) + self.pageHorizontalMargin;

  return pageFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSizeForPagingScrollView {
  // We have to use the paging scroll view's bounds to calculate the contentSize, for the
  // same reason outlined above.
  CGRect bounds = _pagingScrollView.bounds;
  return CGSizeMake(bounds.size.width * _numberOfPages, bounds.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Visible Page Management


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIPhotoScrollView *)dequeueRecycledPage {
  NIPhotoScrollView* page = [_recycledPages anyObject];

  if (nil != page) {
    // Ensure that this object sticks around for this runloop.
    [[page retain] autorelease];

    [_recycledPages removeObject:page];

    // Reset this page to a blank slate state.
    [page prepareForReuse];
  }

  return page;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isDisplayingPageForIndex:(NSInteger)index {
  BOOL foundPage = NO;

  // There will never be more than 3 visible pages in this array, so this lookup is
  // effectively O(C) constant time.
  for (NIPhotoScrollView* page in _visiblePages) {
    if (page.photoIndex == index) {
      foundPage = YES;
      break;
    }
  }

  return foundPage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)currentVisiblePageIndex {
  CGPoint contentOffset = _pagingScrollView.contentOffset;
  CGSize boundsSize = _pagingScrollView.bounds.size;

  // Whatever image is currently displayed in the center of the screen is the currently
  // visible image.
  return MAX(0, MIN(self.numberOfPhotos,
                    floorf((contentOffset.x + boundsSize.width / 2) / boundsSize.width)));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)visiblePageRange {
  if (0 >= _numberOfPages) {
    return NSMakeRange(0, 0);
  }

  NSInteger currentVisiblePageIndex = [self currentVisiblePageIndex];

  int firstVisiblePageIndex = MAX(currentVisiblePageIndex - 1, 0);
  int lastVisiblePageIndex  = MAX(0, MIN(currentVisiblePageIndex + 1, _numberOfPages - 1));

  return NSMakeRange(firstVisiblePageIndex, lastVisiblePageIndex - firstVisiblePageIndex + 1);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)configurePage:(NIPhotoScrollView *)page forIndex:(NSInteger)index {
  page.photoIndex = index;
  page.frame = [self frameForPageAtIndex:index];

  // When we ask the data source for the image we expect the following to happen:
  // 1) If the data source has any image at this index, it should return it and set the
  //    photoSize accordingly.
  // 2) If the returned photo is not the highest quality available, the data source should
  //    start loading it and set isLoading to YES.
  // 3) If no photo was available, then the data source should start loading the photo
  //    at its highest quality and nil should be returned. loadingImage will be used in
  //    this case.
  NIPhotoScrollViewPhotoSize photoSize = NIPhotoScrollViewPhotoSizeUnknown;
  BOOL isLoading = NO;
  CGSize originalPhotoDimensions = CGSizeZero;
  UIImage* image = [_dataSource photoAlbumScrollView: self
                                        photoAtIndex: index
                                           photoSize: &photoSize
                                           isLoading: &isLoading
                             originalPhotoDimensions: &originalPhotoDimensions];

  page.photoDimensions = originalPhotoDimensions;

  if (nil == image) {
    page.zoomingIsEnabled = NO;
    [page setImage:self.loadingImage photoSize:NIPhotoScrollViewPhotoSizeUnknown];

  } else {
    page.zoomingIsEnabled = ([self isZoomingEnabled]
                             && (NIPhotoScrollViewPhotoSizeOriginal == photoSize));
    if (photoSize > page.photoSize) {
      [page setImage:image photoSize:photoSize];

      if (NIPhotoScrollViewPhotoSizeOriginal == photoSize) {
        [self notifyDelegatePhotoDidLoadAtIndex:index];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPage:(NIPhotoScrollView *)page {
  page.zoomScale = page.minimumZoomScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetSurroundingPages {
  for (NIPhotoScrollView* page in _visiblePages) {
    if (page.photoIndex != self.currentCenterPhotoIndex) {
      [self resetPage:page];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)displayPageAtIndex:(NSInteger)index {
  NIPhotoScrollView* page = [self dequeueRecycledPage];

  if (nil == page) {
    page = [[[NIPhotoScrollView alloc] init] autorelease];
    page.photoScrollViewDelegate = self;
    page.zoomingAboveOriginalSizeIsEnabled = [self isZoomingAboveOriginalSizeEnabled];
  }

  // This will only be called once each time the page is shown.
  [self configurePage:page forIndex:index];

  [_pagingScrollView addSubview:page];
  [_visiblePages addObject:page];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateVisiblePages {
  NSInteger oldCenterPhotoIndex = self.currentCenterPhotoIndex;

  NSRange visiblePageRange = [self visiblePageRange];

  _currentCenterPhotoIndex = [self currentVisiblePageIndex];

  // Recycle no-longer-visible pages.
  for (NIPhotoScrollView* page in _visiblePages) {
    if (!NSLocationInRange(page.photoIndex, visiblePageRange)) {
      [_recycledPages addObject:page];
      [page removeFromSuperview];

      // Give the data source the opportunity to kill any asynchronous operations for this
      // now-recycled page.
      if ([_dataSource respondsToSelector:
           @selector(photoAlbumScrollView:stopLoadingPhotoAtIndex:)]) {
        [_dataSource photoAlbumScrollView: self
                  stopLoadingPhotoAtIndex: page.photoIndex];
      }
    }
  }
  [_visiblePages minusSet:_recycledPages];

  // Prioritize displaying the currently visible page.
  if (![self isDisplayingPageForIndex:_currentCenterPhotoIndex]) {
    [self displayPageAtIndex:_currentCenterPhotoIndex];
  }

  // Add missing pages.
  for (int index = visiblePageRange.location; index < NSMaxRange(visiblePageRange); ++index) {
    if (![self isDisplayingPageForIndex:index]) {
      [self displayPageAtIndex:index];
    }
  }

  if (oldCenterPhotoIndex != _currentCenterPhotoIndex
      && [self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidChangePages:)]) {
    [self.delegate photoAlbumScrollViewDidChangePages:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


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
  _isModifyingContentOffset = wasModifyingContentOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (!_isModifyingContentOffset) {
    // This method is called repeatedly as the user scrolls so updateVisiblePages must be
    // leight-weight enough not to noticeably impact performance.
    [self updateVisiblePages];

    if ([self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidScroll:)]) {
      [self.delegate photoAlbumScrollViewDidScroll:self];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self resetSurroundingPages];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self resetSurroundingPages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoScrollViewDidDoubleTapToZoom: (NIPhotoScrollView *)photoScrollView
                                didZoomIn: (BOOL)didZoomIn {
  if ([self.delegate respondsToSelector:@selector(photoAlbumScrollView:didZoomIn:)]) {
    [self.delegate photoAlbumScrollView:self didZoomIn:didZoomIn];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  NIDASSERT(nil != _dataSource);

  // Remove any visible pages from the view before we release the sets.
  for (NIPhotoScrollView* page in _visiblePages) {
    [page removeFromSuperview];
  }

  NI_RELEASE_SAFELY(_visiblePages);
  NI_RELEASE_SAFELY(_recycledPages);

  // Reset the state of the scroll view.
  _isModifyingContentOffset = YES;
  _pagingScrollView.contentSize = self.bounds.size;
  _pagingScrollView.contentOffset = CGPointZero;
  _isModifyingContentOffset = NO;

  // If there is no data source then we can't do anything particularly interesting.
  if (nil == _dataSource) {
    return;
  }

  _visiblePages = [[NSMutableSet alloc] init];
  _recycledPages = [[NSMutableSet alloc] init];

  // Cache the number of pages.
  _numberOfPages = [_dataSource numberOfPhotosInPhotoScrollView:self];

  _pagingScrollView.frame = [self frameForPagingScrollView];

  // The content size is calculated based on the number of pages and the scroll view frame.
  _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

  // Begin requesting the photo information from the data source.
  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadPhoto: (UIImage *)image
             atIndex: (NSInteger)photoIndex
           photoSize: (NIPhotoScrollViewPhotoSize)photoSize {
  for (NIPhotoScrollView* page in _visiblePages) {
    if (page.photoIndex == photoIndex) {

      page.zoomingIsEnabled = ([self isZoomingEnabled]
                               && (NIPhotoScrollViewPhotoSizeOriginal == photoSize));

      // Only replace the photo if it's of a higher quality than one we're already showing.
      if (photoSize > page.photoSize) {
        [page setImage:image photoSize:photoSize];

        // Notify the delegate that the photo has been loaded.
        if (NIPhotoScrollViewPhotoSizeOriginal == photoSize) {
          [self notifyDelegatePhotoDidLoadAtIndex:photoIndex];
        }
      }
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  // Here, our pagingScrollView bounds have not yet been updated for the new interface
  // orientation. This is a good place to calculate the content offset that we will
  // need in the new orientation.
  CGFloat offset = _pagingScrollView.contentOffset.x;
  CGFloat pageWidth = _pagingScrollView.bounds.size.width;

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
  _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
  _isModifyingContentOffset = wasModifyingContentOffset;

  // adjust frames and configuration of each visible page.
  for (NIPhotoScrollView* page in _visiblePages) {
    [page setFrameAndMaintainZoomAndCenter:[self frameForPageAtIndex:page.photoIndex]];
  }

  // Adjust contentOffset to preserve page location based on values collected prior to location.
  CGFloat pageWidth = _pagingScrollView.bounds.size.width;
  CGFloat newOffset = ((_firstVisiblePageIndexBeforeRotation * pageWidth)
                       + (_percentScrolledIntoFirstVisiblePage * pageWidth));
  _isModifyingContentOffset = YES;
  _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
  _isModifyingContentOffset = wasModifyingContentOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setZoomingAboveOriginalSizeIsEnabled:(BOOL)enabled {
  _zoomingAboveOriginalSizeIsEnabled = enabled;

  for (NIPhotoScrollView* page in _visiblePages) {
    page.zoomingAboveOriginalSizeIsEnabled = enabled;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasNext {
  return (self.currentCenterPhotoIndex < self.numberOfPhotos - 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasPrevious {
  return self.currentCenterPhotoIndex > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAnimateToPage:(NSNumber *)photoIndex {
  _isAnimatingToPhoto = NO;

  // Reset the content offset once the animation completes, just to be sure that the
  // viewer sits on a page bounds even if we rotate the device while animating.
  CGPoint offset = [self frameForPageAtIndex:[photoIndex intValue]].origin;
  offset.x -= self.pageHorizontalMargin;

  _isModifyingContentOffset = YES;
  _pagingScrollView.contentOffset = offset;
  _isModifyingContentOffset = NO;

  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPageAtIndex:(NSInteger)photoIndex animated:(BOOL)animated {
  if (_isAnimatingToPhoto) {
    // Don't allow re-entry for sliding animations.
    return;
  }

  CGPoint offset = [self frameForPageAtIndex:photoIndex].origin;
  offset.x -= self.pageHorizontalMargin;

  _isModifyingContentOffset = YES;
  [_pagingScrollView setContentOffset:offset animated:animated];

  NSNumber* index = [NSNumber numberWithInt:photoIndex];
  if (animated) {
    _isAnimatingToPhoto = YES;
    SEL selector = @selector(didAnimateToPage:);
    [NSObject cancelPreviousPerformRequestsWithTarget: self];

    // When the animation is finished we reset the content offset just in case the frame
    // changes while we're animating (like when rotating the device). To do this we need
    // to know the destination index for the animation.
    [self performSelector: selector
               withObject: index
               afterDelay: 0.4];

  } else {
    [self didAnimateToPage:index];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToNextAnimated:(BOOL)animated {
  if ([self hasNext]) {
    NSInteger index = self.currentCenterPhotoIndex + 1;

    [self moveToPageAtIndex:index animated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)moveToPreviousAnimated:(BOOL)animated {
  if ([self hasPrevious]) {
    NSInteger index = self.currentCenterPhotoIndex - 1;

    [self moveToPageAtIndex:index animated:animated];
  }
}


@end
