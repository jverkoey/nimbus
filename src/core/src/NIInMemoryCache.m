//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "NIInMemoryCache.h"

#import "NIDebuggingTools.h"
#import "NIPreprocessorMacros.h"

#import <UIKit/UIKit.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIMemoryCache()
// Mapping from a name (usually a URL) to an internal object.
@property (nonatomic, strong) NSMutableDictionary* cacheMap;
// A linked list of least recently used cache objects. Most recently used is the tail.
@property (nonatomic, strong) NSMutableOrderedSet* lruCacheObjects;
@end

/**
 * @brief A single cache item's information.
 *
 * Used in expiration calculations and for storing the actual cache object.
 */
@interface NIMemoryCacheInfo : NSObject

/**
 * @brief The name used to store this object in the cache.
 */
@property (nonatomic, copy) NSString* name;

/**
 * @brief The object stored in the cache.
 */
@property (nonatomic, strong) id object;

/**
 * @brief The date after which the image is no longer valid and should be removed from the cache.
 */
@property (nonatomic, strong) NSDate* expirationDate;

/**
 * @brief The last time this image was accessed.
 *
 * This property is updated every time the image is fetched from or stored into the cache. It
 * is used when the memory peak has been reached as a fast means of removing least-recently-used
 * images. When the memory limit is reached, we sort the cache based on the last access times and
 * then prune images until we're under the memory limit again.
 */
@property (nonatomic, strong) NSDate* lastAccessTime;

/**
 * @brief Determine whether this cache entry has past its expiration date.
 *
 * @returns YES if an expiration date has been specified and the expiration date has been passed.
 *          NO in all other cases. Notably if there is no expiration date then this object will
 *          never expire.
 */
- (BOOL)hasExpired;

@end

@implementation NIMemoryCache

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
  return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity {
  if ((self = [super init])) {
    _cacheMap = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    _lruCacheObjects = [[NSMutableOrderedSet alloc] init];

    // Automatically reduce memory usage when we get a memory warning.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reduceMemoryUsage)
                                                 name: UIApplicationDidReceiveMemoryWarningNotification
                                               object: nil];
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:
          @"<%@"
          @" lruObjects: %@"
          @" cache map: %@"
          @">",
          [super description],
          self.lruCacheObjects,
          self.cacheMap];
}

#pragma mark - Internal Methods

- (void)updateAccessTimeForInfo:(NIMemoryCacheInfo *)info {
  @synchronized(self) {
    NIDASSERT(nil != info);
    if (nil == info) {
      return; // COV_NF_LINE
    }
    info.lastAccessTime = [NSDate date];

    [self.lruCacheObjects removeObject:info];
    [self.lruCacheObjects addObject:info];
  }
}

- (NIMemoryCacheInfo *)cacheInfoForName:(NSString *)name {
  NIMemoryCacheInfo* info;
  @synchronized(self) {
    info = [self.cacheMap objectForKey:name];
  }
  return info;
}

- (void)setCacheInfo:(NIMemoryCacheInfo *)info forName:(NSString *)name {
  @synchronized(self) {
    NIDASSERT(nil != name);
    if (nil == name) {
      return;
    }

    // Storing in the cache counts as an access of the object, so we update the access time.
    [self updateAccessTimeForInfo:info];

    if ([self shouldSetObject:info.object
                     withName:name
               previousObject:[self cacheInfoForName:name].object]) {
      [self.cacheMap setObject:info forKey:name];

      [self didSetObject:info.object
                withName:name];
    }
  }
}

- (void)removeCacheInfoForName:(NSString *)name {
  @synchronized(self) {
    NIDASSERT(nil != name);
    if (nil == name) {
      return;
    }

    NIMemoryCacheInfo* cacheInfo = [self cacheInfoForName:name];
    [self willRemoveObject:cacheInfo.object withName:name];

    [self.lruCacheObjects removeObject:cacheInfo];
    [self.cacheMap removeObjectForKey:name];
  }
}

#pragma mark - Subclassing

// Deprecated method.
- (BOOL)willSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject {
  return [self shouldSetObject:object withName:name previousObject:previousObject];
}

- (BOOL)shouldSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject {
  // Allow anything to be stored.
  return YES;
}

- (void)didSetObject:(id)object withName:(NSString *)name {
  // No-op
}

- (void)willRemoveObject:(id)object withName:(NSString *)name {
  // No-op
}

#pragma mark - Public


- (void)storeObject:(id)object withName:(NSString *)name {
  @synchronized(self) {
    [self storeObject:object withName:name expiresAfter:nil];
  }
}

- (void)storeObject:(id)object withName:(NSString *)name expiresAfter:(NSDate *)expirationDate {
  @synchronized(self) {
    // Don't store nil objects in the cache.
    if (nil == object) {
      return;
    }

    if (nil != expirationDate && [[NSDate date] timeIntervalSinceDate:expirationDate] >= 0) {
      // The object being stored is already expired so remove the object from the cache altogether.
      [self removeObjectWithName:name];

      // We're done here.
      return;
    }
    NIMemoryCacheInfo* info = [self cacheInfoForName:name];

    // Create a new cache entry.
    if (nil == info) {
      info = [[NIMemoryCacheInfo alloc] init];
      info.name = name;
    }

    // Store the object in the cache item.
    info.object = object;

    // Override any existing expiration date.
    info.expirationDate = expirationDate;

    // Commit the changes to the cache.
    [self setCacheInfo:info forName:name];
  }
}

- (id)objectWithName:(NSString *)name {
  id object = nil;

  @synchronized(self) {
    NIMemoryCacheInfo* info = [self cacheInfoForName:name];

    if (nil != info) {
      if ([info hasExpired]) {
        [self removeObjectWithName:name];

      } else {
        // Update the access time whenever we fetch an object from the cache.
        [self updateAccessTimeForInfo:info];

        object = info.object;
      }
    }
  }

  return object;
}

- (BOOL)containsObjectWithName:(NSString *)name {
  @synchronized(self) {
    NIMemoryCacheInfo* info = [self cacheInfoForName:name];

    if ([info hasExpired]) {
      [self removeObjectWithName:name];
      return NO;
    }

    return (nil != info);
  }
}

- (NSDate *)dateOfLastAccessWithName:(NSString *)name {
  @synchronized(self) {
    NIMemoryCacheInfo* info = [self cacheInfoForName:name];

    if ([info hasExpired]) {
      [self removeObjectWithName:name];
      return nil;
    }

    return [info lastAccessTime];
  }
}

- (NSString *)nameOfLeastRecentlyUsedObject {
  @synchronized(self) {
    NIMemoryCacheInfo* info = [self.lruCacheObjects firstObject];

    if ([info hasExpired]) {
      [self removeObjectWithName:info.name];
      return nil;
    }

    return info.name;
  }
}

- (NSString *)nameOfMostRecentlyUsedObject {
  @synchronized(self) {
    NIMemoryCacheInfo* info = [self.lruCacheObjects lastObject];

    if ([info hasExpired]) {
      [self removeObjectWithName:info.name];
      return nil;
    }

    return info.name;
  }
}

- (void)removeObjectWithName:(NSString *)name {
  @synchronized(self) {
    [self removeCacheInfoForName:name];
  }
}

- (void)removeAllObjectsWithPrefix:(NSString *)prefix {
  @synchronized(self) {
    for (NSString* key in [self.cacheMap copy]) {
      if ([key hasPrefix:prefix]) {
        [self removeObjectWithName:key];
      }
    }
  }
}

- (void)removeAllObjects {
  @synchronized(self) {
    self.cacheMap = [[NSMutableDictionary alloc] init];
    self.lruCacheObjects = [[NSMutableOrderedSet alloc] init];
  }
}

- (void)reduceMemoryUsage {
  @synchronized(self) {
    // Copy the cache map because it's likely that we're going to modify it.
    NSDictionary* cacheMap = [self.cacheMap copy];

    // Iterate over the copied cache map (which will not be modified).
    for (id name in cacheMap) {
      NIMemoryCacheInfo* info = [self cacheInfoForName:name];

      if ([info hasExpired]) {
        [self removeCacheInfoForName:name];
      }
    }
    cacheMap = nil;
  }
}

- (NSUInteger)count {
  @synchronized(self) {
    return [self.cacheMap count];
  }
}

@end


@implementation NIMemoryCacheInfo

- (BOOL)hasExpired {
  return (nil != _expirationDate
          && [[NSDate date] timeIntervalSinceDate:_expirationDate] >= 0);
}

- (NSString *)description {
  return [NSString stringWithFormat:
          @"<%@"
          @" name: %@"
          @" object: %@"
          @" expiration date: %@"
          @" last access time: %@"
          @">",
          [super description],
          self.name,
          self.object,
          self.expirationDate,
          self.lastAccessTime];
}

@end

@interface NIImageMemoryCache()
@property (nonatomic, assign) NSUInteger numberOfPixels;
@end

@implementation NIImageMemoryCache

- (NSUInteger)numberOfPixelsUsedByImage:(UIImage *)image {
  @synchronized(self) {
    if (nil == image) {
      return 0;
    }

    NSUInteger numberOfPixels = (NSUInteger)(image.size.width * image.size.height);
    if ([image respondsToSelector:@selector(scale)]) {
      numberOfPixels *= [image scale];
    }
    return numberOfPixels;
  }
}

- (void)removeAllObjects {
  @synchronized(self) {
    [super removeAllObjects];

    self.numberOfPixels = 0;
  }
}

- (void)reduceMemoryUsage {
  @synchronized(self) {
    // Remove all expired images first.
    [super reduceMemoryUsage];

    if (self.maxNumberOfPixelsUnderStress > 0) {
      // Remove the least recently used images by iterating over the linked list.
      while (self.numberOfPixels > self.maxNumberOfPixelsUnderStress) {
        NIMemoryCacheInfo* info = [self.lruCacheObjects firstObject];
        [self removeCacheInfoForName:info.name];
      }
    }
  }
}

- (BOOL)shouldSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject {
  @synchronized(self) {
    NIDASSERT(nil == object || [object isKindOfClass:[UIImage class]]);
    if (![object isKindOfClass:[UIImage class]]) {
      return NO;
    }

    self.numberOfPixels -= [self numberOfPixelsUsedByImage:previousObject];
    self.numberOfPixels += [self numberOfPixelsUsedByImage:object];

    return YES;
  }
}

- (void)didSetObject:(id)object withName:(NSString *)name {
  @synchronized(self) {
    // Reduce the cache size after the object has been set in case the cache size is smaller
    // than the object that's being added and we need to remove this object right away. If we
    // try to reduce the cache size before the object's been set, we won't have anything to remove
    // and we'll get stuck in an infinite loop.
    if (self.maxNumberOfPixels > 0) {
      // Remove least recently used images until we satisfy our memory constraints.
      while (self.numberOfPixels > self.maxNumberOfPixels
             && [self.lruCacheObjects count] > 0) {
        NIMemoryCacheInfo* info = [self.lruCacheObjects firstObject];
        [self removeCacheInfoForName:info.name];
      }
    }
  }
}

- (void)willRemoveObject:(id)object withName:(NSString *)name {
  @synchronized(self) {
    NIDASSERT(nil == object || [object isKindOfClass:[UIImage class]]);
    if (nil == object || ![object isKindOfClass:[UIImage class]]) {
      return; // COV_NF_LINE
    }

    self.numberOfPixels -= [self numberOfPixelsUsedByImage:object];
  }
}

@end

