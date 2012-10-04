//
// Copyright 2012 Brett Spurrier
// Extended from DribblePhotoAlbumViewController (Copyright 2011 Jeff Verkoeyen)
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

#import "LocalPhotoAlbumViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation LocalPhotoAlbumViewController

@synthesize apiPath = _apiPath;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWith:(id)object {
  if ((self = [self initWithNibName:nil bundle:nil])) {
    self.apiPath = object;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadThumbnails {
  for (NSInteger ix = 0; ix < [_photoInformation count]; ++ix) {
    NSDictionary* photo = [_photoInformation objectAtIndex:ix];
    
    NSString* photoIndexKey = [self cacheKeyForPhotoIndex:ix];
    
    // Don't load the thumbnail if it's already in memory.
    if (![self.thumbnailImageCache containsObjectWithName:photoIndexKey]) {
      NSString* source = [photo objectForKey:@"thumbnailSource"];
      [self requestImageFromSource: source
                         photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                        photoIndex: ix];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) processAlbum:(NSMutableArray *)photos {
  
/*
  //NSMutableArray* photoInformation = [NSMutableArray arrayWithCapacity:[data count]];
  for (NSString* photoAssetsUrl in _photoInformation) {
    
    // Gather the high-quality photo information.
    NSString* originalImageSource = [photo objectForKey:@"image_url"];
    NSInteger width = [[photo objectForKey:@"width"] intValue];
    NSInteger height = [[photo objectForKey:@"height"] intValue];
    
    // We gather the highest-quality photo's dimensions so that we can size the thumbnails
    // correctly until the high-quality image is downloaded.
    CGSize dimensions = CGSizeMake(width, height);
    
    NSString* thumbnailImageSource = [photo objectForKey:@"image_teaser_url"];
    
    NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                     originalImageSource, @"originalSource",
                                     thumbnailImageSource, @"thumbnailSource",
                                     [NSValue valueWithCGSize:dimensions], @"dimensions",
                                     nil];
    [photoInformation addObject:prunedPhotoInfo];
  }
  
  _photoInformation = photoInformation;
  */
  
  //[self loadThumbnails];
  [self.photoAlbumView reloadData];
  //[self.photoScrubberView reloadData];
  
  [self refreshChromeState];




}



- (void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))blockForAlbumProcessing {
  return ^(NSURLRequest *request, NSHTTPURLResponse *response, id object) {
    NSArray* data = [object objectForKey:@"shots"];
    
    NSMutableArray* photoInformation = [NSMutableArray arrayWithCapacity:[data count]];
    for (NSDictionary* photo in data) {
      
      // Gather the high-quality photo information.
      NSString* originalImageSource = [photo objectForKey:@"image_url"];
      NSInteger width = [[photo objectForKey:@"width"] intValue];
      NSInteger height = [[photo objectForKey:@"height"] intValue];
      
      // We gather the highest-quality photo's dimensions so that we can size the thumbnails
      // correctly until the high-quality image is downloaded.
      CGSize dimensions = CGSizeMake(width, height);
      
      NSString* thumbnailImageSource = [photo objectForKey:@"image_teaser_url"];
      
      NSDictionary* prunedPhotoInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       originalImageSource, @"originalSource",
                                       thumbnailImageSource, @"thumbnailSource",
                                       [NSValue valueWithCGSize:dimensions], @"dimensions",
                                       nil];
      [photoInformation addObject:prunedPhotoInfo];
    }
    
    _photoInformation = photoInformation;
    
    [self loadThumbnails];
    [self.photoAlbumView reloadData];
    [self.photoScrubberView reloadData];
    
    [self refreshChromeState];
  };
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadAlbumInformation {
  
  // NOTE: Accessing the AssetsLibrary will require the user to grant Location Services access.
  
  ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
  [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    if (group == nil) {
      return;
    }
    NSMutableArray *localPhotos = [[NSMutableArray alloc] initWithCapacity:[group numberOfAssets]];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
      
      if(result) {
        NSURL *loc = [result valueForProperty:ALAssetPropertyURLs];
        [localPhotos addObject:loc];
      }
      if(index == [group numberOfAssets] - 1) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
          NSLog(@"Finished enumerating %d photos\n", [localPhotos count]);
          _photoInformation = localPhotos;
          [self.photoAlbumView reloadData];
          //[self blockForAlbumProcessing];
        });
        
      }
    }];
    
    
  } failureBlock:^(NSError *error)
   {
     
   }];
  

  
  /*
  NSString* albumURLPath = [@"http://api.dribbble.com" stringByAppendingString:self.apiPath];
  
  // Nimbus processors allow us to perform complex computations on a separate thread before
  // returning the object to the main thread. This is useful here because we perform sorting
  // operations and pruning on the results.
  NSURL* url = [NSURL URLWithString:albumURLPath];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  
  AFJSONRequestOperation* albumRequest =
  [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                  success:[self blockForAlbumProcessing]
                                                  failure:
   ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
     
   }];
  
  
  [self.queue addOperation:albumRequest];
   */
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];
  
  self.photoAlbumView.dataSource = self;
  self.photoScrubberView.dataSource = self;

  // This title will be displayed until we get the results back for the album information.
  self.title = NSLocalizedString(@"Loading...", @"Navigation bar title - Loading a photo album");
  
  [self loadAlbumInformation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _photoInformation = nil;
  
  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoScrubberViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPhotosInScrubberView:(NIPhotoScrubberView *)photoScrubberView {
  return [_photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoScrubberView: (NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex {
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:thumbnailIndex];
  
  UIImage* image = [self.thumbnailImageCache objectWithName:photoIndexKey];
  if (nil == image) {
    NSDictionary* photo = [_photoInformation objectAtIndex:thumbnailIndex];
    
    NSString* thumbnailSource = [photo objectForKey:@"thumbnailSource"];
    [self requestImageFromSource: thumbnailSource
                       photoSize: NIPhotoScrollViewPhotoSizeThumbnail
                      photoIndex: thumbnailIndex];
  }
  
  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfPagesInPagingScrollView:(NIPhotoAlbumScrollView *)photoScrollView {
  return [_photoInformation count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                     photoAtIndex: (NSInteger)photoIndex
                        photoSize: (NIPhotoScrollViewPhotoSize *)photoSize
                        isLoading: (BOOL *)isLoading
          originalPhotoDimensions: (CGSize *)originalPhotoDimensions {
  UIImage* image = nil;
  
  NSString* photoIndexKey = [self cacheKeyForPhotoIndex:photoIndex];
  
  image = [self.highQualityImageCache objectWithName:photoIndexKey];
  if (nil != image) {
    *photoSize = NIPhotoScrollViewPhotoSizeOriginal;
    
  } else {
    NSDictionary* sourceDictionary = [_photoInformation objectAtIndex:photoIndex];
    
    NSString* assetsUrl = nil;
    if([sourceDictionary objectForKey:@"public.jpeg"]) {
      assetsUrl = [sourceDictionary objectForKey:@"public.jpeg"];
    }
    else if([sourceDictionary objectForKey:@"public.png"]) {
      assetsUrl = [sourceDictionary objectForKey:@"public.png"];
    }

    [self requestImageFromAssetsLibrary: assetsUrl
                              photoSize: NIPhotoScrollViewPhotoSizeOriginal
                             photoIndex: photoIndex];
    
    *isLoading = YES;
    
  }
  
  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
     stopLoadingPhotoAtIndex: (NSInteger)photoIndex {
  // TODO: Figure out how to implement this with AFNetworking.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<NIPagingScrollViewPage>)pagingScrollView:(NIPagingScrollView *)pagingScrollView pageViewForIndex:(NSInteger)pageIndex {
  return [self.photoAlbumView pagingScrollView:pagingScrollView pageViewForIndex:pageIndex];
}


@end
