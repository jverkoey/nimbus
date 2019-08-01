//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "NetworkPhotoAlbumViewController.h"

#import "NIOverviewMemoryCacheController.h"
#import "NimbusOverview.h"
#import "NIOverviewView.h"
#import "NIOverviewPageView.h"
#import "AFNetworking.h"

#ifdef DEBUG
@interface NetworkPhotoAlbumViewController()
@property (nonatomic, retain) NIOverviewMemoryCachePageView* highQualityPage;
@property (nonatomic, retain) NIOverviewMemoryCachePageView* thumbnailPage;
@end
#endif

@interface NetworkPhotoAlbumViewController()
@property (nonatomic,strong) AFHTTPSessionManager *httpSessionManager;
@end

@implementation NetworkPhotoAlbumViewController

- (void)shutdown_NetworkPhotoAlbumViewController {
  [self.httpSessionManager invalidateSessionCancelingTasks:YES];

#ifdef DEBUG
  [[NIOverview view] removePageView:self.highQualityPage];
  [[NIOverview view] removePageView:self.thumbnailPage];
#endif
}

- (void)dealloc {
  [self shutdown_NetworkPhotoAlbumViewController];
}

- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
  return [NSString stringWithFormat:@"%zd", photoIndex];
}

- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex {
  BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
  NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
  return identifier;
}

- (id)identifierKeyFromIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInteger:identifier];
}

- (void)requestImageFromSource:(NSString *)source
                     photoSize:(NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex:(NSInteger)photoIndex {
  BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
  NSInteger identifier = [self identifierWithPhotoSize:photoSize photoIndex:photoIndex];
  id identifierKey = [self identifierKeyFromIdentifier:identifier];

  // Avoid duplicating requests.
  if ([_activeRequests containsObject:identifierKey]) {
    return;
  }

  NSURL* url = [NSURL URLWithString:source];
  
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

  [self.httpSessionManager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, UIImage* image) {
    // Store the image in the correct image cache.
    if (isThumbnail) {
      [_thumbnailImageCache storeObject: image
                               withName: photoIndexKey];

    } else {
      [_highQualityImageCache storeObject: image
                                 withName: photoIndexKey];
    }

    // If you decide to move this code around then ensure that this method is called from
    // the main thread. Calling it from any other thread will have undefined results.
    [self.photoAlbumView didLoadPhoto: image
                              atIndex: photoIndex
                            photoSize: photoSize];

    if (isThumbnail) {
      [self.photoScrubberView didLoadThumbnail:image atIndex:photoIndex];
    }

    [_activeRequests removeObject:identifierKey];

  } failure:nil];

  // Start the operation.
  [_activeRequests addObject:identifierKey];
}

#pragma mark - UIViewController


- (void)loadView {
  [super loadView];

  _activeRequests = [[NSMutableSet alloc] init];

  _highQualityImageCache = [[NIImageMemoryCache alloc] init];
  _thumbnailImageCache = [[NIImageMemoryCache alloc] init];

  self.httpSessionManager = [AFHTTPSessionManager manager];
  AFImageResponseSerializer *serializer = [AFImageResponseSerializer serializer];
  serializer.imageScale = 1;
  self.httpSessionManager.responseSerializer = serializer;
  self.httpSessionManager.operationQueue.maxConcurrentOperationCount = 5;

  [_highQualityImageCache setMaxNumberOfPixels:1024L*1024L*10L];
  [_thumbnailImageCache setMaxNumberOfPixelsUnderStress:1024L*1024L*3L];

  // Set the default loading image.
  self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                      NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];

#ifdef DEBUG
  self.highQualityPage = [NIOverviewMemoryCachePageView pageWithCache:self.highQualityImageCache];
  [[NIOverview view] addPageView:self.highQualityPage];
  self.thumbnailPage = [NIOverviewMemoryCachePageView pageWithCache:self.thumbnailImageCache];
  [[NIOverview view] addPageView:self.thumbnailPage];
#endif
}

- (void)viewDidUnload {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super viewDidUnload];
}

@end
