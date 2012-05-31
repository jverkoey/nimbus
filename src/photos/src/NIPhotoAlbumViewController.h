//
//  NIPhotoAlbumViewController.h
//
//  Created by Gregory Hill on 11/3/11.
//  Copyright (c) 2011 Hillside Apps, LLC. All rights reserved.
//

#import "NIPhotoAlbumScrollView.h"

#import "NIPhotoDataSource.h"


@interface NIPhotoAlbumViewController : UIViewController {
	NIPhotoDataSource		*_photoDataSource;
}


@property (nonatomic, retain) NIPhotoDataSource			*photoDataSource;

- (NSInteger) identifierWithPhotoSize: (NIPhotoScrollViewPhotoSize)photoSize
                           photoIndex: (NSInteger)photoIndex;

- (id) identifierKeyFromIdentifier:(NSInteger)identifier;

- (void) initPhotoAlbumViewWithFrame:(CGRect)photoAlbumFrame delegate:(id<NIPhotoAlbumScrollViewDelegate>)delegate;


- (void)didCancelRequestWithPhotoSize: (NIPhotoScrollViewPhotoSize)photoSize
                           photoIndex: (NSInteger)photoIndex;


/**
 * Load data source.  Must be overridden in subclass if data source is unique.
 */
- (void) loadDataSource;

/**
 * Path for initial image that is displayed during loading of other images.  Must be overridden in
 *	subclass if new loading image is desired.
 */
- (NSString *) loadingImagePath;


/**
 * Abstract method to be implemented by sub-classes.  Used to update UI if elements
 *	depending on data source need to be updated.
 */
- (void) dataSourceLoaded;


@end
