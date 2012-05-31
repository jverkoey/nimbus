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


/**
 * Right now, init, shutdown, and dealloc are placeholders.  The work that needs 
 *	to be done is either in the superclass, NIPhotoDataSource, or in a subclass.
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
	self = [super init];
	
    if (self) {
    }

    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown {
	[super shutdown];
}

- (void) shutdown_Queue {
	for (NINetworkRequestOperation* request in _queue.operations) {
        request.delegate = nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [super dealloc];
}


/**
 * We are overriding the declared method in NIPhotoDataSource.  The work being done here
 *	is network-specific.  It is being called by whichever subclass is defining the specific
 *	network source of the data ((NSString *)source in the method call).  Most likely,
 *	this method will *not* need to be overridden by any subclasses that are relying
 *	on a network-based data source.
 */
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

	//DebugLog(@"Network source: %@", source);
    NSURL* url = [self urlFromSource:source];

    NINetworkRequestOperation* readOp = [[[NINetworkRequestOperation alloc] initWithURL:url] autorelease];
    readOp.timeout = 30;

    // Set an negative index for thumbnail requests so that they don't get cancelled by
    // photoAlbumScrollView:stopLoadingPhotoAtIndex:
    readOp.tag = isThumbnail ? -(photoIndex + 1) : photoIndex;

    // The completion block will be executed on the main thread, so we must be careful not
    // to do anything computationally expensive here.
    [readOp setDidFinishBlock:^(NIOperation *operation) {
		NSData *imageData = ((NINetworkRequestOperation *) operation).data;
		
		NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
									imageData, @"imageData",
									[NSNumber numberWithBool:isThumbnail], @"isThumbnail",
									[NSNumber numberWithInt:photoIndex], @"photoIndex",
									[NSNumber numberWithInt:photoSize], @"photoSize",
									nil];
		
		[super performSelectorOnMainThread: @selector(cacheImageWithDictionary:) 
								withObject: dictionary
							 waitUntilDone: YES];
		
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


- (NSURL *) urlFromSource:(NSString *)source {
	NSURL* url = [NSURL URLWithString:source];

	return url;
}



@end
