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

#import "NimbusCore.h"

/**
 * @brief A single cache item's information.
 *
 * Used in expiration calculations and for storing the actual cache object.
 */
@interface NIMemoryCacheInfo : NSObject {
@private
  id      _object;
  NSDate* _expirationDate;
  NSDate* _lastAccessTime;
}

/**
 * @brief The object stored in the cache.
 */
@property (nonatomic, readwrite, retain) id object;

/**
 * @brief The date after which the image is no longer valid and should be removed from the cache.
 */
@property (nonatomic, readwrite, retain) NSDate* expirationDate;

/**
 * @brief The last time this image was accessed.
 *
 * This property is updated every time the image is fetched from or stored into the cache. It
 * is used when the memory peak has been reached as a fast means of removing least-recently-used
 * images. When the memory limit is reached, we sort the cache based on the last access times and
 * then prune images until we're under the memory limit again.
 */
@property (nonatomic, readwrite, retain) NSDate* lastAccessTime;

/**
 * @brief Determine whether this cache entry has past its expiration date.
 *
 * @returns YES if an expiration date has been specified and the expiration date has been passed.
 *          NO in all other cases. Notably if there is no expiration date then this object will
 *          never expire.
 */
- (BOOL)hasExpired;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMemoryCache


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithCapacity:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCapacity:(NSUInteger)capacity {
  if ((self = [super init])) {
    _cacheMap = [[NSMutableDictionary alloc] initWithCapacity:capacity];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Internal Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIMemoryCacheInfo *)cacheInfoForName:(NSString *)name {
  return [_cacheMap objectForKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCacheInfo:(NIMemoryCacheInfo *)info forName:(NSString *)name {
  [_cacheMap setObject:info forKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeCacheInfoForName:(NSString *)name {
  [_cacheMap removeObjectForKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)storeObject:(id)object withName:(NSString *)name {
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  // Create a new cache entry.
  if (nil == info) {
    info = [[NIMemoryCacheInfo alloc] init];
  }

  // Store the object in the cache item.
  info.object = object;

  // Storing in the cache counts as an access of the object, so we update the access time.
  info.lastAccessTime = [NSDate date];

  // Clear out any expiration date that may exist so that this item won't expire.
  info.expirationDate = nil;

  // Commit the changes to the cache.
  [self setCacheInfo:info forName:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)storeObject:(id)object withName:(NSString *)name expiresAfter:(NSDate *)expirationDate {
  if ([[NSDate date] timeIntervalSinceDate:expirationDate] >= 0) {
    // The object being stored is already expired so remove the object from the cache altogether.
    [self removeObjectWithName:name];

    // We're done here.
    return;
  }
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  // Create a new cache entry.
  if (nil == info) {
    info = [[NIMemoryCacheInfo alloc] init];
  }

  // Store the object in the cache item.
  info.object = object;

  // Storing in the cache counts as an access of the object, so we update the access time.
  info.lastAccessTime = [NSDate date];

  // Override any existing expiration date so that the cache item will expire.
  info.expirationDate = expirationDate;

  // Commit the changes to the cache.
  [self setCacheInfo:info forName:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectWithName:(NSString *)name {
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  if ([info hasExpired]) {
    [self removeObjectWithName:name];
    info = nil;

    return nil;
  }

  return info.object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeObjectWithName:(NSString *)name {
  [self removeCacheInfoForName:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllObjects {
  NI_RELEASE_SAFELY(_cacheMap);
  _cacheMap = [[NSMutableDictionary alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reduceMemoryUsage {
  // Copy the cache map because it's likely that we're going to modify it.
  NSDictionary* cacheMap = [_cacheMap copy];

  // Iterate over the copied cache map (which will not be modified).
  for (id key in cacheMap) {
    NIMemoryCacheInfo* info = [_cacheMap objectForKey:key];

    if ([info hasExpired]) {
      [_cacheMap removeObjectForKey:key];
    }
  }
  NI_RELEASE_SAFELY(cacheMap);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)count {
  return [_cacheMap count];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMemoryCacheInfo

@synthesize object          = _object;
@synthesize expirationDate  = _expirationDate;
@synthesize lastAccessTime  = _lastAccessTime;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_object);
  NI_RELEASE_SAFELY(_expirationDate);
  NI_RELEASE_SAFELY(_lastAccessTime);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasExpired {
  return (nil != _expirationDate
          && [[NSDate date] timeIntervalSinceDate:_expirationDate] >= 0);
}


@end

