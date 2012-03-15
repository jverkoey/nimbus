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

#import "NINetworkPhotoAlbumViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINetworkPhotoAlbumViewController

@synthesize networkPhotoInformation			= _networkPhotoInformation;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown_NetworkPhotoAlbumViewController {
  for (NINetworkRequestOperation* request in _queue.operations) {
    request.delegate = nil;
  }
	
	[super shutdown];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super dealloc];
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

  // We must use __block here to avoid creating a retain cycle with the readOp.
  __block NINetworkRequestOperation* readOp = [[[NINetworkRequestOperation alloc] initWithURL:url] autorelease];
  readOp.timeout = 30;

  // Set an negative index for thumbnail requests so that they don't get cancelled by
  // photoAlbumScrollView:stopLoadingPhotoAtIndex:
  readOp.tag = identifier;

  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

  // The completion block will be executed on the main thread, so we must be careful not
  // to do anything computationally expensive here.
  [readOp setDidFinishBlock:^(NIOperation* operation) {
    UIImage* image = [UIImage imageWithData:readOp.data];

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
  }];

  // When this request is canceled (like when we're quickly flipping through an album)
  // the request will fail, so we must be careful to remove the request from the active set.
  [readOp setDidFailWithErrorBlock:^(NIOperation* operation, NSError* error) {
    [_activeRequests removeObject:identifierKey];
  }];


  // Set the operation priority level.

  if (NIPhotoScrollViewPhotoSizeThumbnail == photoSize) {
    // Thumbnail images should be lower priority than full-size images.
    [readOp setQueuePriority:NSOperationQueuePriorityLow];

  } else {
    [readOp setQueuePriority:NSOperationQueuePriorityNormal];
  }


  // Start the operation.

  [_activeRequests addObject:identifierKey];

  [_queue addOperation:readOp];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  // Set the default loading image.
  self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                      NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super viewDidUnload];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationWillFinish:(NINetworkRequestOperation *)operation {
	NSException *ex = [NSException exceptionWithName:@"invalid method implementation" reason:@"operationWillFinish: must be implemented in a subclass of NIPhotoAlbumViewController" userInfo:nil];
	
	[ex raise];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFinish:(NINetworkRequestOperation *)operation {
  _photoInformation = [operation.processedObject retain];
	
  [self.photoAlbumView reloadData];
	
  [self loadThumbnails];
  
  [self.photoScrubberView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addImageSourceURL:(NSString *)originalSourceURL 
				thumbnailSourceURL:(NSString *)thumbnailSourceURL 
								dimensions:(CGSize)dimensions {
	//
	NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
																	 originalSourceURL, keyOriginalSourceURL,
																	 thumbnailSourceURL, keyThumbnailSourceURL,
																	 [NSValue valueWithCGSize:dimensions], keyImageDimensions,
																	 nil];
	
	[_networkPhotoInformation addObject:prunedPhotoInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addImageSourceURL:(NSString *)originalSourceURL 
				thumbnailSourceURL:(NSString *)thumbnailSourceURL 
								dimensions:(CGSize)dimensions 
									 caption:(NSString *)caption {
	//
		NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
																		 originalSourceURL, keyOriginalSourceURL,
																		 thumbnailSourceURL, keyThumbnailSourceURL,
																		 [NSValue valueWithCGSize:dimensions], keyImageDimensions,
																		 caption, keyImageCaption,
																		 nil];
		
		[_networkPhotoInformation addObject:prunedPhotoInfo];	
}


@end
