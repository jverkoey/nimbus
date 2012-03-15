//
//  NIPhotoDataSource.m
//  Nimbus
//
//  Created by Gregory Hill on 3/14/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIPhotoDataSource.h"

@implementation NIPhotoDataSource

@synthesize photoAlbumView, photoScrubberView, photoInformation;

@synthesize highQualityImageCache = _highQualityImageCache;
@synthesize thumbnailImageCache = _thumbnailImageCache;
@synthesize queue = _queue;


- (id) init {
	self = [super init];
	
    if (self) {
        _activeRequests = [[NSMutableSet alloc] init];
		
        _highQualityImageCache = [[NIImageMemoryCache alloc] init];
        _thumbnailImageCache = [[NIImageMemoryCache alloc] init];
		
        [_highQualityImageCache setMaxNumberOfPixelsUnderStress:1024*1024*3];
		
        _queue = [[NSOperationQueue alloc] init];
        [_queue setMaxConcurrentOperationCount:5];
    }
	
	return self;
}

- (void) dealloc {
	[super dealloc];
	
	[self shutdown];
}

- (void) shutdown {
    for (NINetworkRequestOperation* request in _queue.operations) {
        request.delegate = nil;
    }
	
	_photoAlbumView = nil;
	
	[_queue cancelAllOperations];
	
	NI_RELEASE_SAFELY(_activeRequests);
	
	NI_RELEASE_SAFELY(_highQualityImageCache);
	NI_RELEASE_SAFELY(_thumbnailImageCache);
	NI_RELEASE_SAFELY(_queue);
}

- (void) setPhotoAlbumView:(NIPhotoAlbumScrollView *)_photoAlbumView {
	if(!photoAlbumView) {
		photoAlbumView = nil;
		
		NI_RELEASE_SAFELY(photoAlbumView);
	}

	photoAlbumView = _photoAlbumView;
	
	photoAlbumView.dataSource = self;
}

- (void) setPhotoScrubberView:(NIPhotoScrubberView *)_photoScrubberView {
	if(!photoScrubberView) {
		photoScrubberView = nil;
		
		NI_RELEASE_SAFELY(photoScrubberView);
	}
	
	photoScrubberView = _photoScrubberView;
	
	photoScrubberView.dataSource = self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
    return [NSString stringWithFormat:@"%d", photoIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex {
	//
//    BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
//    NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
//    NSNumber* identifierKey = [NSNumber numberWithInt:identifier];
//	
//    // Avoid duplicating requests.
//    if ([_activeRequests containsObject:identifierKey]) {
//        return;
//    }
//	
//    NSURL* url = [NSURL URLWithString:source];
//	
//    NINetworkRequestOperation* readOp = [[NINetworkRequestOperation alloc] initWithURL:url];
//    readOp.timeout = 30;
//	
//    // Set an negative index for thumbnail requests so that they don't get cancelled by
//    // photoAlbumScrollView:stopLoadingPhotoAtIndex:
//    readOp.tag = isThumbnail ? -(photoIndex + 1) : photoIndex;
//	
//    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
//	
//    // The completion block will be executed on the main thread, so we must be careful not
//    // to do anything computationally expensive here.
//    [readOp setDidFinishBlock:^(NIOperation *operation) {
//        UIImage* image = [UIImage imageWithData:((NINetworkRequestOperation *) operation).data];
//		
//        // Store the image in the correct image cache.
//        if (isThumbnail) {
//            [_thumbnailImageCache storeObject: image
//                                     withName: photoIndexKey];
//			
//        } else {
//            [_highQualityImageCache storeObject: image
//                                       withName: photoIndexKey];
//        }
//		
//        // If you decide to move this code around then ensure that this method is called from
//        // the main thread. Calling it from any other thread will have undefined results.
//        [self.photoAlbumView didLoadPhoto: image
//                                  atIndex: photoIndex
//                                photoSize: photoSize];
//		
//        if (isThumbnail) {
//            [self.photoScrubberView didLoadThumbnail:image atIndex:photoIndex];
//        }
//		
//        [_activeRequests removeObject:identifierKey];
//    }];
//	
//    // When this request is canceled (like when we're quickly flipping through an album)
//    // the request will fail, so we must be careful to remove the request from the active set.
//    [readOp setDidFailWithErrorBlock:^(NIOperation *operation, NSError *error) {
//        [_activeRequests removeObject:identifierKey];
//    }];
//	
//	
//    // Set the operation priority level.
//	
//    if (NIPhotoScrollViewPhotoSizeThumbnail == photoSize) {
//        // Thumbnail images should be lower priority than full-size images.
//        [readOp setQueuePriority:NSOperationQueuePriorityLow];
//		
//    } else {
//        [readOp setQueuePriority:NSOperationQueuePriorityNormal];
//    }
//	
//	
//    // Start the operation.
//	
//    [_activeRequests addObject:identifierKey];
//	
//    [_queue addOperation:readOp];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
    [self.photoAlbumView reloadData];
	
    [self loadThumbnails];
	
    [self.photoScrubberView reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
    for (NSInteger ix = 0; ix < [self.photoInformation count]; ++ix) {
        NSDictionary* photo = [self.photoInformation objectAtIndex:ix];
		
        NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];
		
        // Don't load the thumbnail if it's already in memory.
        if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
            NSString* source = [photo valueForKey:keyThumbnailSourceURL];
            [self requestImageFromSource: source
                               photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                              photoIndex: ix];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrubberViewDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
    return [self.photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex {
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
	
    UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
    if (nil == image) {
        NSDictionary* photo = [self.photoInformation objectAtIndex:thumbnailIndex];
		
        NSString* thumbnailSource = [photo valueForKey:keyThumbnailSourceURL];
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
    return [self.photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
	//
    UIImage* image = nil;
	
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
    id photo = [self.photoInformation objectAtIndex:photoIndex];
	
    // Let the photo album view know how large the photo will be once it's fully loaded.
    *originalPhotoDimensions = [[photo valueForKey:keyImageDimensions] CGSizeValue];
	
    image = [self.highQualityImageCache objectWithName:photoIndexKey];
    if (nil != image) {
        *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
		
    } else {
        NSString* source = [photo valueForKey:keyOriginalSourceURL];
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
            NSString* thumbnailSource = [photo valueForKey:keyThumbnailSourceURL];
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
	//
    for (NIOperation* op in [self.queue operations]) {
        if (op.tag == photoIndex) {
            [op cancel];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPagingScrollViewPage>) pagingScrollView:(NIPagingScrollView *)pagingScrollView 
							   pageViewForIndex:(NSInteger)pageIndex {
	//
    return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}


@end
