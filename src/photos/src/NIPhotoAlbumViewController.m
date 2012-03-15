//
//  NIPhotoAlbumViewController.m
//
//  Created by Gregory Hill on 11/3/11.
//  Copyright (c) 2011 Hillside Apps, LLC. All rights reserved.
//

#import "NIPhotoAlbumViewController.h"

@interface NIPhotoAlbumViewController()
- (void) initImageCaches;
@end

@implementation NIPhotoAlbumViewController

@synthesize photoAlbumView = _photoAlbumView;

@synthesize highQualityImageCache = _highQualityImageCache;
@synthesize thumbnailImageCache = _thumbnailImageCache;
@synthesize queue = _queue;


- (void) dealloc {
	[super dealloc];

  NI_RELEASE_SAFELY(_photoInformation);
}

- (void) shutdown {
	_photoAlbumView = nil;
	
  [_queue cancelAllOperations];

  NI_RELEASE_SAFELY(_activeRequests);

	NI_RELEASE_SAFELY(_highQualityImageCache);
	NI_RELEASE_SAFELY(_thumbnailImageCache);
  NI_RELEASE_SAFELY(_queue);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
	[super loadView];
	
  _activeRequests = [[NSMutableSet alloc] init];
	
	[self initImageCaches];
	
  _queue = [[NSOperationQueue alloc] init];
  [_queue setMaxConcurrentOperationCount:5];
}

- (void) viewDidUnload {
	[super viewDidUnload];
	
	NI_RELEASE_SAFELY(_photoInformation);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) initImageCaches {
	_highQualityImageCache = [[NIImageMemoryCache alloc] init];
	_thumbnailImageCache = [[NIImageMemoryCache alloc] init];
	
	[_highQualityImageCache setMaxNumberOfPixelsUnderStress:1024*1024*3];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForPhotoIndex:(NSInteger)photoIndex {
  return [NSString stringWithFormat:@"%d", photoIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex {
	//
  BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
  NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
  return identifier;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)identifierKeyFromIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInt:identifier];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) initPhotoAlbumViewWithFrame:(CGRect)photoAlbumFrame 
														delegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate {
	//
	_photoAlbumView = [[[NIPhotoAlbumScrollView alloc] initWithFrame:photoAlbumFrame] autorelease];
	
	_photoAlbumView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
										| UIViewAutoresizingFlexibleHeight);
	
	_photoAlbumView.delegate = delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
	//
	[self.photoAlbumView willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
														  duration: duration];
	
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
											duration:duration];
}


// Abstract method to be implemented in sub-classes.
- (void)requestImageFromSource: (NSString *)source
                     photoSize: (NIPhotoScrollViewPhotoSize)photoSize
                    photoIndex: (NSInteger)photoIndex {
	//
	NSException *ex = [NSException exceptionWithName:@"invalid method implementation" reason:@"requestImageFromSource:photoSize:photoIndex: must be implemented in a subclass of NIPhotoAlbumViewController" userInfo:nil];
	
	[ex raise];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didCancelRequestWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                           photoIndex:(NSInteger)photoIndex {
	//
  NSInteger identifier = [self identifierWithPhotoSize:photoSize photoIndex:photoIndex];
  id identifierKey = [self identifierKeyFromIdentifier:identifier];
  [_activeRequests removeObject:identifierKey];
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
	//
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
  
  UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
  if (nil == image) {
    NSDictionary* photo = [_photoInformation objectAtIndex:thumbnailIndex];
    
    NSString* thumbnailSource = [photo objectForKey:keyThumbnailSourceURL];
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
	//
  UIImage* image = nil;
	
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
  NSDictionary* photo = [_photoInformation objectAtIndex:photoIndex];
	
  // Let the photo album view know how large the photo will be once it's fully loaded.
  *originalPhotoDimensions = [[photo objectForKey:keyImageDimensions] CGSizeValue];
	
  image = [self.highQualityImageCache objectWithName:photoIndexKey];
  if (nil != image) {
    *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
		
  } else {
    NSString* source = [photo objectForKey:keyOriginalSourceURL];
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
      NSString* thumbnailSource = [photo objectForKey:keyThumbnailSourceURL];
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
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}



@end
