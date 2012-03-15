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

#import "NINetworkPhotoDataSource.h"

@implementation NINetworkPhotoDataSource

//@synthesize photoAlbumView, photoScrubberView, photoInformation;
//
//@synthesize highQualityImageCache = _highQualityImageCache;
//@synthesize thumbnailImageCache = _thumbnailImageCache;
//@synthesize queue = _queue;
//
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
	
    if (self) {
//        _activeRequests = [[NSMutableSet alloc] init];
//
//        _highQualityImageCache = [[NIImageMemoryCache alloc] init];
//        _thumbnailImageCache = [[NIImageMemoryCache alloc] init];
//
//        [_highQualityImageCache setMaxNumberOfPixelsUnderStress:1024*1024*3];
//
//        _queue = [[NSOperationQueue alloc] init];
//        [_queue setMaxConcurrentOperationCount:5];

        // Set the default loading image.
        self.photoAlbumView.loadingImage = [UIImage imageWithContentsOfFile:
                                            NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
    }

    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown {
	[super shutdown];
	
//    for (NINetworkRequestOperation* request in _queue.operations) {
//        request.delegate = nil;
//    }
//	
//    [_queue cancelAllOperations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex {
	//
    BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
    NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
    NSNumber* identifierKey = [NSNumber numberWithInt:identifier];

    // Avoid duplicating requests.
    if ([_activeRequests containsObject:identifierKey]) {
        return;
    }

    NSURL* url = [NSURL URLWithString:source];

    NINetworkRequestOperation* readOp = [[NINetworkRequestOperation alloc] initWithURL:url];
    readOp.timeout = 30;

    // Set an negative index for thumbnail requests so that they don't get cancelled by
    // photoAlbumScrollView:stopLoadingPhotoAtIndex:
    readOp.tag = isThumbnail ? -(photoIndex + 1) : photoIndex;

    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];

    // The completion block will be executed on the main thread, so we must be careful not
    // to do anything computationally expensive here.
    [readOp setDidFinishBlock:^(NIOperation *operation) {
        UIImage* image = [UIImage imageWithData:((NINetworkRequestOperation *) operation).data];

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
    [readOp setDidFailWithErrorBlock:^(NIOperation *operation, NSError *error) {
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

/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)loadThumbnails {
//    for (NSInteger ix = 0; ix < [self.photoInformation count]; ++ix) {
//        NSDictionary* photo = [self.photoInformation objectAtIndex:ix];
//
//        NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];
//
//        // Don't load the thumbnail if it's already in memory.
//        if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
//            NSString* source = [photo valueForKey:@"thumbnailSource"];
//            [self requestImageFromSource: source
//                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
//                              photoIndex: ix];
//        }
//    }
//}
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)reload {
//    [self.photoAlbumView reloadData];
//
//    [self loadThumbnails];
//
//    [self.photoScrubberView reloadData];
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark -
//#pragma mark NIPhotoScrubberViewDataSource
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
//    return [self.photoInformation count];
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
//              thumbnailAtIndex: (NSInteger)thumbnailIndex {
//    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
//
//    UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
//    if (nil == image) {
//        NSDictionary* photo = [self.photoInformation objectAtIndex:thumbnailIndex];
//
//        NSString* thumbnailSource = [photo valueForKey:@"thumbnailSource"];
//        [self requestImageFromSource: thumbnailSource
//                           photoSize: NIPhotoScrollViewPhotoSizeThumbnail
//                          photoIndex: thumbnailIndex];
//    }
//
//    return image;
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//#pragma mark -
//#pragma mark NIPhotoAlbumScrollViewDataSource
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (NSInteger)numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
//    return [self.photoInformation count];
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
//                     photoAtIndex: (NSInteger)photoIndex
//                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
//                        isLoading: (BOOL *)isLoading
//          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
//    UIImage* image = nil;
//
//    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
//
//    id photo = [self.photoInformation objectAtIndex:photoIndex];
//
//    // Let the photo album view know how large the photo will be once it's fully loaded.
//    *originalPhotoDimensions = [[photo valueForKey:@"dimensions"] CGSizeValue];
//
//    image = [self.highQualityImageCache objectWithName:photoIndexKey];
//    if (nil != image) {
//        *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
//
//    } else {
//        NSString* source = [photo valueForKey:@"originalSource"];
//        [self requestImageFromSource: source
//                           photoSize: NIPhotoScrollViewPhotoSizeOriginal
//                          photoIndex: photoIndex];
//
//        *isLoading = YES;
//
//        // Try to return the thumbnail image if we can.
//        image = [self.thumbnailImageCache objectWithName:photoIndexKey];
//        if (nil != image) {
//            *photoSize = NIPhotoScrollViewPhotoSizeThumbnail;
//
//        } else {
//            // Load the thumbnail as well.
//            NSString* thumbnailSource = [photo valueForKey:@"thumbnailSource"];
//            [self requestImageFromSource: thumbnailSource
//                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
//                              photoIndex: photoIndex];
//
//        }
//    }
//
//    return image;
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
//     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
//    for (NIOperation* op in [self.queue operations]) {
//        if (op.tag == photoIndex) {
//            [op cancel];
//        }
//    }
//}
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
//    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
//}



@end
