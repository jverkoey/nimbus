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

#import "NetworkPhotoAlbumViewController.h"

/**
 * Shows a Dribbble shot list.
 *
 *      Minimum iOS SDK Version: 4.0
 *      SDK Requirements: Blocks (4.0)
 */
@interface DribbblePhotoAlbumViewController : NetworkPhotoAlbumViewController <
  NIPhotoAlbumScrollViewDataSource,
  NIPhotoScrubberViewDataSource,
  NIOperationDelegate
> {
@private
  NSString* _apiPath;

  NSArray* _photoInformation;
}

/**
 * The generic entry point used by the catalog view controller to initialize this controller.
 *
 * Expects a value to be appended to http://api.dribbble.com that will return a list of shots.
 */
- (id)initWith:(id)object;

@property (nonatomic, readwrite, copy) NSString* apiPath;


@end
