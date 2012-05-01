//
//  NIToolbarDataSource.m
//  Nimbus
//
//  Created by Gregory Hill on 3/21/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIToolbarDataSource.h"

@implementation NIToolbarDataSource

@synthesize photoScrubberView;


- (void) setPhotoScrubberView:(NIPhotoScrubberView *)_photoScrubberView {
	if(!photoScrubberView) {
		photoScrubberView = nil;
		
		NI_RELEASE_SAFELY(photoScrubberView);
	}
	
	photoScrubberView = _photoScrubberView;
	
	photoScrubberView.dataSource = self;
}

- (void) reload {
	[super reload];
	
    [self.photoScrubberView reloadData];
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
	//
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
- (void) cacheImageWithData: (NSData *)imageData 
				isThumbnail: (BOOL)isThumbnail 
				 photoIndex: (NSInteger)photoIndex 
				  photoSize: (NIPhotoScrollViewPhotoSize)photoSize {
	//
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
	
	UIImage* image = [UIImage imageWithData:imageData];
	
	// Store the image in the correct image cache.
	if (isThumbnail) {
//		DebugLog(@"caching thumbnail");
		[_thumbnailImageCache storeObject: image
								 withName: photoIndexKey];
		
	} else {
//		DebugLog(@"caching fullsize");
		[_highQualityImageCache storeObject: image
								   withName: photoIndexKey];
	}
	
	// If you decide to move this code around then ensure that this method is called from
	// the main thread. Calling it from any other thread will have undefined results.
	[self.photoAlbumView didLoadPhoto: image
							  atIndex: photoIndex
							photoSize: photoSize];
	
	if (isThumbnail) {
		[self.photoScrubberView didLoadThumbnail: image 
										 atIndex: photoIndex];
	}
}


- (void) cacheImageWithDictionary:(NSDictionary *)dictionary {
	NSData *imageData = [dictionary valueForKey:@"imageData"];
	BOOL isThumbnail = [[dictionary valueForKey:@"isThumbnail"] boolValue];
	NSInteger photoIndex = [[dictionary valueForKey:@"photoIndex"] intValue];
	NIPhotoScrollViewPhotoSize photoSize = (NIPhotoScrollViewPhotoSize)[[dictionary valueForKey:@"photoSize"] intValue];
	
	[self cacheImageWithData: imageData
				 isThumbnail: isThumbnail
				  photoIndex: photoIndex
				   photoSize: photoSize];
}

@end
