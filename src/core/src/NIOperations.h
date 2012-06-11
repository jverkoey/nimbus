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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIBlocks.h"

/**
 * For writing code that runs concurrently.
 *
 * @ingroup NimbusCore
 * @defgroup Operations Operations
 *
 * This collection of NSOperation implementations is meant to provide a set of common
 * operations that might be used in an application to offload complex processing to a separate
 * thread.
 */

@protocol NIOperationDelegate;

/**
 * A base implementation of an NSOperation that supports traditional delegation and blocks.
 *
 * <h2>Subclassing</h2>
 *
 * A subclass should call the operationDid* methods to notify the delegate on the main thread
 * of changes in the operation's state. Calling these methods will notify the delegate and the
 * blocks if provided.
 *
 *      @ingroup Operations
 */
@interface NIOperation : NSOperation

@property (readwrite, assign) id<NIOperationDelegate> delegate;
@property (readonly, retain) NSError* lastError;
@property (readwrite, assign) NSInteger tag;

#if NS_BLOCKS_AVAILABLE

@property (readwrite, copy) NIBasicBlock didStartBlock;
@property (readwrite, copy) NIBasicBlock didFinishBlock;
@property (readwrite, copy) NIErrorBlock didFailWithErrorBlock;
@property (readwrite, copy) NIBasicBlock willFinishBlock;

#endif // #if NS_BLOCKS_AVAILABLE

- (void)didStart;
- (void)didFinish;
- (void)didFailWithError:(NSError *)error;
- (void)willFinish;

@end

/**
 * An operation that makes a network request.
 *
 * Provides asynchronous network request support when added to an NSOperationQueue.
 *
 * If the url provided is a file url, then the file will be loaded from disk instead.
 *
 *      @ingroup Operations
 */
@interface NINetworkRequestOperation : NIOperation

// Designated initializer.
- (id)initWithURL:(NSURL *)url;

@property (readwrite, copy) NSURL* url;
@property (readwrite, assign) NSTimeInterval timeout; // Default: 60
@property (readwrite, assign) NSURLRequestCachePolicy cachePolicy; // Default: NSURLRequestUseProtocolCachePolicy
@property (readonly, retain) NSData* data;
@property (readwrite, retain) id processedObject;

@end

/**
 * The delegate protocol for an NIOperation.
 *
 *      @ingroup Operations
 */
@protocol NIOperationDelegate <NSObject>
@optional

/** @name [NIOperationDelegate] State Changes */

/** The operation has started executing. */
- (void)nimbusOperationDidStart:(NIOperation *)operation;

/**
 * The operation is about to complete successfully.
 *
 * This will not be called if the operation fails.
 *
 * This will be called from within the operation's runloop and must be thread safe.
 */
- (void)nimbusOperationWillFinish:(NIOperation *)operation;

/**
 * The operation has completed successfully.
 *
 * This will not be called if the operation fails.
 */
- (void)nimbusOperationDidFinish:(NIOperation *)operation;

/**
 * The operation failed in some way and has completed.
 *
 * operationDidFinish: will not be called.
 */
- (void)nimbusOperationDidFail:(NIOperation *)operation withError:(NSError *)error;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
// NIOperation

/** @name Delegation */

/**
 * The delegate through which changes are notified for this operation.
 *
 * All delegate methods are performed on the main thread.
 *
 *      @fn NIOperation::delegate
 */


/** @name Post-Operation Properties */

/**
 * The error last passed to the didFailWithError notification.
 *
 *      @fn NIOperation::lastError
 */


/** @name Identification */

/**
 * A simple tagging mechanism for identifying operations.
 *
 *      @fn NIOperation::tag
 */


#if NS_BLOCKS_AVAILABLE
/** @name Blocks */

/**
 * The operation has started executing.
 *
 * Performed on the main thread.
 *
 *      @fn NIOperation::didStartBlock
 */

/**
 * The operation has completed successfully.
 *
 * This will not be called if the operation fails.
 *
 * Performed on the main thread.
 *
 *      @fn NIOperation::didFinishBlock
 */

/**
 * The operation failed in some way and has completed.
 *
 * didFinishBlock will not be executed.
 *
 * Performed on the main thread.
 *
 *      @fn NIOperation::didFailWithErrorBlock
 */

/**
 * The operation is about to complete successfully.
 *
 * This will not be called if the operation fails.
 *
 * Performed in the operation's thread.
 *
 *      @fn NIOperation::willFinishBlock
 */
#endif // #if NS_BLOCKS_AVAILABLE


/**
 * @name Subclassing
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */

/**
 * On the main thread, notify the delegate that the operation has begun.
 *
 *      @fn NIOperation::didStart
 */

/**
 * On the main thread, notify the delegate that the operation has finished.
 *
 *      @fn NIOperation::didFinish
 */

/**
 * On the main thread, notify the delegate that the operation has failed.
 *
 *      @fn NIOperation::didFailWithError:
 */

/**
 * In the operation's thread, notify the delegate that the operation will finish successfully.
 *
 *      @fn NIOperation::willFinish
 */


// NINetworkRequestOperation

/** @name Creating an Operation */

/**
 * Initializes a newly allocated network operation with a given url.
 *
 *      @fn NINetworkRequestOperation::initWithURL:
 */


/** @name Configuring the Operation */

/**
 * The url that will be loaded in the network operation.
 *
 *      @fn NINetworkRequestOperation::url
 */

/**
 * The number of seconds that may pass before a request gives up and fails.
 *
 *      @fn NINetworkRequestOperation::timeout
 */

/**
 * The request cache policy to use.
 *
 *      @fn NINetworkRequestOperation::cachePolicy
 */


/** @name Operation Results */

/**
 * The data received from the request.
 *
 * Will be nil if the request failed.
 *
 *      @sa NIOperation::lastError
 *      @fn NINetworkRequestOperation::data
 */

/**
 * An object created from the data that was fetched.
 *
 * Will be nil if the request failed.
 *
 *      @sa NIOperation::lastError
 *      @fn NINetworkRequestOperation::processedObject
 */
