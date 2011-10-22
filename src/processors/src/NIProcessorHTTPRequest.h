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

#import "NIHTTPRequest.h"
#import "NIProcessorDelegate.h"

/**
 * An HTTP request that processes the returned data on a separate thread.
 *
 * This type of request is incredibly useful for transforming response data into application
 * objects. For example, turning a request to a JSON endpoint into application-specific objects.
 *
 * There are specific implementations of this request built for a variety of data formats that
 * can be used for convenience. There are three ways you can modify the data in the pipeline.
 * See the @link NimbusProcessors Nimbus Processors@endlink documentation for more information
 * about these three steps.
 *
 *      @ingroup Network-Processors
 */
@interface NIProcessorHTTPRequest : NIHTTPRequest {
@private
  id _processedObject;

  __unsafe_unretained id<NIProcessorDelegate> _processorDelegate;

#if NS_BLOCKS_AVAILABLE
  NIProcessorBlock _processDataBlock;
#endif
}

#pragma mark Results /** @name Results */

/**
 * The resulting root object after the request has completed and the data has been processed.
 */
@property (nonatomic, readonly, retain) id processedObject;


#pragma mark Pipeline Processing Steps /** @name Pipeline Processing Steps */

/**
 * A subclass should implement this method and transform the data into an object.
 *
 * By default this method returns the data object unmodified.
 */
- (id)objectFromResponseData:(NSData *)data error:(NSError **)error;

#if NS_BLOCKS_AVAILABLE

/**
 * The second step in the processing order for the data.
 *
 * This will be called immediately after rootObjectFromResponseData is called on this
 * instance.
 */
@property (readwrite, copy) NIProcessorBlock processDataBlock;

/**
 * The final step in the processing order for the data.
 *
 * This delegate's methods will be called after the subclass' processDataBlock implementation
 * and this instance's blocks have been executed.
 */
@property (nonatomic, readwrite, assign) id<NIProcessorDelegate> processorDelegate;

#endif

@end
