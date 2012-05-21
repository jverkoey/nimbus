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
 * @defgroup NimbusOperations Nimbus Operations
 * @{
 *
 * Processing data is a potential bottleneck for any application that manipulates it.
 * Older iPhone and iPod touch models get the worst of this with their slower processors
 * and smaller amounts of ram. It's important to pull data processing off of the main UI thread.
 * Nimbus operations provide a consistent means of processing data in a defered way using
 * the NIOperation class of objects.
 *
 *
 * <h2>Suggestions for Picking a Processing Method</h2>
 *
 * <h3>Use Blocks and NIOperationDelegate for One-Off Implementations</h3>
 *
 * Blocks are useful when writing inline code quickly, but after a certain point of complexity it
 * may be cleaner to implement the delegate. If your block spans more than 10 lines of code or so,
 * it might be worth considering moving the logic into the delegate method.
 *
 * <h3>Subclass Common Functionality</h3>
 *
 * If you find yourself repeating the same functionality across a variety of controllers then you
 * should consider building a subclass. A good example is NINetworkJSONRequest, which subclasses
 * NINetworkRequestOperation and turns the response data into Objective-C objects.
 * NINetworkRequestOperation can be reused throughout an application as a result.
 *
 * <h2>Examples</h2>
 *
 * <h3>Fetching the Name of a Node in the Facebook Graph</h3>
 *
 * @code
 *  // The graph API path for the Nimbus Facebook group.
 *  NSString* urlPath = @"https://graph.facebook.com/186162441444201";
 *
 *  // Create a JSONKit request that will turn the response data into Objective-C objects.
 *  // Define the request with __block so that it doesn't cause a retain cycle when we access
 *  // the request object from within the block.
 *  __block NINetworkJSONRequest* request = [[[NINetworkJSONRequest alloc] initWithURL:
 *                                            [NSURL URLWithString:urlPath]] autorelease];
 *
 *  // Called on the operation's thread.
 *  // We can do computationally expensive operations here without blocking the UI in any way.
 *  // Note: You must be careful not to access any non-thread-safe objects from within this block.
 *  request.willFinishBlock = ^(NIOperation* operation) {
 *
 *    NSString* graphName = nil;
 *
 *    // By this point the JSON will have been turned into an object.
 *    graphName = [request.processedObject objectForKey:@"name"];
 *
 *    // The block expects us to return an id type.
 *    return (id)graphName;
 *  };
 *
 *  // Avoid a retain cycle of self.
 *  __block UIViewController* vc = self;
 *
 *  // Called on the main UI thread. This method should be light-weight.
 *  request.didFinishBlock = ^(NIOperation* operation) {
 *    NSString* graphName = request.processedObject;
 *    // Do what we will with the graph name now.
 *    vc.title = graphName;
 *  };
 *
 *  [operationQueue addOperation:request];
 *
 * @endcode
 *
 */

/**
 * @defgroup Network-Operations Network Operations
 *
 * Operations designed specifically for network data processing. These operations process the data
 * after it has been successfully downloaded, but before the request returns the data to the main
 * thread. These operations subclass NINetworkRequestOperation.
 */

/**@}*/
