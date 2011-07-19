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

#if NS_BLOCKS_AVAILABLE
typedef id (^NIProcessorBlock)(id object, NSError** error);
#endif

/**
 * Defines the basic protocol for processing data.
 *
 *      @ingroup NimbusProcessors
 */
@protocol NIProcessorDelegate <NSObject>

@required

/**
 * Called as the final step in the processing order.
 *
 * It is recommended that you implement this method as a class method and assign (id)[self class]
 * to the processorDelegate member of the NIProcessorHTTPRequest instance. This is because
 * this method will be called from the NIProcessorHTTPRequest thread, not the main thread, so
 * you must be careful not to touch any non thread-safe data.
 *
 *      @param processor        The object that initiated the call to this method.
 *      @param object           The latest object in the processing pipeline.
 *      @param processingError  The latest error that has occurred in the processing pipeline.
 */
- (id)processor:(id)processor processObject:(id)object error:(NSError **)processingError;

@end
