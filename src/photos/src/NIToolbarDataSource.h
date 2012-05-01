//
//  NIToolbarDataSource.h
//  Nimbus
//
//  Created by Gregory Hill on 3/21/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIPhotoDataSource.h"
#import "NIPhotoScrubberViewDataSource.h"

@interface NIToolbarDataSource : NIPhotoDataSource <NIPhotoScrubberViewDataSource>

@property (nonatomic, unsafe_unretained) NIPhotoScrubberView* photoScrubberView;

- (void) cacheImageWithData: (NSData *)data 
				isThumbnail: (BOOL)isThumbnail 
				 photoIndex: (NSInteger)photoIndex 
				  photoSize: (NIPhotoScrollViewPhotoSize)photoSize;


- (void) cacheImageWithDictionary:(NSDictionary *)dictionary;

@end
