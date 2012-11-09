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
#import "NIPhotoAlbumScrollViewDataSource.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoAlbumScrollView

@synthesize loadingImage = _loadingImage;
@synthesize photoViewBackgroundColor = _photoViewBackgroundColor;
@synthesize zoomingIsEnabled = _zoomingIsEnabled;
@synthesize zoomingAboveOriginalSizeIsEnabled = _zoomingAboveOriginalSizeIsEnabled;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Default state.
    self.zoomingIsEnabled = YES;
    self.zoomingAboveOriginalSizeIsEnabled = YES;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBackgroundColor:(UIColor *)backgroundColor {
  [super setBackgroundColor:backgroundColor];

  self.pagingScrollView.backgroundColor = backgroundColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)notifyDelegatePhotoDidLoadAtIndex:(NSInteger)photoIndex {
  if (photoIndex == (self.centerPageIndex + 1)
      && [self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidLoadNextPhoto:)]) {
    [self.delegate photoAlbumScrollViewDidLoadNextPhoto:self];

  } else if (photoIndex == (self.centerPageIndex - 1)
             && [self.delegate respondsToSelector:@selector(photoAlbumScrollViewDidLoadPreviousPhoto:)]) {
    [self.delegate photoAlbumScrollViewDidLoadPreviousPhoto:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Visible Page Management


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willDisplayPage:(NIPhotoScrollView *)page {
  // When we ask the data source for the image we expect the following to happen:
  // 1) If the data source has any image at this index, it should return it and set the
  //    photoSize accordingly.
  // 2) If the returned photo is not the highest quality available, the data source should
  //    start loading the high quality photo and set isLoading to YES.
  // 3) If no photo was available, then the data source should start loading the photo
  //    at its highest available quality and nil should be returned. The loadingImage property
  //    will be displayed until the image is loaded. isLoading should be set to YES.
  NIPhotoScrollViewPhotoSize photoSize = NIPhotoScrollViewPhotoSizeUnknown;
  BOOL isLoading = NO;
  CGSize originalPhotoDimensions = CGSizeZero;
  UIImage* image = [self.dataSource photoAlbumScrollView: self
                                            photoAtIndex: page.pageIndex
                                               photoSize: &photoSize
                                               isLoading: &isLoading
                                 originalPhotoDimensions: &originalPhotoDimensions];

  page.photoDimensions = originalPhotoDimensions;
  page.loading = isLoading;

  if (nil == image) {
    page.zoomingIsEnabled = NO;
    [page setImage:self.loadingImage photoSize:NIPhotoScrollViewPhotoSizeUnknown];

  } else {
    BOOL updateImage = photoSize > page.photoSize;
    if (updateImage) {
      [page setImage:image photoSize:photoSize];
    }

    // Configure this after the image is set otherwise if the page's image isn't there
	// e.g. (after prepareForReuse), zooming will always be disabled
    page.zoomingIsEnabled = ([self isZoomingEnabled]
                             && (NIPhotoScrollViewPhotoSizeOriginal == photoSize));

    if (updateImage && NIPhotoScrollViewPhotoSizeOriginal == photoSize) {
      [self notifyDelegatePhotoDidLoadAtIndex:page.pageIndex];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRecyclePage:(UIView<NIPagingScrollViewPage> *)page {
  // Give the data source the opportunity to kill any asynchronous operations for this
  // now-recycled page.
  if ([self.dataSource respondsToSelector:
       @selector(photoAlbumScrollView:stopLoadingPhotoAtIndex:)]) {
    [self.dataSource photoAlbumScrollView: self
                  stopLoadingPhotoAtIndex: page.pageIndex];
  }
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
- (UIView<NIPagingScrollViewPage> *)pagingScrollView:(NIPagingScrollView *)pagingScrollView
                                    pageViewForIndex:(NSInteger)pageIndex {
  UIView<NIPagingScrollViewPage>* pageView = nil;
  NSString* reuseIdentifier = @"photo";
  pageView = [pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
  if (nil == pageView) {
    pageView = [[NIPhotoScrollView alloc] init];
    pageView.reuseIdentifier = reuseIdentifier;
    pageView.backgroundColor = self.photoViewBackgroundColor;
  }

  NIPhotoScrollView* photoScrollView = (NIPhotoScrollView *)pageView;
  photoScrollView.photoScrollViewDelegate = self;
  photoScrollView.zoomingAboveOriginalSizeIsEnabled = [self isZoomingAboveOriginalSizeEnabled];

  return pageView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadPhoto: (UIImage *)image
             atIndex: (NSInteger)pageIndex
           photoSize: (NIPhotoScrollViewPhotoSize)photoSize {
  for (NIPhotoScrollView* page in self.visiblePages) {
    if (page.pageIndex == pageIndex) {

      // Only replace the photo if it's of a higher quality than one we're already showing.
      if (photoSize > page.photoSize) {
        page.loading = NO;
        [page setImage:image photoSize:photoSize];

        page.zoomingIsEnabled = ([self isZoomingEnabled]
                                 && (NIPhotoScrollViewPhotoSizeOriginal == photoSize));

        // Notify the delegate that the photo has been loaded.
        if (NIPhotoScrollViewPhotoSizeOriginal == photoSize) {
          [self notifyDelegatePhotoDidLoadAtIndex:pageIndex];
        }
      }
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setZoomingAboveOriginalSizeIsEnabled:(BOOL)enabled {
  _zoomingAboveOriginalSizeIsEnabled = enabled;

  for (NIPhotoScrollView* page in self.visiblePages) {
    page.zoomingAboveOriginalSizeIsEnabled = enabled;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoViewBackgroundColor:(UIColor *)photoViewBackgroundColor {
  if (_photoViewBackgroundColor != photoViewBackgroundColor) {
      _photoViewBackgroundColor = photoViewBackgroundColor;
    
    for (UIView<NIPagingScrollViewPage>* page in self.visiblePages) {
      page.backgroundColor = photoViewBackgroundColor;
    }
  }
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
- (id<NIPhotoAlbumScrollViewDataSource>)dataSource {
  NIDASSERT([[super dataSource] conformsToProtocol:@protocol(NIPhotoAlbumScrollViewDataSource)]);
  return (id<NIPhotoAlbumScrollViewDataSource>)[super dataSource];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id<NIPhotoAlbumScrollViewDataSource>)dataSource {
  [super setDataSource:(id<NIPagingScrollViewDataSource>)dataSource];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPhotoAlbumScrollViewDelegate>)delegate {
  id<NIPagingScrollViewDelegate> superDelegate = [super delegate];
  NIDASSERT(nil == superDelegate
            || [superDelegate conformsToProtocol:@protocol(NIPhotoAlbumScrollViewDelegate)]);
  return (id<NIPhotoAlbumScrollViewDelegate>)superDelegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate {
  [super setDelegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate];
}


@end
