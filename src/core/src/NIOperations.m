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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIReadFileFromDiskOperation()

@property (nonatomic, readwrite, retain) NSData* data;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIReadFileFromDiskOperation

@synthesize pathToFile  = _pathToFile;
@synthesize data        = _data;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pathToFile);
  NI_RELEASE_SAFELY(_data);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPathToFile:(NSString *)pathToFile {
  if ((self = [super init])) {
    self.pathToFile = pathToFile;
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

  [self operationDidStart];

  NSError* error = nil;

  self.data = [[NSData dataWithContentsOfFile: self.pathToFile
                                      options: 0
                                        error: &error]
               copy];


  if (nil != error) {
    [self operationDidFailWithError:error];

  } else {
    [self operationDidFinish];
  }

  NI_RELEASE_SAFELY(pool);
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIOperation()

@property (nonatomic, readwrite, retain) NSError* lastError;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOperation

@synthesize delegate = _delegate;
@synthesize lastError = _lastError;

#if NS_BLOCKS_AVAILABLE
@synthesize didStartBlock         = _didStartBlock;
@synthesize didFinishBlock        = _didFinishBlock;
@synthesize didFailWithErrorBlock = _didFailWithErrorBlock;
#endif // #if NS_BLOCKS_AVAILABLE


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_lastError);

#if NS_BLOCKS_AVAILABLE
  NI_RELEASE_SAFELY(_didStartBlock);
  NI_RELEASE_SAFELY(_didFinishBlock);
  NI_RELEASE_SAFELY(_didFailWithErrorBlock);
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
