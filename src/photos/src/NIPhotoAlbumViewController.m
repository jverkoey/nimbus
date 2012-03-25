//
//  NIPhotoAlbumViewController.m
//
//  Created by Gregory Hill on 11/3/11.
//  Copyright (c) 2011 Hillside Apps, LLC. All rights reserved.
//

#import "NIPhotoAlbumViewController.h"

@implementation NIPhotoAlbumViewController

@synthesize photoDataSource			= _photoDataSource;


- (void) dealloc {
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadView {
	[super loadView];
	
	[self loadDataSource];
}

- (void) loadDataSource {
	_photoDataSource = [[NIPhotoDataSource alloc] init];
}


- (NSString *) loadingImagePath {
	return NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png");
}


- (void) viewDidUnload {
	[super viewDidUnload];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)identifierWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                          photoIndex:(NSInteger)photoIndex {
	//
  BOOL isThumbnail = (NIPhotoScrollViewPhotoSizeThumbnail == photoSize);
  NSInteger identifier = isThumbnail ? -(photoIndex + 1) : photoIndex;
	
  return identifier;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)identifierKeyFromIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInt:identifier];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) initPhotoAlbumViewWithFrame:(CGRect)photoAlbumFrame 
							delegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate {
	//
	NIPhotoAlbumScrollView *_photoAlbumView = [[[NIPhotoAlbumScrollView alloc] initWithFrame:photoAlbumFrame] autorelease];
	
	_photoAlbumView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
										| UIViewAutoresizingFlexibleHeight);
	
	_photoAlbumView.delegate = delegate;

	self.photoDataSource.photoAlbumView = _photoAlbumView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
	//
	[self.photoDataSource.photoAlbumView willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
																		  duration: duration];
	
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
											duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didCancelRequestWithPhotoSize:(NIPhotoScrollViewPhotoSize)photoSize
                           photoIndex:(NSInteger)photoIndex {
	//
  NSInteger identifier = [self identifierWithPhotoSize:photoSize photoIndex:photoIndex];
  id identifierKey = [self identifierKeyFromIdentifier:identifier];
	
  [self.photoDataSource cancelRequestWithIdentifier:identifierKey];
}


@end
