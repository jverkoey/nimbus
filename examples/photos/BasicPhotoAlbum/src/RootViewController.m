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

#import "RootViewController.h"

#import "NIHTTPRequest.h"
#import "NIJSONHTTPProcessor.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
  for (NSInteger ix = 0; ix < 4; ++ix) {
    __block NIReadFileFromDiskOperation* readOp =
    [[[NIReadFileFromDiskOperation alloc] initWithPathToFile:
      NIPathForBundleResource(nil, [NSString stringWithFormat:@"clouds_thumbnail/clouds_%d.jpeg", ix])]
     autorelease];

    readOp.tag = -1;

    NSString* photoIndexKey = [NSString stringWithFormat:@"%d", ix + 1];

    [readOp setWillFinishBlock:^{
      readOp.processedObject = [UIImage imageWithData:readOp.data];
    }];

    [readOp setDidFinishBlock:^{
      [_thumbnailImageCache storeObject: readOp.processedObject
                               withName: photoIndexKey];

      [self.photoAlbumView didLoadPhoto: readOp.processedObject
                                atIndex: ix + 1
                              photoSize: NIPhotoScrollViewPhotoSizeThumbnail];
    }];

    [_queue addOperation:readOp];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _highQualityImageCache = [[NIImageMemoryCache alloc] initWithCapacity:5];
  _thumbnailImageCache = [[NIImageMemoryCache alloc] initWithCapacity:5];

  _queue = [[NSOperationQueue alloc] init];
  // Load photos serially.
  [_queue setMaxConcurrentOperationCount:1];

  [self loadThumbnails];

  self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                      NIPathForBundleResource(nil, @"photoDefault.png")];
  self.photoAlbumView.dataSource = self;

  NSString* albumURLPath = @"http://graph.facebook.com/6196758417/photos";
  NIJSONHTTPRequest* albumRequest = [[[NIJSONHTTPRequest alloc] initWithURL:
                                      [NSURL URLWithString:albumURLPath]] autorelease];

  albumRequest.delegate = self;
  albumRequest.processorDelegate = (id)[self class];

  [_queue addOperation:albumRequest];
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
- (void)requestFinished:(NIJSONHTTPRequest *)request {
  _photoInformation = [request.rootObject retain];
  NSLog(@"%@", _photoInformation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIProcessorDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)request:(NIJSONHTTPRequest *)request processRootObject:(id)rootObject {
  // This is called from the processing thread in order to allow us to turn the root object
  // into something more interesting.
  if (![rootObject isKindOfClass:[NSDictionary class]]) {
    return nil;
  }
  NSArray* data = [rootObject objectForKey:@"data"];

  NSMutableArray* photoInformation = [NSMutableArray arrayWithCapacity:[data count]];
  for (NSDictionary* photo in data) {
    NSArray* images = [photo objectForKey:@"images"];

    NSArray* sortedImages =
    [images sortedArrayUsingDescriptors:
     [NSArray arrayWithObject:
      [NSSortDescriptor sortDescriptorWithKey:@"width" ascending:NO]]];

    NSString* originalImageSource = [[sortedImages objectAtIndex:0] objectForKey:@"source"];

    NSInteger thumbnailIndex = ([sortedImages count] - 1
                                - MIN([sortedImages count] - 2, NIIsPad() ? 3 : 0));

    NSString* thumbnailImageSource = nil;
    if (0 < thumbnailIndex) {
      thumbnailImageSource = [[sortedImages objectAtIndex:thumbnailIndex] objectForKey:@"source"];
    }

    NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     originalImageSource, @"originalSource",
                                     thumbnailImageSource, @"thumbnailSource",
                                     nil];
    [photoInformation addObject:prunedPhotoInfo];
  }
  return photoInformation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInPhotoScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
  return 5;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading {
  UIImage* image = nil;

  if (photoIndex > 0) {
    NSString* photoIndexKey = [NSString stringWithFormat:@"%d", photoIndex];

    image = [_highQualityImageCache objectWithName:photoIndexKey];
    if (nil != image) {
      *photoSize = NIPhotoScrollViewPhotoSizeOriginal;

    } else {
      // We must use the __block declarator here so that we don't create a retain cycle
      // when accessing the readOp in the blocks below.
      __block NIReadFileFromDiskOperation* readOp =
      [[[NIReadFileFromDiskOperation alloc] initWithPathToFile:
        NIPathForBundleResource(nil, [NSString stringWithFormat:@"clouds_original/clouds_%d.jpeg", photoIndex - 1])]
       autorelease];

      readOp.tag = photoIndex;

      [readOp setWillFinishBlock:^{
        readOp.processedObject = [UIImage imageWithData:readOp.data];
      }];

      [readOp setDidFinishBlock:^{
        [_highQualityImageCache storeObject: readOp.processedObject
                                   withName: photoIndexKey];

        [photoAlbumScrollView didLoadPhoto: readOp.processedObject
                                   atIndex: photoIndex
                                 photoSize: NIPhotoScrollViewPhotoSizeOriginal];
      }];

      [_queue addOperation:readOp];

      *isLoading = YES;

      image = [_thumbnailImageCache objectWithName:photoIndexKey];
      if (nil != image) {
        *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
      }
    }

  } else {
    *isLoading = YES;
  }

  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
  for (NIOperation* op in [_queue operations]) {
    if (op.tag == photoIndex) {
      [op cancel];
    }
  }
}


@end
