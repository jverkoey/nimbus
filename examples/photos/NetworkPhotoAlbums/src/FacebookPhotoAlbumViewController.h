//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "NetworkPhotoAlbumViewController.h"

/**
 * Shows a Facebook photo album accessed through the Graph API.
 *
 *      Minimum iOS SDK Version: 4.0
 *      SDK Requirements: Blocks (4.0)
 */
@interface FacebookPhotoAlbumViewController : NetworkPhotoAlbumViewController <
  NIPhotoAlbumScrollViewDataSource,
  NIPhotoScrubberViewDataSource,
  NIOperationDelegate
> {
@private
  NSString* _facebookAlbumId;

  NSArray* _photoInformation;
}

/**
 * The generic entry point used by the catalog view controller to initialize this controller.
 *
 * Expects a photo album id.
 *
 *      @see facebookAlbumId
 */
- (id)initWith:(id)object;

/**
 * The album id of the Facebook album to load.
 *
 * You can preview what the Graph API will generate by fetching the following url:
 *
 * http://graph.facebook.com/<facebookAlbumId>/photos
 *
 * Album IDs to play with from the Stanford page at https://www.facebook.com/stanford
 *
 * - 10150219083838418 120th Commencement in Pictures
 * - 10150185938728418 Stanford 40th Annual Powwow
 * - 10150160584103418 Spring blossoms at Stanford
 */
@property (nonatomic, copy) NSString* facebookAlbumId;

@end
