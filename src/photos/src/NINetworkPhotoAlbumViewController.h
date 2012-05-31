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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIToolbarPhotoViewController.h"
#import "NINetworkPhotoDataSource.h"


/**
 * A network-based photo album view controller.
 *
 *      Minimum iOS SDK Version: 4.0
 *      SDK Requirements: Blocks (4.0)
 *
 * This controller provides the necessary image caches and queue for loading images from
 * the network.
 *
 * <h2>Caching Architectural Design Considerations</h2>
 *
 * This controller maintains two image caches, one for high quality images and one for
 * thumbnails. The thumbnail cache is unbounded and the high quality cache has a limit of about
 * 3 1024x1024 images.
 *
 * The primary benefit of containing the image caches in this controller instead of using the
 * global image cache is that when this controller is no longer being used, all of its memory
 * is relinquished. If this controller were to use the global image cache it's also likely that
 * we might push out other application-wide images unnecessarily. In a production environment
 * we would depend on the network disk cache to load the photos back into memory when we return
 * to this controller.
 *
 * By default the thumbnail cache has no limit to its size, though it may be advantageous to
 * cap the cache at something reasonable.
 */
@interface NINetworkPhotoAlbumViewController : NIToolbarPhotoViewController <NIOperationDelegate> {
@protected
	NSMutableArray			*_networkPhotoInformation;
	
@private
}

@property (nonatomic, retain) NSMutableArray			*networkPhotoInformation;


/**
 * Helper methods to load photo information.  Subclasses need to load the individual photos into
 *	a dictionary.  These methods standardize the process.
 */
- (void) addImageSourceURL:(NSString *)originalSourceURL thumbnailSourceURL:(NSString *)thumbnailSourceURL dimensions:(CGSize)dimensions;

- (void) addImageSourceURL:(NSString *)originalSourceURL thumbnailSourceURL:(NSString *)thumbnailSourceURL dimensions:(CGSize)dimensions caption:(NSString *)caption;


@end
