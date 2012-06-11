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

#import "NIInMemoryCache.h"

#import "NIDataStructures.h"
#import "NIDebuggingTools.h"
#import "NIPreprocessorMacros.h"

#import <UIKit/UIKit.h>

@interface NIMemoryCache()
// Mapping from a name (usually a URL) to an internal object.
@property (nonatomic, readwrite, retain) NSMutableDictionary* cacheMap;
// A linked list of least recently used cache objects. Most recently used is the tail.
@property (nonatomic, readwrite, retain) NILinkedList* lruCacheObjects;
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
@property (nonatomic, readwrite, copy) NSString* name;

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
 * @brief The location of this object in the least-recently used linked list.
 */
@property (nonatomic, readwrite, assign) NILinkedListLocation* lruLocation;

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

@synthesize cacheMap        = _cacheMap;
@synthesize lruCacheObjects = _lruCacheObjects;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  NI_RELEASE_SAFELY(_cacheMap);
  NI_RELEASE_SAFELY(_lruCacheObjects);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithCapacity:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCapacity:(NSUInteger)capacity {
  if ((self = [super init])) {
    _cacheMap = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    _lruCacheObjects = [[NILinkedList alloc] init];

    // Automatically reduce memory usage when we get a memory warning.
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reduceMemoryUsage)
                                                 name: UIApplicationDidReceiveMemoryWarningNotification
                                               object: nil];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Internal Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateAccessTimeForInfo:(NIMemoryCacheInfo *)info {
  NIDASSERT(nil != info);
  if (nil == info) {
    return; // COV_NF_LINE
  }
  info.lastAccessTime = [NSDate date];

  [self.lruCacheObjects removeObjectAtLocation:info.lruLocation];
  info.lruLocation = [self.lruCacheObjects addObject:info];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIMemoryCacheInfo *)cacheInfoForName:(NSString *)name {
  return [self.cacheMap objectForKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCacheInfo:(NIMemoryCacheInfo *)info forName:(NSString *)name {
  NIDASSERT(nil != name);
  if (nil == name) {
    return;
  }

  // Storing in the cache counts as an access of the object, so we update the access time.
  [self updateAccessTimeForInfo:info];

  if ([self willSetObject:info.object
                 withName:name
           previousObject:[self cacheInfoForName:name].object]) {
    [self.cacheMap setObject:info forKey:name];

    [self didSetObject:info.object
              withName:name];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeCacheInfoForName:(NSString *)name {
  NIDASSERT(nil != name);
  if (nil == name) {
    return;
  }

  [self willRemoveObject:[self cacheInfoForName:name].object withName:name];

  [self.cacheMap removeObjectForKey:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Subclassing


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject {
  // Allow anything to be stored.
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSetObject:(id)object withName:(NSString *)name {
  // No-op
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRemoveObject:(id)object withName:(NSString *)name {
  // No-op
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)storeObject:(id)object withName:(NSString *)name {
  [self storeObject:object withName:name expiresAfter:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)storeObject:(id)object withName:(NSString *)name expiresAfter:(NSDate *)expirationDate {
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
    info = [[[NIMemoryCacheInfo alloc] init] autorelease];
    info.name = name;
  }

  // Store the object in the cache item.
  info.object = object;

  // Override any existing expiration date.
  info.expirationDate = expirationDate;

  // Commit the changes to the cache.
  [self setCacheInfo:info forName:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectWithName:(NSString *)name {
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  id object = nil;

  if (nil != info) {
    if ([info hasExpired]) {
      [self removeObjectWithName:name];

    } else {
      // Update the access time whenever we fetch an object from the cache.
      [self updateAccessTimeForInfo:info];

      object = info.object;
    }
  }

  return [[object retain] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)containsObjectWithName:(NSString *)name {
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  if ([info hasExpired]) {
    [self removeObjectWithName:name];
    return NO;
  }

  return (nil != info);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateOfLastAccessWithName:(NSString *)name {
  NIMemoryCacheInfo* info = [self cacheInfoForName:name];

  if ([info hasExpired]) {
    [self removeObjectWithName:name];
    return nil;
  }

  return [info lastAccessTime];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)nameOfLeastRecentlyUsedObject {
  NIMemoryCacheInfo* info = [self.lruCacheObjects firstObject];

  if ([info hasExpired]) {
    [self removeObjectWithName:info.name];
    return nil;
  }

  return info.name;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)nameOfMostRecentlyUsedObject {
  NIMemoryCacheInfo* info = [self.lruCacheObjects lastObject];

  if ([info hasExpired]) {
    [self removeObjectWithName:info.name];
    return nil;
  }

  return info.name;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeObjectWithName:(NSString *)name {
  [self removeCacheInfoForName:name];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllObjects {
  self.cacheMap = [[[NSMutableDictionary alloc] init] autorelease];
  self.lruCacheObjects = [[[NILinkedList alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reduceMemoryUsage {
  // Copy the cache map because it's likely that we're going to modify it.
  NSDictionary* cacheMap = [self.cacheMap copy];

  // Iterate over the copied cache map (which will not be modified).
  for (id name in cacheMap) {
    NIMemoryCacheInfo* info = [self cacheInfoForName:name];

    if ([info hasExpired]) {
      [self removeCacheInfoForName:name];
    }
  }
  NI_RELEASE_SAFELY(cacheMap);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)count {
  return [self.cacheMap count];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMemoryCacheInfo

@synthesize name            = _name;
@synthesize object          = _object;
@synthesize expirationDate  = _expirationDate;
@synthesize lastAccessTime  = _lastAccessTime;
@synthesize lruLocation     = _lruLocation;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_name);
  NI_RELEASE_SAFELY(_object);
  NI_RELEASE_SAFELY(_expirationDate);
  NI_RELEASE_SAFELY(_lastAccessTime);
  _lruLocation = nil;

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasExpired {
  return (nil != _expirationDate
          && [[NSDate date] timeIntervalSinceDate:_expirationDate] >= 0);
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIImageMemoryCache()
@property (nonatomic, readwrite, assign) NSUInteger numberOfPixels;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIImageMemoryCache

@synthesize numberOfPixels                = _numberOfPixels;
@synthesize maxNumberOfPixels             = _maxNumberOfPixels;
@synthesize maxNumberOfPixelsUnderStress  = _maxNumberOfPixelsUnderStress;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)numberOfPixelsUsedByImage:(UIImage *)image {
  if (nil == image) {
    return 0;
  }

  NSUInteger numberOfPixels = (NSUInteger)(image.size.width * image.size.height);
  if ([image respondsToSelector:@selector(scale)]) {
    numberOfPixels *= [image scale];
  }
  return numberOfPixels;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllObjects {
  [super removeAllObjects];

  self.numberOfPixels = 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reduceMemoryUsage {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willSetObject:(id)object withName:(NSString *)name previousObject:(id)previousObject {
  NIDASSERT(nil == object || [object isKindOfClass:[UIImage class]]);
  if (![object isKindOfClass:[UIImage class]]) {
    return NO;
  }

  self.numberOfPixels -= [self numberOfPixelsUsedByImage:previousObject];
  self.numberOfPixels += [self numberOfPixelsUsedByImage:object];

  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSetObject:(id)object withName:(NSString *)name {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRemoveObject:(id)object withName:(NSString *)name {
  NIDASSERT(nil == object || [object isKindOfClass:[UIImage class]]);
  if (nil == object || ![object isKindOfClass:[UIImage class]]) {
    return; // COV_NF_LINE
  }

  NIMemoryCacheInfo* info = [self cacheInfoForName:name];
  [self.lruCacheObjects removeObjectAtLocation:info.lruLocation];

  self.numberOfPixels -= [self numberOfPixelsUsedByImage:object];
}


@end

