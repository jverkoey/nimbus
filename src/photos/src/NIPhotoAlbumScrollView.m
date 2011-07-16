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

const CGFloat NIPhotoAlbumScrollViewDefaultPageHorizontalMargin = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoAlbumScrollView

@synthesize loadingImage = _loadingImage;
@synthesize pageHorizontalMargin = _pageHorizontalMargin;
@synthesize zoomingIsEnabled = _zoomingIsEnabled;
@synthesize dataSource = _dataSource;


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

    _firstVisiblePageIndexBeforeRotation = -1;
    _percentScrolledIntoFirstVisiblePage = -1;

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
  return floorf((contentOffset.x + boundsSize.width / 2) / boundsSize.width);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSRange)visiblePageRange {
  NSInteger currentVisiblePageIndex = [self currentVisiblePageIndex];

  int firstVisiblePageIndex = MAX(currentVisiblePageIndex - 1, 0);
  int lastVisiblePageIndex  = MIN(currentVisiblePageIndex + 1, _numberOfPages - 1);

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
  UIImage* image = [_dataSource photoAlbumScrollView: self
                                        photoAtIndex: index
                                           photoSize: &photoSize
                                           isLoading: &isLoading];

  if (nil == image) {
    page.zoomingIsEnabled = NO;
    [page setImage:self.loadingImage photoSize:NIPhotoScrollViewPhotoSizeUnknown];

  } else {
    page.zoomingIsEnabled = self.zoomingIsEnabled;
    if (photoSize > page.photoSize) {
      [page setImage:image photoSize:photoSize];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPage:(NIPhotoScrollView *)page {
  page.zoomScale = page.minimumZoomScale;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateVisiblePages {
  NSRange visiblePageRange = [self visiblePageRange];

  NSInteger currentVisiblePageIndex = [self currentVisiblePageIndex];

  // Recycle no-longer-visible pages and reset off-screen pages.
  for (NIPhotoScrollView* page in _visiblePages) {
    if (!NSLocationInRange(page.photoIndex, visiblePageRange)) {
      [_recycledPages addObject:page];
      [page removeFromSuperview];

      if ([_dataSource respondsToSelector:
           @selector(photoAlbumScrollView:stopLoadingPhotoAtIndex:)]) {
        [_dataSource photoAlbumScrollView: self
                  stopLoadingPhotoAtIndex: page.photoIndex];
      }

    } else if (page.photoIndex != currentVisiblePageIndex) {
      [self resetPage:page];
    }
  }
  [_visiblePages minusSet:_recycledPages];

  // Add missing pages.
  for (int index = visiblePageRange.location; index < NSMaxRange(visiblePageRange); ++index) {
    if (![self isDisplayingPageForIndex:index]) {
      NIPhotoScrollView* page = [self dequeueRecycledPage];

      if (nil == page) {
        page = [[[NIPhotoScrollView alloc] init] autorelease];
      }

      // This will only be called once each time the page is shown.
      [self configurePage:page forIndex:index];

      [_pagingScrollView addSubview:page];
      [_visiblePages addObject:page];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
  NI_RELEASE_SAFELY(_visiblePages);
  NI_RELEASE_SAFELY(_recycledPages);

  _visiblePages = [[NSMutableSet alloc] initWithCapacity:3];
  _recycledPages = [[NSMutableSet alloc] init];

  _numberOfPages = [_dataSource numberOfPhotosInPhotoScrollView:self];

  _pagingScrollView.frame = [self frameForPagingScrollView];
  _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

  [self updateVisiblePages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadPhoto: (UIImage *)image
             atIndex: (NSInteger)photoIndex
           photoSize: (NIPhotoScrollViewPhotoSize)photoSize {
  for (NIPhotoScrollView* page in _visiblePages) {
    if (page.photoIndex == photoIndex) {
      page.zoomingIsEnabled = self.zoomingIsEnabled;
      [page setImage:image photoSize:photoSize];
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
  // Recalculate contentSize based on current orientation.
  _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

  // adjust frames and configuration of each visible page.
  for (NIPhotoScrollView* page in _visiblePages) {
    [page setFrameAndMaintainZoomAndCenter:[self frameForPageAtIndex:page.photoIndex]];
  }

  // Adjust contentOffset to preserve page location based on values collected prior to location.
  CGFloat pageWidth = _pagingScrollView.bounds.size.width;
  CGFloat newOffset = ((_firstVisiblePageIndexBeforeRotation * pageWidth)
                       + (_percentScrolledIntoFirstVisiblePage * pageWidth));
  _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
}


@end
