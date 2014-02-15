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

@class NIImageMemoryCache;

/**
 * For modifying Nimbus state information.
 *
 * @ingroup NimbusCore
 * @defgroup Core-State State
 * @{
 *
 * The Nimbus core provides a common layer of features used by nearly all of the libraries in
 * the Nimbus ecosystem. Here you will find methods for accessing and setting the global image
 * cache amongst other things.
 */

/**
 * The Nimbus state interface.
 *
 * @ingroup Core-State
 */
@interface Nimbus : NSObject

#pragma mark Accessing Global State /** @name Accessing Global State */

/**
 * Access the global image memory cache.
 *
 * If a cache hasn't been assigned via Nimbus::setGlobalImageMemoryCache: then one will be created
 * automatically.
 *
 * @remarks The default image cache has no upper limit on its memory consumption. It is
 *               up to you to specify an upper limit in your application.
 */
+ (NIImageMemoryCache *)imageMemoryCache;

/**
 * Access the global network operation queue.
 *
 * The global network operation queue exists to be used for asynchronous network requests if
 * you choose. By defining a global operation queue in the core of Nimbus, we can ensure that
 * all libraries that depend on core will use the same network operation queue unless configured
 * otherwise.
 *
 * If an operation queue hasn't been assigned via Nimbus::setGlobalNetworkOperationQueue: then
 * one will be created automatically with the default iOS settings.
 */
+ (NSOperationQueue *)networkOperationQueue;

#pragma mark Modifying Global State /** @name Modifying Global State */

/**
 * Set the global image memory cache.
 *
 * The cache will be retained and the old cache released.
 */
+ (void)setImageMemoryCache:(NIImageMemoryCache *)imageMemoryCache;

/**
 * Set the global network operation queue.
 *
 * The queue will be retained and the old queue released.
 */
+ (void)setNetworkOperationQueue:(NSOperationQueue *)queue;

@end

/**@}*/// End of State ////////////////////////////////////////////////////////////////////////////
