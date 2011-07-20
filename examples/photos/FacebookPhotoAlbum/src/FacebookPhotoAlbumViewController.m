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

#import "FacebookPhotoAlbumViewController.h"

#import "NIHTTPRequest.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FacebookPhotoAlbumViewController

@synthesize facebookAlbumId = _facebookAlbumId;
@synthesize highQualityImageCache = _highQualityImageCache;
@synthesize thumbnailImageCache = _thumbnailImageCache;
@synthesize queue = _queue;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_facebookAlbumId);

  [super dealloc];
}


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
- (void)loadThumbnails {
  for (NSInteger ix = 0; ix < [_photoInformation count]; ++ix) {
    NSDictionary* photo = [_photoInformation objectAtIndex:ix];

    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];

    // Don't load the thumbnail if it's already in memory.
    if (![_thumbnailImageCache hasObjectWithName:photoIndexKey]) {
      NSString* source = [photo objectForKey:@"thumbnailSource"];
      [self requestImageFromSource: source
                         photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                        photoIndex: ix];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadAlbumInformation {
  NSString* albumURLPath = [NSString stringWithFormat:
                            @"http://graph.facebook.com/%@/photos",
                            self.facebookAlbumId];

  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NIProcessorHTTPRequest* albumRequest = [[[NIJSONKitProcessorHTTPRequest alloc] initWithURL:
                                           [NSURL URLWithString:albumURLPath]] autorelease];

  // When the request fully completes we'll be notified via this delegate on the main thread.
  albumRequest.delegate = self;

  // When the request downloads the JSON we plan to process it in the thread. We use
  // [self class] here to emphasize that we should not be accessing any instance properties
  // from a separate thread.
  albumRequest.processorDelegate = (id)[self class];

  [_queue addOperation:albumRequest];
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

  self.photoAlbumView.dataSource = self;

  // This title will be displayed until we get the results back for the album information.
  self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");

  [self loadAlbumInformation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  NI_RELEASE_SAFELY(_highQualityImageCache);
  NI_RELEASE_SAFELY(_thumbnailImageCache);
  NI_RELEASE_SAFELY(_queue);
  NI_RELEASE_SAFELY(_photoInformation);

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ASIHTTPRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished:(NIProcessorHTTPRequest *)request {
  _photoInformation = [request.processedObject retain];

  [self loadThumbnails];

  // Reload the album data after we fire off the thumbnail requests so that the thumbnails
  // get the initial priority.
  [self.photoAlbumView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIProcessorDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)processor:(id)processor processObject:(id)object error:(NSError **)processingError {
  // This is called from the processing thread in order to allow us to turn the root object
  // into something more interesting.
  if (![object isKindOfClass:[NSDictionary class]]) {
    return nil;
  }

  NSArray* data = [object objectForKey:@"data"];

  NSMutableArray* photoInformation = [NSMutableArray arrayWithCapacity:[data count]];
  for (NSDictionary* photo in data) {
    NSArray* images = [photo objectForKey:@"images"];

    if ([images count] > 0) {
      // Sort the images in descending order by image size.
      NSArray* sortedImages =
      [images sortedArrayUsingDescriptors:
       [NSArray arrayWithObject:
        [[[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO] autorelease]]];

      // Gather the high-quality photo information.
      NSDictionary* originalImage = [sortedImages objectAtIndex:0];
      NSString* originalImageSource = [originalImage objectForKey:@"source"];
      NSInteger width = [[originalImage objectForKey:@"width"] intValue];
      NSInteger height = [[originalImage objectForKey:@"height"] intValue];

      // We gather the highest-quality photo's dimensions so that we can size the thumbnails
      // correctly until the high-quality image is downloaded.
      CGSize dimensions = CGSizeMake(width, height);

      NSInteger numberOfImages = [sortedImages count];

      // 0 being the lowest quality. On larger screens we fetch larger thumbnails.
      NSInteger qualityLevel = (NIIsPad() || NIScreenScale() > 1) ? 1 : 0;

      NSInteger thumbnailIndex = ((numberOfImages - 1)
                                  - MIN(qualityLevel, numberOfImages - 2));

      NSString* thumbnailImageSource = nil;
      if (0 < thumbnailIndex) {
        thumbnailImageSource = [[sortedImages objectAtIndex:thumbnailIndex] objectForKey:@"source"];
      }

      NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       originalImageSource, @"originalSource",
                                       thumbnailImageSource, @"thumbnailSource",
                                       [NSValue valueWithCGSize:dimensions], @"dimensions",
                                       nil];
      [photoInformation addObject:prunedPhotoInfo];
    }
  }
  return photoInformation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInPhotoScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
  return [_photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
  UIImage* image = nil;

  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

  NSDictionary* photo = [_photoInformation objectAtIndex:photoIndex];

  // Let the photo album view know how large the photo will be once it's fully loaded.
  *originalPhotoDimensions = [[photo objectForKey:@"dimensions"] CGSizeValue];

  image = [_highQualityImageCache objectWithName:photoIndexKey];
  if (nil != image) {
    *photoSize = NIPhotoScrollViewPhotoSizeOriginal;

  } else {
    NSString* source = [photo objectForKey:@"originalSource"];
    [self requestImageFromSource: source
                       photoSize: NIPhotoScrollViewPhotoSizeOriginal
                      photoIndex: photoIndex];

    *isLoading = YES;

    // Try to return the thumbnail image if we can.
    image = [_thumbnailImageCache objectWithName:photoIndexKey];
    if (nil != image) {
      *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;

    } else {
      // Load the thumbnail as well.
      NSString* thumbnailSource = [photo objectForKey:@"thumbnailSource"];
      [self requestImageFromSource: thumbnailSource
                         photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                        photoIndex: photoIndex];

    }
  }

  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
  for (ASIHTTPRequest* op in [_queue operations]) {
    if (op.tag == photoIndex) {
      [op cancel];
    }
  }
}


@end
