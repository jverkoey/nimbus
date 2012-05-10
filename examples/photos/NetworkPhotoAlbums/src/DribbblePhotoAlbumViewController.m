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

#import "DribbblePhotoAlbumViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation DribbblePhotoAlbumViewController

@synthesize apiPath = _apiPath;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_apiPath);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWith:(id)object {
  if ((self = [self initWithNibName:nil bundle:nil])) {
    self.apiPath = object;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadAlbumInformation {
  NSString* albumURLPath = [@"http://api.dribbble.com" stringByAppendingString:self.apiPath];

  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NSURL* url = [NSURL URLWithString:albumURLPath];
  NINetworkRequestOperation* albumRequest = [[[NINetworkJSONRequest alloc] initWithURL:url] autorelease];
  albumRequest.timeout = 30;

  // When the request fully completes we'll be notified via this delegate on the main thread.
  albumRequest.delegate = self;

  [self.photoDataSource.queue addOperation:albumRequest];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

//  self.photoDataSource.photoAlbumView.dataSource = self;
//  self.photoDataSource.photoScrubberView.dataSource = self;

  // Dribbble is for mockups and designs, so we don't want to allow the photos to be zoomed
  // in and become blurry.
  self.photoDataSource.photoAlbumView.zoomingAboveOriginalSizeIsEnabled = NO;

  // This title will be displayed until we get the results back for the album information.
  self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");

  [self loadAlbumInformation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationWillFinish:(NINetworkRequestOperation *)operation {
  // This is called from the processing thread in order to allow us to turn the root object
  // into something more interesting.
  if (![operation.processedObject isKindOfClass:[NSDictionary class]]) {
    return;
  }

  id object = operation.processedObject;
  NSArray* data = [object objectForKey:@"shots"];
  
  self.networkPhotoInformation = [NSMutableArray arrayWithCapacity:[data count]];
	
  for (NSDictionary* photo in data) {
    
    // Gather the high-quality photo information.
    NSString* originalImageSource = [photo objectForKey:@"image_url"];
    NSInteger width = [[photo objectForKey:@"width"] intValue];
    NSInteger height = [[photo objectForKey:@"height"] intValue];
    
    // We gather the highest-quality photo's dimensions so that we can size the thumbnails
    // correctly until the high-quality image is downloaded.
    CGSize dimensions = CGSizeMake(width, height);
    
    NSString* thumbnailImageSource = [photo objectForKey:@"image_teaser_url"];
									  
	[super addImageSourceURL: originalImageSource 
		  thumbnailSourceURL: thumbnailImageSource 
				  dimensions: dimensions];
									  
	operation.processedObject = self.networkPhotoInformation;
}


@end
