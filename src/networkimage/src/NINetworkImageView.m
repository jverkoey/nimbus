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

#import "NimbusCore.h"

#import "NINetworkImageRequest.h"



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NINetworkImageView()

@property (nonatomic, readwrite, retain) NSOperation* operation;

@property (nonatomic, readwrite, copy) NSString* lastPathToNetworkImage;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINetworkImageView

@synthesize operation               = _operation;
@synthesize sizeForDisplay          = _sizeForDisplay;
@synthesize scaleOptions            = _scaleOptions;
@synthesize interpolationQuality    = _interpolationQuality;
@synthesize imageMemoryCache        = _imageMemoryCache;
@synthesize networkOperationQueue   = _networkOperationQueue;
@synthesize maxAge                  = _maxAge;
@synthesize initialImage            = _initialImage;
@synthesize memoryCachePrefix       = _memoryCachePrefix;
@synthesize lastPathToNetworkImage  = _lastPathToNetworkImage;
@synthesize delegate                = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelOperation {
  if ([self.operation isKindOfClass:[NIOperation class]]) {
    NIOperation* request = (NIOperation *)self.operation;
    // Clear the delegate so that we don't receive a didFail notification when we cancel the
    // operation.
    request.delegate = nil;
  }
  [self.operation cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self cancelOperation];

  NI_RELEASE_SAFELY(_operation);

  NI_RELEASE_SAFELY(_initialImage);

  NI_RELEASE_SAFELY(_imageMemoryCache);
  NI_RELEASE_SAFELY(_networkOperationQueue);

  NI_RELEASE_SAFELY(_memoryCachePrefix);

  NI_RELEASE_SAFELY(_lastPathToNetworkImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)assignDefaults {
  self.sizeForDisplay = YES;
  self.scaleOptions = NINetworkImageViewScaleToFitLeavesExcessAndScaleToFillCropsExcess;
  self.interpolationQuality = kCGInterpolationDefault;

  self.imageMemoryCache = [Nimbus imageMemoryCache];
  self.networkOperationQueue = [Nimbus networkOperationQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithImage:(UIImage *)image {
  if ((self = [super initWithImage:image])) {
    [self assignDefaults];

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
- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    if (nil != self.image) {
      self.initialImage = self.image;
    }
    [self assignDefaults];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithImage:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cacheKeyForCacheIdentifier:(NSString *)cacheIdentifier
                               imageSize:(CGSize)imageSize
                             contentMode:(UIViewContentMode)contentMode
                            scaleOptions:(NINetworkImageViewScaleOptions)scaleOptions {
  NIDASSERT(NIIsStringWithAnyText(cacheIdentifier));

  NSString* cacheKey = cacheIdentifier;

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
#pragma mark Internal consistent implementation of state changes


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_didStartLoading {
  if ([self.delegate respondsToSelector:@selector(networkImageViewDidStartLoad:)]) {
    [self.delegate networkImageViewDidStartLoad:self];
  }

  [self networkImageViewDidStartLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_didFinishLoadingWithImage: (UIImage *)image
                   cacheIdentifier: (NSString *)cacheIdentifier
                       displaySize: (CGSize)displaySize
                       contentMode: (UIViewContentMode)contentMode
                      scaleOptions: (NINetworkImageViewScaleOptions)scaleOptions
                    expirationDate: (NSDate *)expirationDate {
  // Store the result image in the memory cache.
  if (nil != self.imageMemoryCache) {
    NSString* cacheKey = [self cacheKeyForCacheIdentifier:cacheIdentifier
                                                imageSize:displaySize
                                              contentMode:contentMode
                                             scaleOptions:scaleOptions];

    // Store the image in the memory cache, possibly with an expiration date.
    [self.imageMemoryCache storeObject: image
                              withName: cacheKey
                          expiresAfter: expirationDate];
  }

  // Display the new image.
  [self setImage:image];

  self.operation = nil;

  if ([self.delegate respondsToSelector:@selector(networkImageView:didLoadImage:)]) {
    [self.delegate networkImageView:self didLoadImage:self.image];
  }

  [self networkImageViewDidLoadImage:image];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_didFailToLoadWithError:(NSError *)error {
  self.operation = nil;

  if ([self.delegate respondsToSelector:@selector(networkImageView:didFailWithError:)]) {
    [self.delegate networkImageView:self didFailWithError:error];
  }

  [self networkImageViewDidFailWithError:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidStart:(NIOperation *)operation {
  [self _didStartLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFinish:(NINetworkImageRequest *)operation {
  [self _didFinishLoadingWithImage:operation.imageCroppedAndSizedForDisplay
                   cacheIdentifier:operation.cacheIdentifier
                       displaySize:operation.imageDisplaySize
                       contentMode:operation.imageContentMode
                      scaleOptions:operation.scaleOptions
                    expirationDate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFail:(NIOperation *)operation withError:(NSError *)error {
  [self _didFailToLoadWithError:error];
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
- (void)networkImageViewDidFailWithError:(NSError *)error {
  // No-op. Meant to be overridden.
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage {
  [self setPathToNetworkImage: pathToNetworkImage
               forDisplaySize: CGSizeZero
                  contentMode: self.contentMode
                     cropRect: CGRectZero];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize {
  [self setPathToNetworkImage: pathToNetworkImage
               forDisplaySize: displaySize
                  contentMode: self.contentMode
                     cropRect: CGRectZero];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode {
  [self setPathToNetworkImage: pathToNetworkImage
               forDisplaySize: displaySize
                  contentMode: contentMode
                     cropRect: CGRectZero];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage cropRect:(CGRect)cropRect {
  [self setPathToNetworkImage: pathToNetworkImage
               forDisplaySize: CGSizeZero
                  contentMode: self.contentMode
                     cropRect: cropRect];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage contentMode:(UIViewContentMode)contentMode {
  [self setPathToNetworkImage: pathToNetworkImage
               forDisplaySize: CGSizeZero
                  contentMode: contentMode
                     cropRect: CGRectZero];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPathToNetworkImage:(NSString *)pathToNetworkImage forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode cropRect:(CGRect)cropRect {
  [self cancelOperation];

  if (NIIsStringWithAnyText(pathToNetworkImage)) {
    self.lastPathToNetworkImage = pathToNetworkImage;

    NSURL* url = nil;

    // Check for file URLs.
    if ([pathToNetworkImage hasPrefix:@"/"]) {
      // If the url starts with / then it's likely a file URL, so treat it accordingly.
      url = [NSURL fileURLWithPath:pathToNetworkImage];

    } else {
      // Otherwise we assume it's a regular URL.
      url = [NSURL URLWithString:pathToNetworkImage];
    }

    // If the URL failed to be created, there's not much we can do here.
    if (nil == url) {
      return;
    }
    
    NINetworkImageRequest* request = [[[NINetworkImageRequest alloc] initWithURL:url] autorelease];
    [self setNetworkImageOperation:request forDisplaySize:displaySize contentMode:contentMode cropRect:cropRect];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNetworkImageOperation:(NIOperation<NINetworkImageOperation> *)operation forDisplaySize:(CGSize)displaySize contentMode:(UIViewContentMode)contentMode cropRect:(CGRect)cropRect {
  [self cancelOperation];

  if (nil != operation) {
    // We explicitly do not allow negative display sizes. Check the call stack to figure
    // out who is providing a negative display size. It's possible that displaySize is an
    // uninitialized CGSize structure.
    NIDASSERT(displaySize.width >= 0);
    NIDASSERT(displaySize.height >= 0);

    // If an invalid display size is provided, use the image view's frame instead.
    if (0 >= displaySize.width || 0 >= displaySize.height) {
      displaySize = self.frame.size;
    }

    UIImage* image = nil;

    // Attempt to load the image from memory first.
    if (nil != self.imageMemoryCache) {
      NSString* cacheKey = [self cacheKeyForCacheIdentifier:operation.cacheIdentifier
                                                  imageSize:displaySize
                                                contentMode:contentMode
                                               scaleOptions:self.scaleOptions];
      image = [self.imageMemoryCache objectWithName:cacheKey];
    }

    if (nil != image) {
      // We successfully loaded the image from memory.
      [self setImage:image];

      if ([self.delegate respondsToSelector:@selector(networkImageView:didLoadImage:)]) {
        [self.delegate networkImageView:self didLoadImage:self.image];
      }

      [self networkImageViewDidLoadImage:image];

    } else {
      // Unable to load the image from memory, so let's fire off the operation now.
      operation.delegate = self;

      operation.imageCropRect = cropRect;
      operation.scaleOptions = self.scaleOptions;
      operation.interpolationQuality = self.interpolationQuality;
      if (self.sizeForDisplay) {
        operation.imageDisplaySize = displaySize;
        operation.imageContentMode = contentMode;
      }

      self.operation = operation;

      [self.networkOperationQueue addOperation:self.operation];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [self cancelOperation];

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
  return nil != self.operation;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNetworkOperationQueue:(NSOperationQueue *)queue {
  // Don't allow a nil network operation queue.
  NIDASSERT(nil != queue);
  if (nil == queue) {
    queue = [Nimbus networkOperationQueue];
  }
  if (queue != _networkOperationQueue) {
    [_networkOperationQueue release];
    _networkOperationQueue = [queue retain];
  }
}


@end

