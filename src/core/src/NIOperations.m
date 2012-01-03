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

#import "NIOperations.h"

#import "NIDebuggingTools.h"
#import "NIPreprocessorMacros.h"
#import "NIOperations+Subclassing.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINetworkRequestOperation

@synthesize url = _url;
@synthesize timeout = _timeout;
@synthesize cachePolicy = _cachePolicy;
@synthesize data = _data;
@synthesize processedObject = _processedObject;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_url);
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_processedObject);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)url {
  if ((self = [super init])) {
    self.url = url;
    self.timeout = 60;
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSOperation


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)main {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  if ([self.url isFileURL]) {
    // Special case: load the image from disk without hitting the network.

    [self operationDidStart];

    NSError* dataReadError = nil;

    // The meat of the load-from-disk operation.
    NSString* filePath = [self.url path];
    NSMutableData* data = [NSMutableData dataWithContentsOfFile:filePath
                                                        options:0
                                                          error:&dataReadError];

    if (nil != dataReadError) {
      // This generally happens when the file path points to a file that doesn't exist.
      // dataReadError has the complete details.
      [self operationDidFailWithError:dataReadError];

    } else {
      self.data = data;

      // Notifies the delegates of the request completion.
      [self operationWillFinish];
      [self operationDidFinish];
    }

  } else {
    // Load the image from the network then.
    [self operationDidStart];

    NSURLRequest* request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:self.cachePolicy
                                         timeoutInterval:self.timeout];

    NSError* networkError = nil;
    NSURLResponse* response = nil;
    NSData* data  = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&networkError];

    if (nil != networkError) {
      [self operationDidFailWithError:networkError];

    } else {
      self.data = data;

      [self operationWillFinish];
      [self operationDidFinish];
    }
  }

  NI_RELEASE_SAFELY(pool);
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOperation

@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize lastError = _lastError;

#if NS_BLOCKS_AVAILABLE
@synthesize didStartBlock         = _didStartBlock;
@synthesize didFinishBlock        = _didFinishBlock;
@synthesize didFailWithErrorBlock = _didFailWithErrorBlock;
@synthesize willFinishBlock       = _willFinishBlock;
#endif // #if NS_BLOCKS_AVAILABLE


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_lastError);

#if NS_BLOCKS_AVAILABLE
  NI_RELEASE_SAFELY(_didStartBlock);
  NI_RELEASE_SAFELY(_didFinishBlock);
  NI_RELEASE_SAFELY(_didFailWithErrorBlock);
  NI_RELEASE_SAFELY(_willFinishBlock);
#endif // #if NS_BLOCKS_AVAILABLE

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initiate delegate notification from the NSOperation


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidStart {
	[self performSelectorOnMainThread: @selector(onMainThreadOperationDidStart)
                         withObject: nil
                      waitUntilDone: [NSThread isMainThread]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFinish {
	[self performSelectorOnMainThread: @selector(onMainThreadOperationDidFinish)
                         withObject: nil
                      waitUntilDone: [NSThread isMainThread]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFailWithError:(NSError *)error {
  self.lastError = error;

	[self performSelectorOnMainThread: @selector(onMainThreadOperationDidFailWithError:)
                         withObject: error
                      waitUntilDone: [NSThread isMainThread]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationWillFinish {
  if ([self.delegate respondsToSelector:@selector(operationWillFinish:)]) {
    [self.delegate operationWillFinish:self];
  }

#if NS_BLOCKS_AVAILABLE
  if (nil != self.willFinishBlock) {
    self.willFinishBlock();
  }
#endif // #if NS_BLOCKS_AVAILABLE
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Main Thread


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)onMainThreadOperationDidStart {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(operationDidStart:)]) {
    [self.delegate operationDidStart:self];
  }

#if NS_BLOCKS_AVAILABLE
  if (nil != self.didStartBlock) {
    self.didStartBlock();
  }
#endif // #if NS_BLOCKS_AVAILABLE
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)onMainThreadOperationDidFinish {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(operationDidFinish:)]) {
    [self.delegate operationDidFinish:self];
  }

#if NS_BLOCKS_AVAILABLE
  if (nil != self.didFinishBlock) {
    self.didFinishBlock();
  }
#endif // #if NS_BLOCKS_AVAILABLE
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)onMainThreadOperationDidFailWithError:(NSError *)error {
  // This method should only be called on the main thread.
  NIDASSERT([NSThread isMainThread]);

  if ([self.delegate respondsToSelector:@selector(operationDidFail:withError:)]) {
    [self.delegate operationDidFail:self withError:error];
  }

#if NS_BLOCKS_AVAILABLE
  if (nil != self.didFailWithErrorBlock) {
    self.didFailWithErrorBlock(error);
  }
#endif // #if NS_BLOCKS_AVAILABLE
}


@end
