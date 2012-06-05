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

#import "CaptionedPhotoView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FacebookPhotoAlbumViewController

@synthesize facebookAlbumId = _facebookAlbumId;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_photoInformation);
  NI_RELEASE_SAFELY(_facebookAlbumId);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWith:(id)object {
  if ((self = [self initWithNibName:nil bundle:nil])) {
    self.facebookAlbumId = object;
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
  NSString* albumURLPath = [NSString stringWithFormat:
                            @"http://graph.facebook.com/%@/photos?limit=200",
                            self.facebookAlbumId];

  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NSURL* url = [NSURL URLWithString:albumURLPath];
  NINetworkJSONRequest* albumRequest = [[[NINetworkJSONRequest alloc] initWithURL:url] autorelease];

  // Facebook albums are painfully slow to load if they have a lot of comments. Even more
  // frustrating is that you can't ask *not* to receive the comments from the graph API.
  albumRequest.timeout = 200;

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
- (void)nimbusOperationWillFinish:(NINetworkRequestOperation *)operation {
  // This is called from the processing thread in order to allow us to turn the root object
  // into something more interesting.
  if (![operation.processedObject isKindOfClass:[NSDictionary class]]) {
    return;
  }

  id object = operation.processedObject;
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

      NSString* caption = [photo objectForKey:@"name"];
      NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       originalImageSource, @"originalSource",
                                       thumbnailImageSource, @"thumbnailSource",
                                       [NSValue valueWithCGSize:dimensions], @"dimensions",
                                       caption, @"caption",
                                       nil];
      [photoInformation addObject:prunedPhotoInfo];
    }
  }
  operation.processedObject = photoInformation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFinish:(NINetworkRequestOperation *)operation {
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

      [self didCancelRequestWithPhotoSize:NIPhotoScrollViewPhotoSizeOriginal
                               photoIndex:photoIndex];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NIPagingScrollViewPage>*)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  // TODO (jverkoey Nov 27, 2011): We should make this sort of custom logic easier to build.
  UIView<NIPagingScrollViewPage>* pageView = nil;
  NSString* reuseIdentifier = NSStringFromClass([CaptionedPhotoView class]);
  pageView = [pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
  if (nil == pageView) {
    pageView = [[[CaptionedPhotoView alloc] init] autorelease];
    pageView.reuseIdentifier = reuseIdentifier;
  }

  NIPhotoScrollView* photoScrollView = (NIPhotoScrollView *)pageView;
  photoScrollView.photoScrollViewDelegate = self.photoAlbumView;
  photoScrollView.zoomingAboveOriginalSizeIsEnabled = [self.photoAlbumView isZoomingAboveOriginalSizeEnabled];

  CaptionedPhotoView* captionedView = (CaptionedPhotoView *)pageView;
  captionedView.caption = [[_photoInformation objectAtIndex:pageIndex] objectForKey:@"caption"];
  
  return pageView;
}


@end
