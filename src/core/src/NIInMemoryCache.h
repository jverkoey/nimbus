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

#import "NIPreprocessorMacros.h"

/**
 * For storing and accessing objects in memory.
 *
 * The base class, NIMemoryCache, is a generic object store that may be used for anything that
 * requires support for expiration.
 *
 * @ingroup NimbusCore
 * @defgroup In-Memory-Caches In-Memory Caches
 * @{
 */

/**
 * An in-memory cache for storing objects with expiration support.
 *
 * The Nimbus in-memory object cache allows you to store objects in memory with an expiration
 * date attached. Objects with expiration dates drop out of the cache when they have expired.
 */
@interface NIMemoryCache : NSObject

// Designated initializer.
- (id)initWithCapacity:(NSUInteger)capacity;

- (NSUInteger)count;

- (void)storeObject:(id)object withName:(NSString *)name;
- (void)storeObject:(id)object withName:(NSString *)name expiresAfter:(NSDate *)expirationDate;

- (void)removeObjectWithName:(NSString *)name;
- (void)removeAllObjectsWithPrefix:(NSString *)prefix;
- (void)removeAllObjects;

- (id)objectWithName:(NSString *)name;
- (BOOL)containsObjectWithName:(NSString *)name;
- (NSDate *)dateOfLastAccessWithName:(NSString *)name;

- (NSString *)nameOfLeastRecentlyUsedObject;
- (NSString *)nameOfMostRecentlyUsedObject;

- (void)reduceMemoryUsage;

// Subclassing

- (BOOL)shouldSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject;
- (void)didSetObject:(id)object withName:(NSString *)name;
- (void)willRemoveObject:(id)object withName:(NSString *)name;

// Deprecated method. Use shouldSetObject:withName:previousObject: instead.
- (BOOL)willSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject __NI_DEPRECATED_METHOD;

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
 * @attention If the cache is too small to fit the newly added image, then all images
 *                 will end up being removed including the one being added.
 *
 * @see Nimbus::imageMemoryCache
 * @see Nimbus::setImageMemoryCache:
 */
@interface NIImageMemoryCache : NIMemoryCache

@property (nonatomic, readonly) unsigned long long numberOfPixels;

@property (nonatomic)           unsigned long long maxNumberOfPixels;             // Default: 0 (unlimited)
@property (nonatomic)           unsigned long long maxNumberOfPixelsUnderStress;  // Default: 0 (unlimited)

@end

/**@}*/// End of In-Memory Cache //////////////////////////////////////////////////////////////////

/** @name Creating an In-Memory Cache */

/**
 * Initializes a newly allocated cache with the given capacity.
 *
 * @returns An in-memory cache initialized with the given capacity.
 * @fn NIMemoryCache::initWithCapacity:
 */

/** @name Storing Objects in the Cache */

/**
 * Stores an object in the cache.
 *
 * The object will be stored without an expiration date. The object will stay in the cache until
 * it's bumped out due to the cache's memory limit.
 *
 * @param object  The object being stored in the cache.
 * @param name    The name used as a key to store this object.
 * @fn NIMemoryCache::storeObject:withName:
 */

/**
 * Stores an object in the cache with an expiration date.
 *
 * If an object is stored with an expiration date that has already passed then the object will
 * not be stored in the cache and any existing object will be removed. The rationale behind this
 * is that the object would be removed from the cache the next time it was accessed anyway.
 *
 * @param object          The object being stored in the cache.
 * @param name            The name used as a key to store this object.
 * @param expirationDate  A date after which this object is no longer valid in the cache.
 * @fn NIMemoryCache::storeObject:withName:expiresAfter:
 */

/** @name Removing Objects from the Cache */

/**
 * Removes an object from the cache with the given name.
 *
 * @param name The name used as a key to store this object.
 * @fn NIMemoryCache::removeObjectWithName:
 */

/**
 * Removes all objects from the cache with a given prefix.
 *
 * This method requires a scan of the cache entries.
 *
 * @param prefix Any object name that has this prefix will be removed from the cache.
 * @fn NIMemoryCache::removeAllObjectsWithPrefix:
 */

/**
 * Removes all objects from the cache, regardless of expiration dates.
 *
 * This will completely clear out the cache and all objects in the cache will be released.
 *
 * @fn NIMemoryCache::removeAllObjects
 */

/** @name Accessing Objects in the Cache */

/**
 * Retrieves an object from the cache.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 *
 * @returns The object stored in the cache. The object is retained and autoreleased to
 *               ensure that it survives this run loop if you then remove it from the cache.
 * @fn NIMemoryCache::objectWithName:
 */

/**
 * Returns a Boolean value that indicates whether an object with the given name is present
 * in the cache.
 *
 * Does not update the access time of the object.
 *
 * If the object has expired then the object will be removed from the cache and NO will be
 * returned.
 *
 * @returns YES if an object with the given name is present in the cache and has not expired,
 *               otherwise NO.
 * @fn NIMemoryCache::containsObjectWithName:
 */

/**
 * Returns the date that the object with the given name was last accessed.
 *
 * Does not update the access time of the object.
 *
 * If the object has expired then the object will be removed from the cache and nil will be
 * returned.
 *
 * @returns The last access date of the object if it exists and has not expired, nil
 *               otherwise.
 * @fn NIMemoryCache::dateOfLastAccessWithName:
 */

/**
 * Retrieve the name of the object that was least recently used.
 *
 * This will not update the access time of the object.
 *
 * If the cache is empty, returns nil.
 *
 * @fn NIMemoryCache::nameOfLeastRecentlyUsedObject
 */

/**
 * Retrieve the key with the most fresh access.
 *
 * This will not update the access time of the object.
 *
 * If the cache is empty, returns nil.
 *
 * @fn NIMemoryCache::nameOfMostRecentlyUsedObject
 */

/** @name Reducing Memory Usage Explicitly */

/**
 * Removes all expired objects from the cache.
 *
 * Subclasses may add additional functionality to this implementation.
 * Subclasses should call super in order to prune expired objects.
 *
 * This will be called when <code>UIApplicationDidReceiveMemoryWarningNotification</code>
 * is posted.
 *
 * @fn NIMemoryCache::reduceMemoryUsage
 */

/** @name Querying an In-Memory Cache */

/**
 * Returns the number of objects currently in the cache.
 *
 * @returns The number of objects currently in the cache.
 * @fn NIMemoryCache::count
 */

/**
 * @name Subclassing
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */

/**
 * An object is about to be stored in the cache.
 *
 * @param object          The object that is about to be stored in the cache.
 * @param name            The cache name for the object.
 * @param previousObject  The object previously stored in the cache. This may be the
 *                             same as object.
 * @returns YES If object is allowed to be stored in the cache.
 * @fn NIMemoryCache::shouldSetObject:withName:previousObject:
 */

/**
 * This method is deprecated. Please use shouldSetObject:withName:previousObject: instead.
 *
 * @fn NIMemoryCache::willSetObject:withName:previousObject:
 */

/**
 * An object has been stored in the cache.
 *
 * @param object          The object that was stored in the cache.
 * @param name            The cache name for the object.
 * @fn NIMemoryCache::didSetObject:withName:
 */

/**
 * An object is about to be removed from the cache.
 *
 * @param object  The object about to removed from the cache.
 * @param name    The cache name for the object about to be removed.
 * @fn NIMemoryCache::willRemoveObject:withName:
 */

// NIImageMemoryCache

/** @name Querying an In-Memory Image Cache */

/**
 * Returns the total number of pixels being stored in the cache.
 *
 * @returns The total number of pixels being stored in the cache.
 * @fn NIImageMemoryCache::numberOfPixels
 */

/** @name Setting the Maximum Number of Pixels */

/**
 * The maximum number of pixels this cache may ever store.
 *
 * Defaults to 0, which is special cased to represent an unlimited number of pixels.
 *
 * @returns The maximum number of pixels this cache may ever store.
 * @fn NIImageMemoryCache::maxNumberOfPixels
 */

/**
 * The maximum number of pixels this cache may store after a call to reduceMemoryUsage.
 *
 * Defaults to 0, which is special cased to represent an unlimited number of pixels.
 *
 * @returns The maximum number of pixels this cache may store after a call
 *               to reduceMemoryUsage.
 * @fn NIImageMemoryCache::maxNumberOfPixelsUnderStress
 */
