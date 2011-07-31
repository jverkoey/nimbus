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
 * The base class, NIMemoryCache, is a generic object store that may be used for anything that
 * requires support for expiration.
 *
 *      @ingroup NimbusCore
 *      @defgroup In-Memory-Caches In-Memory Caches
 *      @{
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
 * @name Creating an In-Memory Cache
 * @{
 */
#pragma mark Creating an In-Memory Cache

/**
 * Initialize the cache with zero initial capacity.
 */
- (id)init;

/**
 * Designated initializer. Initialize the cache with an initial capacity.
 *
 * Use a best guess to avoid having the internal data structure reallocate its memory repeatedly
 * - at least up up to a certain point - as the cache grows.
 */
- (id)initWithCapacity:(NSUInteger)capacity;

/**@}*/// End of Creating an In-Memory Cache


/**
 * @name Storing Objects in the Cache
 * @{
 */
#pragma mark Storing Objects in the Cache

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

/**@}*/// End of Storing Objects in the Cache


/**
 * @name Removing Objects from the Cache
 * @{
 */
#pragma mark Removing Objects from the Cache

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

/**@}*/// End of Storing Objects in the Cache


/**
 * @name Accessing Objects in the Cache
 * @{
 */
#pragma mark Accessing Objects in the Cache

/**
 * Retrieve an object from the cache.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 */
- (id)objectWithName:(NSString *)name;

/**
 * Determine whether an object is in the cache or not without modifying the access time.
 *
 * This is useful if you simply want to check the cache for the existence of an object.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 */
- (BOOL)hasObjectWithName:(NSString *)name;

/**
 * Retrieve the data that the object with the given name was last accessed.
 *
 * This will not update the access time of the object.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 */
- (NSDate *)dateOfLastAccessWithName:(NSString *)name;

/**
 * Retrieve the key with the most stale access.
 *
 * This will not update the access time of the object.
 *
 * If there's no object matching that criteria, return nil;
 */

- (NSString*) valueWithOldestAccess;

/**
 * Retrieve the key with the most fresh access.
 *
 * This will not update the access time of the object.
 *
 * If there's no object matching that criteria, return nil;
 */

- (NSString*) valueWithLastAccess;


/**@}*/// End of Accessing Objects in the Cache


/**
 * @name Reducing Memory Usage Explicitly
 * @{
 */
#pragma mark Reducing Memory Usage Explicitly

/**
 * Remove all expired objects from the cache.
 *
 * Subclasses may add additional functionality to this implementation and should generally
 * call super.
 *
 * This will be called when UIApplicationDidReceiveMemoryWarningNotification is posted.
 */
- (void)reduceMemoryUsage;

/**@}*/// End of Reducing Memory Usage Explicitly


/**
 * @name Querying an In-Memory Cache
 * @{
 */
#pragma mark Querying an In-Memory Cache

/**
 * The number of objects stored in this cache.
 */
@property (nonatomic, readonly) NSUInteger count;

/**@}*/// End of Querying an In-Memory Cache


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
 * An object has been stored in the cache.
 *
 *      @param object          The object that was stored in the cache.
 *      @param name            The cache name for the object.
 */
- (void)didSetObject:(id)object withName:(NSString *)name;

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
 * An in-memory cache for storing images with caps on the total number of pixels.
 *
 * When reduceMemoryUsage is called, the least recently used images are removed from the cache
 * until the numberOfPixels is below maxNumberOfPixelsUnderStress.
 *
 * When an image is added to the cache that causes the memory usage to pass the max, the
 * least recently used images are removed from the cache until the numberOfPixels is below
 * maxNumberOfPixels.
 *
 * By default the image memory cache has no limit to its pixel count. You must explicitly
 * set this value in your application.
 *
 *      @attention If the cache is too small to fit the newly added image, then all images
 *                 will end up being removed including the one being added.
 *
 *      @see Nimbus::imageMemoryCache
 *      @see Nimbus::setImageMemoryCache:
 */
@interface NIImageMemoryCache : NIMemoryCache {
@private
  NSUInteger _numberOfPixels;

  NSUInteger _maxNumberOfPixels;
  NSUInteger _maxNumberOfPixelsUnderStress;
}


/**
 * @name Querying an In-Memory Image Cache
 * @{
 */
#pragma mark Querying an In-Memory Image Cache

/**
 * The total number of pixels being stored in the cache.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfPixels;

/**@}*/// End of Querying an In-Memory Image Cache


/**
 * @name Setting the Maximum Number of Pixels
 * @{
 */
#pragma mark Setting the Maximum Number of Pixels

/**
 * The maximum number of pixels this cache may ever store.
 *
 * Defaults to 0, which is special cased to represent an unlimited number of pixels.
 */
@property (nonatomic, readwrite, assign) NSUInteger maxNumberOfPixels;

/**
 * The maximum number of pixels this cache may store after a call to reduceMemoryUsage.
 *
 * Defaults to 0, which is special cased to represent an unlimited number of pixels.
 */
@property (nonatomic, readwrite, assign) NSUInteger maxNumberOfPixelsUnderStress;

/**@}*/// End of Setting the Maximum Number of Pixels

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of In-Memory Cache //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
