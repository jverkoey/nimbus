//
// Copyright 2011-2014 NimbusKit
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

#import "NIPreprocessorMacros.h" /* for weak */

@class NIOperation;

typedef void (^NIOperationBlock)(NIOperation* operation);
typedef void (^NIOperationDidFailBlock)(NIOperation* operation, NSError* error);

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
 * @ingroup Operations
 */
@interface NIOperation : NSOperation

@property (weak) id<NIOperationDelegate> delegate;
@property (readonly, strong) NSError* lastError;
@property (assign) NSInteger tag;

@property (copy) NIOperationBlock didStartBlock;
@property (copy) NIOperationBlock didFinishBlock;
@property (copy) NIOperationDidFailBlock didFailWithErrorBlock;
@property (copy) NIOperationBlock willFinishBlock;

- (void)didStart;
- (void)didFinish;
- (void)didFailWithError:(NSError *)error;
- (void)willFinish;

@end

/**
 * The delegate protocol for an NIOperation.
 *
 * @ingroup Operations
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


// NIOperation

/** @name Delegation */

/**
 * The delegate through which changes are notified for this operation.
 *
 * All delegate methods are performed on the main thread.
 *
 * @fn NIOperation::delegate
 */


/** @name Post-Operation Properties */

/**
 * The error last passed to the didFailWithError notification.
 *
 * @fn NIOperation::lastError
 */


/** @name Identification */

/**
 * A simple tagging mechanism for identifying operations.
 *
 * @fn NIOperation::tag
 */


/** @name Blocks */

/**
 * The operation has started executing.
 *
 * Performed on the main thread.
 *
 * @fn NIOperation::didStartBlock
 */

/**
 * The operation has completed successfully.
 *
 * This will not be called if the operation fails.
 *
 * Performed on the main thread.
 *
 * @fn NIOperation::didFinishBlock
 */

/**
 * The operation failed in some way and has completed.
 *
 * didFinishBlock will not be executed.
 *
 * Performed on the main thread.
 *
 * @fn NIOperation::didFailWithErrorBlock
 */

/**
 * The operation is about to complete successfully.
 *
 * This will not be called if the operation fails.
 *
 * Performed in the operation's thread.
 *
 * @fn NIOperation::willFinishBlock
 */


/**
 * @name Subclassing
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */

/**
 * On the main thread, notify the delegate that the operation has begun.
 *
 * @fn NIOperation::didStart
 */

/**
 * On the main thread, notify the delegate that the operation has finished.
 *
 * @fn NIOperation::didFinish
 */

/**
 * On the main thread, notify the delegate that the operation has failed.
 *
 * @fn NIOperation::didFailWithError:
 */

/**
 * In the operation's thread, notify the delegate that the operation will finish successfully.
 *
 * @fn NIOperation::willFinish
 */
