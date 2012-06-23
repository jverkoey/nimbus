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

#import "NetworkPhotoAlbumViewController.h"

#import "NIOverviewMemoryCacheController.h"
#import "NimbusOverview.h"
#import "NIOverviewView.h"
#import "NIOverviewPageView.h"
#import "AFNetworking.h"

#ifdef DEBUG
@interface NetworkPhotoAlbumViewController()
@property (nonatomic, readwrite, retain) NIOverviewMemoryCachePageView* highQualityPage;
@property (nonatomic, readwrite, retain) NIOverviewMemoryCachePageView* thumbnailPage;
@end
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkPhotoAlbumViewController

@synthesize highQualityImageCache = _highQualityImageCache;
@synthesize thumbnailImageCache = _thumbnailImageCache;
@synthesize queue = _queue;
#ifdef DEBUG
@synthesize highQualityPage = _highQualityPage;
@synthesize thumbnailPage = _thumbnailPage;
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown_NetworkPhotoAlbumViewController {
  [_queue cancelAllOperations];

#ifdef DEBUG
  [[NIOverview view] removePageView:self.highQualityPage];
  [[NIOverview view] removePageView:self.thumbnailPage];
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self shutdown_NetworkPhotoAlbumViewController];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
  return [NSString stringWithFormat:@"%d", photoIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex {
  BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
  NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
  return identifier;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)identifierKeyFromIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInt:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  request.timeoutInterval = 30;
  
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

  AFImageRequestOperation* readOp =
  [AFImageRequestOperation imageRequestOperationWithRequest:request
                                       imageProcessingBlock:nil success:
   ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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
     
   } failure:
   ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
     
   }];

  readOp.imageScale = 1;

  // Set the operation priority level.

  if (NIPhotoScrollViewPhotoSizeThumbnail == photoSize) {
    // Thumbnail images should be lower priority than full-size images.
    [readOp setQueuePriority:NSOperationQueuePriorityLow];

  } else {
    [readOp setQueuePriority:NSOperationQueuePriorityNormal];
  }

  // Start the operation.

  [_queue addOperation:readOp];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _activeRequests = [[NSMutableSet alloc] init];

  _highQualityImageCache = [[NIImageMemoryCache alloc] init];
  _thumbnailImageCache = [[NIImageMemoryCache alloc] init];

  [_highQualityImageCache setMaxNumberOfPixels:1024L*1024L*10L];
  [_highQualityImageCache setMaxNumberOfPixelsUnderStress:1024L*1024L*3L];

  _queue = [[NSOperationQueue alloc] init];
  [_queue setMaxConcurrentOperationCount:5];

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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super viewDidUnload];
}


@end
