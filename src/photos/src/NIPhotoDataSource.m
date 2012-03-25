//
//  NIPhotoDataSource.m
//  Nimbus
//
//  Created by Gregory Hill on 3/14/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIPhotoDataSource.h"

@implementation NIPhotoDataSource

@synthesize photoAlbumView, photoInformation;

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
	[self shutdown_Queue];
	
	self.photoAlbumView = nil;
	
	[_queue cancelAllOperations];
	
	NI_RELEASE_SAFELY(_activeRequests);
	
	NI_RELEASE_SAFELY(_highQualityImageCache);
	NI_RELEASE_SAFELY(_thumbnailImageCache);
	NI_RELEASE_SAFELY(_queue);
}

- (void) shutdown_Queue {
}

- (void) setPhotoAlbumView:(NIPhotoAlbumScrollView *)_photoAlbumView {
	if(!photoAlbumView) {
		photoAlbumView = nil;
		
		NI_RELEASE_SAFELY(photoAlbumView);
	}

	photoAlbumView = _photoAlbumView;
	
	photoAlbumView.dataSource = self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) cacheKeyForPhotoIndex:(NSInteger)photoIndex {
    return [NSString stringWithFormat:@"%d", photoIndex];
}


/**
 * This needs to be overridden by the subclass that is specific to the data source 
 *	being used.  See NINetworkPhotoDataSource for an example of how this works.
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) requestImageFromSource: (NSString *)source
											photoSize: (NIPhotoScrollViewPhotoSize)photoSize
										 photoIndex: (NSInteger)photoIndex {
	//
	NSException *ex = [NSException exceptionWithName:@"invalid method implementation" reason:@"requestImageFromSource:photoSize:photoIndex: must be implemented in a subclass of NIPhotoDataSource" userInfo:nil];
	
	[ex raise];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) reload {
    [self.photoAlbumView reloadData];
	
    [self loadThumbnails];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadThumbnails {
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

- (void) cancelRequestWithIdentifier:(id)identifierKey {
	[_activeRequests removeObject:identifierKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger) numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
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
