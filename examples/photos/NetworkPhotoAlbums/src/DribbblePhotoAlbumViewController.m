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

#import "DribbblePhotoAlbumViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DribbblePhotoAlbumViewController

@synthesize apiPath = _apiPath;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_photoInformation);
  NI_RELEASE_SAFELY(_apiPath);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWith:(id)object {
  if ((self = [self initWithNibName:nil bundle:nil])) {
    self.apiPath = object;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
  for (NSInteger ix = 0; ix < [_photoInformation count]; ++ix) {
    NSDictionary* photo = [_photoInformation objectAtIndex:ix];

    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];

    // Don't load the thumbnail if it's already in memory.
    if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
      NSString* source = [photo objectForKey:@"thumbnailSource"];
      [self requestImageFromSource: source
                         photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                        photoIndex: ix];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadAlbumInformation {
  NSString* albumURLPath = [@"http://api.dribbble.com" stringByAppendingString:self.apiPath];

  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NSURL* url = [NSURL URLWithString:albumURLPath];
  NINetworkRequestOperation* albumRequest = [[[NINetworkJSONRequest alloc] initWithURL:url] autorelease];
  albumRequest.timeout = 30;

  // When the request fully completes we'll be notified via this delegate on the main thread.
  albumRequest.delegate = self;

  [self.queue addOperation:albumRequest];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.photoAlbumView.dataSource = self;
  self.photoScrubberView.dataSource = self;

  // Dribbble is for mockups and designs, so we don't want to allow the photos to be zoomed
  // in and become blurry.
  self.photoAlbumView.zoomingAboveOriginalSizeIsEnabled = NO;

  // This title will be displayed until we get the results back for the album information.
  self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");

  [self loadAlbumInformation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  NI_RELEASE_SAFELY(_photoInformation);

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationWillFinish:(NINetworkRequestOperation *)operation {
  // This is called from the processing thread in order to allow us to turn the root object
  // into something more interesting.
  if (![operation.processedObject isKindOfClass:[NSDictionary class]]) {
    return;
  }

  id object = operation.processedObject;
  NSArray* data = [object objectForKey:@"shots"];
  
  NSMutableArray* photoInformation = [NSMutableArray arrayWithCapacity:[data count]];
  for (NSDictionary* photo in data) {
    
    // Gather the high-quality photo information.
    NSString* originalImageSource = [photo objectForKey:@"image_url"];
    NSInteger width = [[photo objectForKey:@"width"] intValue];
    NSInteger height = [[photo objectForKey:@"height"] intValue];
    
    // We gather the highest-quality photo's dimensions so that we can size the thumbnails
    // correctly until the high-quality image is downloaded.
    CGSize dimensions = CGSizeMake(width, height);
    
    NSString* thumbnailImageSource = [photo objectForKey:@"image_teaser_url"];
    
    NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     originalImageSource, @"originalSource",
                                     thumbnailImageSource, @"thumbnailSource",
                                     [NSValue valueWithCGSize:dimensions], @"dimensions",
                                     nil];
    [photoInformation addObject:prunedPhotoInfo];
  }

  operation.processedObject = photoInformation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFinish:(NINetworkRequestOperation *)operation {
  _photoInformation = [operation.processedObject retain];

  [self.photoAlbumView reloadData];

  [self loadThumbnails];
  
  [self.photoScrubberView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrubberViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
  return [_photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex {
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
  
  UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
  if (nil == image) {
    NSDictionary* photo = [_photoInformation objectAtIndex:thumbnailIndex];
    
    NSString* thumbnailSource = [photo objectForKey:@"thumbnailSource"];
    [self requestImageFromSource: thumbnailSource
                       photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                      photoIndex: thumbnailIndex];
  }
  
  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
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

  image = [self.highQualityImageCache objectWithName:photoIndexKey];
  if (nil != image) {
    *photoSize = NIPhotoScrollViewPhotoSizeOriginal;

  } else {
    NSString* source = [photo objectForKey:@"originalSource"];
    [self requestImageFromSource: source
                       photoSize: NIPhotoScrollViewPhotoSizeOriginal
                      photoIndex: photoIndex];

    *isLoading = YES;

    // Try to return the thumbnail image if we can.
    image = [self.thumbnailImageCache objectWithName:photoIndexKey];
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
  for (NIOperation* op in [self.queue operations]) {
    if (op.tag == photoIndex) {
      [op cancel];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}


@end
