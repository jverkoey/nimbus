//
//  NIPhotoDataSource.h
//  Nimbus
//
//  Created by Gregory Hill on 3/14/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIPhotoAlbumScrollView.h"
#import "NIPhotoScrubberView.h"

#import "NIPhotoAlbumScrollViewDataSource.h"

/**
 * Definitions for building dictionary containing image data.
 */
#define keyOriginalSourceURL			@"originalSource"
#define keyThumbnailSourceURL			@"thumbnailSource"
#define keyImageDimensions				@"dimensions"
#define keyImageCaption					@"caption"


@interface NIPhotoDataSource : NSObject <NIPhotoAlbumScrollViewDataSource> {
@protected
    __strong NSOperationQueue* _queue;
	
    __strong NSMutableSet* _activeRequests;
	
    __strong NIImageMemoryCache* _highQualityImageCache;
    __strong NIImageMemoryCache* _thumbnailImageCache;
}

@property (nonatomic, strong) NSArray *photoInformation;

@property (nonatomic, unsafe_unretained) NIPhotoAlbumScrollView* photoAlbumView;

/**
 * The high quality image cache.
 *
 * All original-sized photos are stored in this cache.
 *
 * By default the cache is unlimited with a max stress size of 1024*1024*3 pixels.
 *
 * Images are stored with a name that corresponds directly to the photo index in the form "%d".
 *
 * This is unloaded when the controller's view is unloaded from memory.
 */
@property (nonatomic, readonly, strong) NIImageMemoryCache* highQualityImageCache;

/**
 * The thumbnail image cache.
 *
 * All thumbnail photos are stored in this cache.
 *
 * By default the cache is unlimited.
 *
 * Images are stored with a name that corresponds directly to the photo index in the form "%d".
 *
 * This is unloaded when the controller's view is unloaded from memory.
 */
@property (nonatomic, readonly, strong) NIImageMemoryCache* thumbnailImageCache;

/**
 * The operation queue that runs all of the network and processing operations.
 *
 * This is unloaded when the controller's view is unloaded from memory.
 */
@property (nonatomic, readonly, strong) NSOperationQueue* queue;


- (void) shutdown;

- (void) shutdown_Queue;


/**
 * Generate the in-memory cache key for the given index.
 */
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;

/**
 * Request an image from a source URL and store the result in the corresponding image cache.
 *
 *      @param source       The image's source URL path.
 *      @param photoSize    The size of the photo being requested.
 *      @param photoIndex   The photo index used to store the image in the memory cache.
 */
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex;

- (void)reload;

- (void)loadThumbnails;

- (void) cancelRequestWithIdentifier:(id)identifierKey;


@end
