//
//  NIPhotoAlbumViewController.h
//
//  Created by Gregory Hill on 11/3/11.
//  Copyright (c) 2011 Hillside Apps, LLC. All rights reserved.
//

#import "NIPhotoAlbumScrollView.h"

/**
 * Definitions for building dictionary containing image data.  Used in subclasses of NIPhotoAlbumViewController
 * 	to do the heavy lifting as far as building.  Then used by NIPhotoAlbumViewController 
 *	to access the data for display purposes.
 */
#define keyOriginalSourceURL			@"originalSource"
#define keyThumbnailSourceURL			@"thumbnailSource"
#define keyImageDimensions				@"dimensions"
#define keyImageCaption						@"caption"


@interface NIPhotoAlbumViewController : UIViewController <
	NIPhotoAlbumScrollViewDataSource,
	NIPhotoScrubberViewDataSource
> {
	// Views
	NIPhotoAlbumScrollView* _photoAlbumView;
	
	// Caches
	NIImageMemoryCache* _highQualityImageCache;
	NIImageMemoryCache* _thumbnailImageCache;

  NSOperationQueue* _queue;
  
  NSMutableSet* _activeRequests;
	
  NSArray* _photoInformation;
	
}

/**
 * The photo album view.
 */
@property (nonatomic, readonly, retain) NIPhotoAlbumScrollView* photoAlbumView;

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
@property (nonatomic, readonly, retain) NIImageMemoryCache* highQualityImageCache;

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
@property (nonatomic, readonly, retain) NIImageMemoryCache* thumbnailImageCache;

/**
 * The operation queue that runs all of the network and processing operations.
 *
 * This is unloaded when the controller's view is unloaded from memory.
 */
@property (nonatomic, readonly, retain) NSOperationQueue* queue;


- (void) shutdown;

/**
 * Generate the in-memory cache key for the given index.
 */
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex;

- (void) initImageCaches;

- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex;

- (id)identifierKeyFromIdentifier:(NSInteger)identifier;

- (void) initPhotoAlbumViewWithFrame:(CGRect)photoAlbumFrame delegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate;

- (void)loadThumbnails;


/**
 * Request an image from a source URL and store the result in the corresponding image cache.
 *
 *      @param source       The image's source URL path.
 *      @param photoSize    The size of the photo being requested.
 *      @param photoIndex   The photo index used to store the image in the memory cache.
 *		
 *		Method at this level is "abstract" for now.  Will be implemented by sub-classes to fulfill on requests based on type of image source.
 *		For example, the source could be on the web, or in the file system, or a CoreData repository.
 */
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex;

- (void)didCancelRequestWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                           photoIndex:(NSInteger)photoIndex;


/**
 Helper methods to load photo information
 */
//- (void) addPhoto:(NSString *)originalSourceURL thumbnailSourceURL:(NSString *)thumbnailSourceURL dimensions:(CGSize)dimensions;
//
//- (void) addPhoto:(NSString *)originalSourceURL thumbnailSourceURL:(NSString *)thumbnailSourceURL dimensions:(CGSize)dimensions caption:(NSString *)caption;


@end
