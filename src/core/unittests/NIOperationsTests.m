//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 9, 2011 - Copyright 2009-2011 Facebook
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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NIOperations.h"
#import "NIPreprocessorMacros.h"
#import "NIPaths.h"

@interface NIOperationsTests : SenTestCase <NIOperationDelegate> {
@private
  NSMutableArray* _delegateMethodsCalled;
  NSBundle*       _unitTestBundle;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOperationsTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  _delegateMethodsCalled = [[NSMutableArray alloc] init];
  _unitTestBundle = [NSBundle bundleWithIdentifier:@"com.nimbus.core.unittests"];
  STAssertNotNil(_unitTestBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Test read file from disk


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskInitialization {
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"nimbus64x64.png");
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:pathToFile isDirectory:NO]];

  STAssertNil(op.data, @"Data should be nil to start.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDisk {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"nimbus64x64.png")
                                              isDirectory:NO]];

  NSOperationQueue* queue = [[NSOperationQueue alloc] init];

  [queue addOperation:op];
  [queue waitUntilAllOperationsAreFinished];

  STAssertNotNil(op.data, @"Data should have been read from the image.");

  UIImage* image = [[UIImage alloc] initWithData:op.data];

  STAssertNotNil(image, @"Image should have been created.");
  STAssertEquals(image.size.width, 64.f, @"Image dimensions should be 64 wide.");
  STAssertEquals(image.size.height, 64.f, @"Image dimensions should be 64 tall.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskFailure {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"bogusfile.abc")
                                              isDirectory:NO]];
  
  NSOperationQueue* queue = [[NSOperationQueue alloc] init];

  [queue addOperation:op];
  [queue waitUntilAllOperationsAreFinished];

  STAssertNil(op.data, @"No data should have been read from the image.");
  STAssertEquals([op.lastError domain], NSCocoaErrorDomain,
                 @"Error should be within the Cocoa domain.");
  STAssertEquals([op.lastError code], 260,
                 @"Code should be 260 for 'The operation couldn’t be completed'.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskWithDelegateSuccess {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"nimbus64x64.png")
                                              isDirectory:NO]];

  op.delegate = self;

  // Run the operation synchronously.
  [op main];

  STAssertEquals([_delegateMethodsCalled count], (NSUInteger)2,
                 @"Start and finish should have been called.");
  STAssertTrue([_delegateMethodsCalled containsObject:
                NSStringFromSelector(@selector(operationDidStart:))],
               @"operationDidStart: should have been called.");
  STAssertTrue([_delegateMethodsCalled containsObject:
                NSStringFromSelector(@selector(operationDidFinish:))],
               @"operationDidFinish: should have been called.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskWithDelegateFailure {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"bogusfile.abc")
                                              isDirectory:NO]];

  op.delegate = self;

  // Run the operation synchronously.
  [op main];

  STAssertEquals([_delegateMethodsCalled count], (NSUInteger)2,
                 @"Start and finish should have been called.");
  STAssertTrue([_delegateMethodsCalled containsObject:
                NSStringFromSelector(@selector(operationDidStart:))],
               @"operationDidStart: should have been called.");
  STAssertTrue([_delegateMethodsCalled containsObject:
                NSStringFromSelector(@selector(operationDidFail:withError:))],
               @"operationDidFail:withError: should have been called.");

  STAssertEquals([op.lastError domain], NSCocoaErrorDomain,
                 @"Error should be within the Cocoa domain.");
  STAssertEquals([op.lastError code], 260,
                 @"Code should be 260 for 'The operation couldn’t be completed'.");
}


#pragma mark Blocks

#if NS_BLOCKS_AVAILABLE

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskWithBlocksSuccess {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"nimbus64x64.png")
                                              isDirectory:NO]];

  __block BOOL didStart = NO;
  __block BOOL didFinish = NO;

  op.didStartBlock = ^{
    didStart = YES;
  };

  op.didFinishBlock = ^{
    didFinish = YES;
  };

  // Run the operation synchronously.
  [op main];

  STAssertTrue(didStart, @"didStartBlock should have been called.");
  STAssertTrue(didFinish, @"didFinishBlock should have been called.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testReadFileFromDiskWithBlocksFailure {
  NINetworkRequestOperation* op = [[NINetworkRequestOperation alloc] initWithURL:
                                   [NSURL fileURLWithPath:NIPathForBundleResource(_unitTestBundle, @"bogusfile.abc")
                                              isDirectory:NO]];

  __block BOOL didStart = NO;
  __block BOOL didFail = NO;
  __block NSError* failureError = nil;

  op.didStartBlock = ^{
    didStart = YES;
  };

  op.didFailWithErrorBlock = ^(NSError* error) {
    didFail = YES;
    failureError = [error copy];
  };

  // Run the operation synchronously.
  [op main];

  STAssertTrue(didStart, @"didStartBlock should have been called.");
  STAssertTrue(didFail, @"didFailWithErrorBlock should have been called.");

  STAssertEquals([failureError domain], NSCocoaErrorDomain,
                 @"Error should be within the Cocoa domain.");
  STAssertEquals([failureError code], 260,
                 @"Code should be 260 for 'The operation couldn’t be completed'.");
}

#endif // #if NS_BLOCKS_AVAILABLE


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidStart:(NSOperation *)operation {
  [_delegateMethodsCalled addObject:NSStringFromSelector(_cmd)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFinish:(NSOperation *)operation {
  [_delegateMethodsCalled addObject:NSStringFromSelector(_cmd)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)operationDidFail:(NSOperation *)operation withError:(NSError *)error {
  [_delegateMethodsCalled addObject:NSStringFromSelector(_cmd)];
}


@end
