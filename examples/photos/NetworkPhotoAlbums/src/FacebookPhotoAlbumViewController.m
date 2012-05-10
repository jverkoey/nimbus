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

#import "FacebookPhotoAlbumViewController.h"

#import "CaptionedPhotoView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation FacebookPhotoAlbumViewController

@synthesize facebookAlbumId = _facebookAlbumId;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_facebookAlbumId);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWith:(id)object {
  if ((self = [self initWithNibName:nil bundle:nil])) {
    self.facebookAlbumId = object;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadAlbumInformation {
  NSString* albumURLPath = [NSString stringWithFormat:
                            @"http://graph.facebook.com/%@/photos?limit=200",
                            self.facebookAlbumId];

  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NSURL* url = [NSURL URLWithString:albumURLPath];
  NINetworkJSONRequest* albumRequest = [[[NINetworkJSONRequest alloc] initWithURL:url] autorelease];

  // Facebook albums are painfully slow to load if they have a lot of comments. Even more
  // frustrating is that you can't ask *not* to receive the comments from the graph API.
  albumRequest.timeout = 200;

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
//
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
	NSArray* data = [object objectForKey:@"data"];

	self.networkPhotoInformation = [NSMutableArray arrayWithCapacity:[data count]];

	for (NSDictionary* photo in data) {
		NSArray* images = [photo objectForKey:@"images"];

		if ([images count] > 0) {
			// Sort the images in descending order by image size.
			NSArray* sortedImages =
				[images sortedArrayUsingDescriptors:
					[NSArray arrayWithObject:
						[[[NSSortDescriptor alloc] initWithKey:@"width" ascending:NO] autorelease]]];

			// Gather the high-quality photo information.
			NSDictionary* originalImage = [sortedImages objectAtIndex:0];
			NSString* originalImageSource = [originalImage objectForKey:@"source"];
			NSInteger width = [[originalImage objectForKey:@"width"] intValue];
			NSInteger height = [[originalImage objectForKey:@"height"] intValue];

			// We gather the highest-quality photo's dimensions so that we can size the thumbnails
			// correctly until the high-quality image is downloaded.
			CGSize dimensions = CGSizeMake(width, height);

			NSInteger numberOfImages = [sortedImages count];

			// 0 being the lowest quality. On larger screens we fetch larger thumbnails.
			NSInteger qualityLevel = (NIIsPad() || NIScreenScale() > 1) ? 1 : 0;

			NSInteger thumbnailIndex = ((numberOfImages - 1)
										- MIN(qualityLevel, numberOfImages - 2));

			NSString* thumbnailImageSource = nil;
			if (0 < thumbnailIndex) {
				thumbnailImageSource = [[sortedImages objectAtIndex:thumbnailIndex] objectForKey:@"source"];
			}

			NSString* caption = [photo objectForKey:@"name"];

			[super addImageSourceURL: originalImageSource 
				  thumbnailSourceURL: thumbnailImageSource 
						  dimensions: dimensions 
							 caption: caption];
		}
	}
	
  operation.processedObject = self.networkPhotoInformation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView<NIPagingScrollViewPage> *) pagingScrollView: (NIPagingScrollView *)pagingScrollView 
									 pageViewForIndex: (NSInteger)pageIndex {
	//
  // TODO (jverkoey Nov 27, 2011): We should make this sort of custom logic easier to build.
  UIView<NIPagingScrollViewPage>* pageView = nil;
  NSString* reuseIdentifier = NSStringFromClass([CaptionedPhotoView class]);
  pageView = [pagingScrollView dequeueReusablePageWithIdentifier:reuseIdentifier];
  if (nil == pageView) {
    pageView = [[[CaptionedPhotoView alloc] init] autorelease];
    pageView.reuseIdentifier = reuseIdentifier;
  }

  NIPhotoScrollView* photoScrollView = (NIPhotoScrollView *)pageView;
  photoScrollView.photoScrollViewDelegate = self.photoDataSource.photoAlbumView;
  photoScrollView.zoomingAboveOriginalSizeIsEnabled = [self.photoDataSource.photoAlbumView isZoomingAboveOriginalSizeEnabled];

  CaptionedPhotoView* captionedView = (CaptionedPhotoView *)pageView;
  captionedView.caption = [[self.photoDataSource.photoInformation objectAtIndex:pageIndex] objectForKey:keyImageCaption];
  
  return pageView;
}


@end
