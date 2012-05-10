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

#import "NINetworkPhotoAlbumViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINetworkPhotoAlbumViewController

@synthesize networkPhotoInformation			= _networkPhotoInformation;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown_NetworkPhotoAlbumViewController {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];
}

- (void) loadDataSource {
	_photoDataSource = [[NINetworkPhotoDataSource alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [self shutdown_NetworkPhotoAlbumViewController];

  [super viewDidUnload];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) nimbusOperationWillFinish:(NINetworkRequestOperation *)operation {
	NSException *ex = [NSException exceptionWithName:@"invalid method implementation" reason:@"operationWillFinish: must be implemented in a subclass of NINetworkPhotoAlbumViewController" userInfo:nil];
	
	[ex raise];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFinish:(NINetworkRequestOperation *)operation {
  self.photoDataSource.photoInformation = operation.processedObject;
	
  [self.photoDataSource reload];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
//- (void)nimbusOperationDidFinish:(NINetworkRequestOperation *)operation {
//  _photoInformation = [operation.processedObject retain];
//
//  [self.photoAlbumView reloadData];
//
//  [self loadThumbnails];
//  
//  [self.photoScrubberView reloadData];
//}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addImageSourceURL: (NSString *)originalSourceURL 
		thumbnailSourceURL: (NSString *)thumbnailSourceURL 
				dimensions: (CGSize)dimensions {
	//
	NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
																	 originalSourceURL, keyOriginalSourceURL,
																	 thumbnailSourceURL, keyThumbnailSourceURL,
																	 [NSValue valueWithCGSize:dimensions], keyImageDimensions,
																	 nil];

	//DebugLog(@"\nNetwork photoInfo: %@", prunedPhotoInfo);

	[_networkPhotoInformation addObject:prunedPhotoInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addImageSourceURL: (NSString *)originalSourceURL 
		thumbnailSourceURL: (NSString *)thumbnailSourceURL 
				dimensions: (CGSize)dimensions 
				   caption: (NSString *)caption {
	//
		NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
																		 originalSourceURL, keyOriginalSourceURL,
																		 thumbnailSourceURL, keyThumbnailSourceURL,
																		 [NSValue valueWithCGSize:dimensions], keyImageDimensions,
																		 caption, keyImageCaption,
																		 nil];
		
		[_networkPhotoInformation addObject:prunedPhotoInfo];	
}


@end
