//
//  NIPhotoScrubberViewDataSource.h
//  Nimbus
//
//  Created by Gregory Hill on 3/14/12.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIPhotoScrubberView;

/**
 * The data source for the photo scrubber.
 *
 *      @ingroup Photos-Protocols
 *
 * <h2>Performance Considerations</h2>
 *
 * A scrubber view's purpose is for instantly flipping through an album of photos. As such,
 * it's crucial that your implementation of the data source performs blazingly fast. When
 * the scrubber requests a thumbnail from you you should *not* be hitting the disk or blocking
 * on a network call. If you don't have the thumbnail available at that exact moment, fire
 * off an asynchronous load request (using NIReadFileFromDiskOperation or NIHTTPRequest)
 * and return nil. Once the thumbnail is loaded, call didLoadThumbnail:atIndex: to notify
 * the scrubber that it can display the thumbnail now.
 *
 * It is not recommended to use high-res images for your scrubber thumbnails. This is because
 * the scrubber will keep a large set of images in memory and if you're giving it
 * high-resolution images then you'll find that your app quickly burns through memory.
 * If you don't have access to thumbnails from whatever API you're using then you should consider
 * not using a scrubber.
 *
 *      @see NIPhotoScrubberView
 */
@protocol NIPhotoScrubberViewDataSource <NSObject>

@required

#pragma mark Fetching Required Information /** @name Fetching Required Information */

/**
 * Fetches the total number of photos in the scroll view.
 *
 * The value returned in this method will be cached by the scroll view until reloadData
 * is called again.
 */
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView;

/**
 * Fetch the thumbnail image for the given photo index.
 *
 * Please read and understand the performance considerations for this data source.
 */
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex;

@end

