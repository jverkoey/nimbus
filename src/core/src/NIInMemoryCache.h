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

/**
 * For storing and accessing objects in memory.
 *
 * @ingroup NimbusCore
 * @defgroup In-Memory-Caches In-Memory Caches
 * @{
 *
 * The base class, NIMemoryCache, is a generic object store that may be used for anything that
 * requires support for expiration.
 */

@class NILinkedList;

/**
 * An in-memory cache for storing objects with expiration support.
 *
 * The Nimbus in-memory object cache allows you to store objects in memory with an expiration
 * date attached. Objects with expiration dates drop out of the cache when they have expired.
 */
@interface NIMemoryCache : NSObject {
@private
  // Mapping from a name (usually a URL) to an internal object.
  NSMutableDictionary*  _cacheMap;

  // A linked list of least recently used cache objects. Most recently used is the tail.
  NILinkedList*         _lruCacheObjects;
}

/**
 * Initialize the cache with no initial capacity.
 */
- (id)init;

/**
 * Designated initializer. Initialize the cache with an initial capacity.
 *
 * Use a best guess to avoid having the internal data structure reallocate its memory repeatedly
 * - at least up up to a certain point - as the cache grows.
 */
- (id)initWithCapacity:(NSUInteger)capacity;

/**
 * Store an object in the cache.
 *
 *      @param object  The object being stored in the cache.
 *      @param name    The name used as a key to store this object.
 *
 * The object will be stored without an expiration date. The object will stay in the cache until
 * it's bumped out due to the cache's memory limit.
 */
- (void)storeObject:(id)object withName:(NSString *)name;

/**
 * Store an object in the cache with an expiration date.
 *
 *      @param object          The object being stored in the cache.
 *      @param name            The name used as a key to store this object.
 *      @param expirationDate  A date after which this object is no longer valid in the cache.
 *
 * If an object is stored with an expiration date that has already passed then the object will
 * not be stored in the cache and any existing object will be removed. The rationale behind this
 * is that the object would be removed from the cache the next time it was accessed anyway.
 */
- (void)storeObject:(id)object withName:(NSString *)name expiresAfter:(NSDate *)expirationDate;

/**
 * Retrive an object from the cache.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 */
- (id)objectWithName:(NSString *)name;

/**
 * Remove an object in the cache.
 *
 *      @param name The name used as a key to store this object.
 */
- (void)removeObjectWithName:(NSString *)name;

/**
 * Remove all objects from the cache, regardless of expiration dates.
 *
 * This will completely clear out the cache and all objects in the cache will be released.
 */
- (void)removeAllObjects;

/**
 * Remove all expired objects from the cache.
 *
 * This is meant to be used when a memory warning is received. Subclasses may add additional
 * functionality to this implementation.
 */
- (void)reduceMemoryUsage;

/**
 * The number of objects stored in this cache.
 */
@property (nonatomic, readonly) NSUInteger count;


/**
 * @name Subclassing
 * @{
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */
#pragma mark Subclassing

/**
 * An object is about to be stored in the cache.
 *
 *      @param object          The object to be stored in the cache.
 *      @param name            The cache name for the object.
 *      @param previousObject  The object previously stored in the cache. This may be the
 *                             same as object.
 */
- (void)willSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject;

/**
 * An object is about to be removed from the cache.
 *
 *      @param object  The object about to removed from the cache.
 *      @param name    The cache name for the object about to be removed.
 */
- (void)willRemoveObject:(id)object withName:(NSString *)name;

/**@}*/

@end


/**
 * An in-memory cache for storing images with a least-recently-used memory cap.
 */
@interface NIImageMemoryCache : NIMemoryCache {
@private
  NSUInteger _totalMemoryUsage;

  NSUInteger _maxTotalMemoryUsage;
  NSUInteger _maxTotalLowMemoryUsage;
}

/**
 * The total amount of memory being used.
 */
@property (nonatomic, readonly, assign) NSUInteger totalMemoryUsage;

/**
 * The maximum amount of memory this cache may ever use.
 *
 * Defaults to 0, which is special cased to represent an unbounded cache size.
 */
@property (nonatomic, readwrite, assign) NSUInteger maxTotalMemoryUsage;

/**
 * The maximum amount of memory this cache may use after a call to reduceMemoryUsage.
 *
 * Defaults to 0, which is special cased to represent an unbounded cache size.
 */
@property (nonatomic, readwrite, assign) NSUInteger maxTotalLowMemoryUsage;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of In-Memory Cache //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
