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

/**
 * @defgroup NimbusProcessors Nimbus Processors
 * @{
 *
 * Processors are for performing complex data manipulation on separate threads.
 *
 * Processing data is a potential bottleneck for any application that manipulates data.
 * Older iPhone and iPod touch models get the worst of this with their slower processors
 * and smaller amounts of ram. As such, it's very important to attempt to push off any
 * data processing from the main UI thread. Nimbus processors provide a consistent means
 * of processing data in a defered way using NSOperations.
 *
 * <h2>Processor Chain of Operations</h2>
 *
 * Processors process their data in the following order, with the result and any errors from
 * each step being fed to the next one.
 *
 * -# <b>[subclass]</b> <i>objectFromResponseData:error:</i>
 * -# <b>   [block]</b> <i>processDataBlock(object, error)</i>
 * -# <b>[delegate]</b> <i>processor:processObject:error:</i>
 *
 *
 * <h2>Suggestions for Picking a Processing Method</h2>
 *
 * <h3>Use Blocks and NIProcessorDelegate for One-Off Implementations</h3>
 *
 * Blocks can be particularly handy for writing inline code quickly, but after a certain
 * point of complexity it may be cleaner to use the processorDelegate. If your block is
 * spans more than 10 lines of code or so, it might be worth considering moving the logic
 * into the delegate method.
 *
 * <h3>Subclass Common Functionality</h3>
 *
 * If you find yourself repeating the same functionality across a variety of
 * controllers you should consider building a subclass. A good example is
 * the NIJSONKitProcessorHTTPRequest, which subclasses NIProcessorHTTPRequest and
 * turns the response data into Objective-C objects. This class can now be reused
 * throughout an application.
 *
 * <h2>Examples</h2>
 *
 * <h3>Fetching the Name of a Node in the Facebook Graph</h3>
 *
 * @code
 *  // The graph API path for the Nimbus Facebook group.
 *  NSString* urlPath = @"https://graph.facebook.com/186162441444201";
 *
 *  // Create a JSONKit processor that will turn the response data into Objective-C objects.
 *  NIProcessorHTTPRequest* request = [[[NIJSONKitProcessorHTTPRequest alloc] initWithURL:
 *                                      [NSURL URLWithString:urlPath]] autorelease];
 *
 *  // The following block will be processed on the processor request's thread and is
 *  // step 2 in the chain of operations outlined above.
 *  // We can do computationally expensive operations here without blocking the UI in any way.
 *  // Note: You must be careful not to access any non-thread-safe objects from within this block.
 *  request.processDataBlock = ^(id object, NSError** error) {
 *
 *    // By this point step 1 of the chain of operations will have been performed and
 *    // JSONKit will have turned the JSON response data into an object, assuming it didn't fail.
 *    NSString* graphName = nil;
 *
 *    // If JSONKit failed to parse the object then there's nothing we can do here.
 *    if (nil != *error) {
 *      graphName = [object objectForKey:@"name"];
 *    }
 *
 *    // The block expects us to return an id type.
 *    return (id)graphName;
 *  };
 *
 *  // This allows us to receive notification of completion for this request.
 *  request.delegate = self;
 *
 *  [operationQueue addOperation:request];
 *
 *
 *  // Called on the main thread.
 *  - (void)requestFinished:(NIProcessorHTTPRequest *)request {
 *    NSString* graphName = [request.processedObject retain];
 *    // Do what we will with the graph name now.
 *    self.title = graphName;
 *  }
 * @endcode
 *
 */

/**
 * @defgroup Network-Processors Network Processors
 *
 * Processors designed specifically for network access. These processors will process their
 * data after the data has been successfully downloaded, but before the request returns
 * the data to the main thread. This allows data to be processed after it has been downloaded
 * but before the UI has to deal with it.
 */

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusProcessors/NIProcessorHTTPRequest.h"
#import "NimbusProcessors/NIProcessorDelegate.h"
#else
#import "NIProcessorHTTPRequest.h"
#import "NIProcessorDelegate.h"
#endif

/**@}*/
