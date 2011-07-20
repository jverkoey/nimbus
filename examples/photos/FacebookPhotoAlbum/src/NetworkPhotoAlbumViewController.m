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

#import "NIHTTPRequest.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NetworkPhotoAlbumViewController

@synthesize highQualityImageCache = _highQualityImageCache;
@synthesize thumbnailImageCache = _thumbnailImageCache;
@synthesize queue = _queue;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
  return [NSString stringWithFormat:@"%d", photoIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex {
  NSURL* url = [NSURL URLWithString:source];

  // We must use __block here to avoid creating a retain cycle with the readOp.
  __block NIHTTPRequest* readOp = [[[NIHTTPRequest alloc] initWithURL:url] autorelease];

  // Set an invalid index for thumbnail requests so that they don't get cancelled by
  // photoAlbumScrollView:stopLoadingPhotoAtIndex:
  readOp.tag = (photoSize == NIPhotoScrollViewPhotoSizeThumbnail) ? -1 : photoIndex;

  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

  // The completion block will be executed on the main thread, so we must be careful not
  // to do anything computationally expensive here.
  [readOp setCompletionBlock:^{
    UIImage* image = [UIImage imageWithData:[readOp responseData]];

    // Store the image in the correct image cache.
    if (NIPhotoScrollViewPhotoSizeThumbnail == photoSize) {
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
  }];


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

  _highQualityImageCache = [[NIImageMemoryCache alloc] init];
  _thumbnailImageCache = [[NIImageMemoryCache alloc] init];

  [_highQualityImageCache setMaxNumberOfPixelsUnderStress:1024*1024*3];

  _queue = [[NSOperationQueue alloc] init];

  // Set the default loading image.
  self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                      NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  NI_RELEASE_SAFELY(_highQualityImageCache);
  NI_RELEASE_SAFELY(_thumbnailImageCache);
  NI_RELEASE_SAFELY(_queue);

  [super viewDidUnload];
}


@end
