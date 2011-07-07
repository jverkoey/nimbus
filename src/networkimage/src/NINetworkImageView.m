//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 15, 2011 - Copyright 2009-2011 Facebook
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

#import "NINetworkImageView.h"

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusCore/NimbusCore.h"
#import "ASIHTTPRequest/ASIHTTPRequest.h"
#import "ASIHTTPRequest/ASIDownloadCache.h"
#else
#import "NimbusCore.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#endif

#import "NIHTTPImageRequest.h"



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NINetworkImageView()

@property (nonatomic, readwrite, retain) NIHTTPImageRequest* request;

@property (nonatomic, readwrite, copy) NSString* lastPathToNetworkImage;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINetworkImageView

@synthesize request                 = _request;
@synthesize sizeForDisplay          = _sizeForDisplay;
@synthesize scaleOptions            = _scaleOptions;
@synthesize imageMemoryCache        = _imageMemoryCache;
@synthesize imageDiskCache          = _imageDiskCache;
@synthesize networkOperationQueue   = _networkOperationQueue;
@synthesize maxAge                  = _maxAge;
@synthesize diskCacheLifetime       = _diskCacheLifetime;
@synthesize initialImage            = _initialImage;
@synthesize memoryCachePrefix       = _memoryCachePrefix;
@synthesize lastPathToNetworkImage  = _lastPathToNetworkImage;
@synthesize delegate                = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self.request clearDelegatesAndCancel];
  self.request = nil;

  NI_RELEASE_SAFELY(_initialImage);

  NI_RELEASE_SAFELY(_imageMemoryCache);
  NI_RELEASE_SAFELY(_imageDiskCache);
  NI_RELEASE_SAFELY(_networkOperationQueue);

  NI_RELEASE_SAFELY(_memoryCachePrefix);

  NI_RELEASE_SAFELY(_lastPathToNetworkImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithImage:(UIImage *)image {
  if ((self = [super initWithImage:image])) {
    // Assign defaults.
    self.sizeForDisplay = YES;
    self.scaleOptions = NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess;

    self.diskCacheLifetime = NINetworkImageViewDiskCacheLifetimePermanent;

    self.imageMemoryCache = [Nimbus globalImageMemoryCache];
    self.networkOperationQueue = [Nimbus globalNetworkOperationQueue];
    self.imageDiskCache = [ASIDownloadCache sharedCache];

    // Retain the initial image.
    self.initialImage = image;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [self initWithImage:nil])) {
    self.frame = frame;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithImage:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForURL: (NSURL *)URL
                   imageSize: (CGSize)imageSize
                 contentMode: (UIViewContentMode)contentMode
                scaleOptions: (NINetworkImageViewScaleOptions)scaleOptions {
  NSString* cacheKey = [URL absoluteString];

  // Prefix cache key to create a namespace.
  if (nil != self.memoryCachePrefix) {
    cacheKey = [self.memoryCachePrefix stringByAppendingString:cacheKey];
  }

  // Append the size to the key. This allows us to differentiate cache keys by image dimension.
  // If the display size ever changes, we want to ensure that we're fetching the correct image
  // from the cache.
  if (self.sizeForDisplay) {
    cacheKey = [cacheKey stringByAppendingFormat:@"%@{%d,%d}",
                NSStringFromCGSize(imageSize), contentMode, scaleOptions];
  }

  // The resulting cache key will look like:
  // (memoryCachePrefix)/path/to/image({width,height}{contentMode,cropImageForDisplay})

  return cacheKey;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ASIHTTPRequest Delegation


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestStarted:(NIHTTPImageRequest *)request {
  [self networkImageViewDidStartLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinish:(NIHTTPImageRequest *)request {
  // Store the resulting image in the memory cache.
  if (nil != self.imageMemoryCache) {
    NSString* cacheKey = [self cacheKeyForURL: request.url
                                    imageSize: request.imageDisplaySize
                                  contentMode: request.imageContentMode
                                 scaleOptions: request.scaleOptions];

    // Get the expiration date from the response headers for the request.
    NSDate* expirationDate = [ASIHTTPRequest expiryDateForRequest:request maxAge:self.maxAge];

    // Store the image in the memory cache, possibly with an expiration date. The expiration
    // date will allow the image to be released from memory if it expires whenever we receive
    // a memory warning.
    [self.imageMemoryCache storeObject: request.imageCroppedAndSizedForDisplay
                              withName: cacheKey
                          expiresAfter: expirationDate];
  }

  // Display the new image.
  [self setImage:request.imageCroppedAndSizedForDisplay];

  self.request = nil;

  if ([self.delegate respondsToSelector:@selector(networkImageView:didLoadImage:)]) {
    [self.delegate networkImageView:self didLoadImage:self.image];
  }

  [self networkImageViewDidLoadImage:request.imageCroppedAndSizedForDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFail:(NIHTTPImageRequest *)request {
  self.request = nil;

  [self networkImageViewDidFailToLoad:request.error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (ASICacheStoragePolicy)cacheStoragePolicy {
  switch (self.diskCacheLifetime) {
    case NINetworkImageViewDiskCacheLifetimeSession: {
      return ASICacheForSessionDurationCacheStoragePolicy;
    }
    default:
    case NINetworkImageViewDiskCacheLifetimePermanent: {
      return ASICachePermanentlyCacheStoragePolicy;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Subclassing


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)networkImageViewDidStartLoading {
  // No-op. Meant to be overridden.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)networkImageViewDidLoadImage:(UIImage *)image {
  // No-op. Meant to be overridden.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)networkImageViewDidFailToLoad:(NSError *)error {
  // No-op. Meant to be overridden.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage {
  [self setPathToNetworkImage: pathToNetworkImage
                     cropRect: CGRectZero
               forDisplaySize: CGSizeZero
                  contentMode: self.contentMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
               forDisplaySize: (CGSize)displaySize {
  [self setPathToNetworkImage: pathToNetworkImage
                     cropRect: CGRectZero
               forDisplaySize: displaySize
                  contentMode: self.contentMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
               forDisplaySize: (CGSize)displaySize
                  contentMode: (UIViewContentMode)contentMode {
  [self setPathToNetworkImage: pathToNetworkImage
                     cropRect: CGRectZero
               forDisplaySize: displaySize
                  contentMode: contentMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
                     cropRect: (CGRect)cropRect {
  [self setPathToNetworkImage: pathToNetworkImage
                     cropRect: cropRect
               forDisplaySize: CGSizeZero
                  contentMode: self.contentMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
                  contentMode: (UIViewContentMode)contentMode {
  [self setPathToNetworkImage: pathToNetworkImage
                     cropRect: CGRectZero
               forDisplaySize: CGSizeZero
                  contentMode: contentMode];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage: (NSString *)pathToNetworkImage
                     cropRect: (CGRect)cropRect
               forDisplaySize: (CGSize)displaySize
                  contentMode: (UIViewContentMode)contentMode {
  [self.request clearDelegatesAndCancel];

  if (NIIsStringWithAnyText(pathToNetworkImage)) {
    self.lastPathToNetworkImage = pathToNetworkImage;

    // We explicitly do not allow negative display sizes. Check the call stack to figure
    // out who is providing a negative display size. It's possible that displaySize is an
    // uninitialized CGSize structure.
    NIDASSERT(displaySize.width >= 0);
    NIDASSERT(displaySize.height >= 0);

    // If an invalid display size is provided, use the image view's frame instead.
    if (0 >= displaySize.width || 0 >= displaySize.height) {
      displaySize = self.frame.size;
    }

    NSURL* url = [NSURL URLWithString:pathToNetworkImage];

    /*
    // TODO: Implement loading directly from disk.
    //handle file:// urls because TTHTTPImageRequest does not handle them.
    if ([url isFileURL]) {
      UIImage* image = [UIImage imageWithContentsOfFile:[url path]];
      if (image) {
        [self setImage:image];

        if ([self.delegate respondsToSelector:@selector(networkImageView:didLoadImage:)]) {
          [self.delegate networkImageView:self didLoadImage:self.image];
        }
        isCached = YES;
        return;
      }
    }*/

    UIImage* image = nil;

    // Attempt to load the image from memory first.
    if (nil != self.imageMemoryCache) {
      NSString* cacheKey = [self cacheKeyForURL: url
                                      imageSize: displaySize
                                    contentMode: contentMode
                                   scaleOptions: self.scaleOptions];
      image = [self.imageMemoryCache objectWithName:cacheKey];
    }

    if (nil != image) {
      // We successfully loaded the image from memory.
      [self setImage:image];

      if ([self.delegate respondsToSelector:@selector(networkImageView:didLoadImage:)]) {
        [self.delegate networkImageView:self didLoadImage:self.image];
      }

    } else {
      // Unable to load the image from memory, fire off the load request (which will load
      // the image from the disk if possible and fall back to loading from the network).
      NIHTTPImageRequest* request =
      [NIHTTPImageRequest requestWithURL: url
                              usingCache: self.imageDiskCache];

      [request setDelegate:self];
      [request setDidFinishSelector:@selector(requestDidFinish:)];
      [request setDidFailSelector:@selector(requestDidFail:)];

      [request setCacheStoragePolicy:self.cacheStoragePolicy];

      [request setImageCropRect:cropRect];
      [request setScaleOptions:self.scaleOptions];
      if (self.sizeForDisplay) {
        [request setImageDisplaySize:displaySize];
        [request setImageContentMode:contentMode];
      }

      self.request = request;

      [self.networkOperationQueue addOperation:request];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [self.request clearDelegatesAndCancel];

  [self setImage:self.initialImage];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setInitialImage:(UIImage *)initialImage {
  if (_initialImage != initialImage) {
    BOOL updateViewImage = (_initialImage == self.image);
    [_initialImage release];
    _initialImage = [initialImage retain];

    if (updateViewImage) {
      [self setImage:_initialImage];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return nil != _request;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNetworkOperationQueue:(NSOperationQueue *)queue {
  // Don't allow a nil network operation queue.
  NIDASSERT(nil != queue);
  if (nil == queue) {
    queue = [Nimbus globalNetworkOperationQueue];
  }
  if (queue != _networkOperationQueue) {
    [_networkOperationQueue release];
    _networkOperationQueue = [queue retain];
  }
}


@end

