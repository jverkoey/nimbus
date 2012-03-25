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



@end
