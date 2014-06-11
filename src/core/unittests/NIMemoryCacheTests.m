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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <XCTest/XCTest.h>

#import <UIKit/UIKit.h>

#import "NIDebuggingTools.h"
#import "NIInMemoryCache.h"
#import "NSDate+UnitTesting.h"

@interface NIMemoryCacheTests : XCTestCase {
}

@end

@implementation NIMemoryCacheTests


#pragma mark - In-Memory Cache


- (void)testInitialization {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty after initialization.");
}

- (void)testSingleObjectNoExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object in it.");
  XCTAssertEqual([cache objectWithName:@"obj1"], cacheObject1, @"Cache object should be equal.");
}

- (void)testMultipleObjectsNoExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2 withName: @"obj2"];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
  XCTAssertEqual([cache objectWithName:@"obj1"], cacheObject1, @"Cache object should be equal.");
  XCTAssertEqual([cache objectWithName:@"obj2"], cacheObject2, @"Cache object should be equal.");
}

- (void)testRemovingSingleObject {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  [cache removeObjectWithName:@"obj1"];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");
}

- (void)testRemovingCachePrefixes {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];
  id cacheObject1Prefix = [NSArray array];
  [cache storeObject:cacheObject1Prefix withName:@"obj1_details"];
  id cacheObject2 = [NSArray array];
  [cache storeObject:cacheObject2 withName:@"obj2"];

  [cache removeAllObjectsWithPrefix:@"obj1"];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");
}

- (void)testRemovingAllObjects {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  id cacheObject2 = [NSArray array];
  [cache storeObject:cacheObject2 withName:@"obj2"];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
  [cache removeAllObjects];
  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should now be empty.");
}

- (void)testSingleObjectWithFutureExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object in it.");
}

- (void)testMultipleObjectsWithFutureExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:100]];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects in it.");
}

- (void)testSingleObjectWithPastExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");
}

- (void)testMultipleObjectsWithPastExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  id cacheObject2 = [NSArray array];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-100]];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");
}

- (void)testSingleObjectWithExpiredUpdate {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"];

  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:-1]];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");
}

- (void)testSingleObjectWithNonExpiredUpdate {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"];

  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one item.");
}

- (void)testSingleObjectWithExpiration {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  XCTAssertNil([cache objectWithName:@"obj1"], @"Object should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

- (void)testAccessExpiredObjectWithContains {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1
            withName:@"obj1"
        expiresAfter:[NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  XCTAssertFalse([cache containsObjectWithName:@"obj1"], @"Object should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

- (void)testAccessExpiredObjectWithDate {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1
            withName:@"obj1"
        expiresAfter:[NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  XCTAssertNil([cache dateOfLastAccessWithName:@"obj1"], @"Object should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

- (void)testAccessExpiredObjectWithNameOfLeastRecentlyUsedObject {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1
            withName:@"obj1"
        expiresAfter:[NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  XCTAssertNil([cache nameOfLeastRecentlyUsedObject], @"Object should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

- (void)testAccessExpiredObjectWithNameOfMostRecentlyUsedObject {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1
            withName:@"obj1"
        expiresAfter:[NSDate dateWithTimeIntervalSinceNow:1]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");

  // Accessing an expired object removes it from the cache entirely.
  XCTAssertNil([cache nameOfMostRecentlyUsedObject], @"Object should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should be empty.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

- (void)testHasObject {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  XCTAssertTrue([cache containsObjectWithName:@"obj1"], @"obj1 should exist in the cache.");

  XCTAssertFalse([cache containsObjectWithName:@"obj2"], @"obj2 should not exist in the cache.");
}

- (void)testAccessTimeModifications {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject:cacheObject1 withName:@"obj1"];

  NSDate* lastAccessTime = [cache dateOfLastAccessWithName:@"obj1"];

  // Does not update the access time.
  [cache containsObjectWithName:@"obj1"];

  XCTAssertEqual(lastAccessTime, [cache dateOfLastAccessWithName:@"obj1"],
                 @"Access time should not have been modified.");

  // Does update the access time.
  [cache objectWithName:@"obj1"];

  XCTAssertFalse([lastAccessTime isEqualToDate:[cache dateOfLastAccessWithName:@"obj1"]],
                 @"Access time should have been modified.");
}

- (void)testLeastAndMostRecentlyUsedObjects {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  XCTAssertNil([cache nameOfLeastRecentlyUsedObject],
               @"There should not be a least-recently-used object.");
  XCTAssertNil([cache nameOfMostRecentlyUsedObject],
               @"There should not be a most-recently-used object.");

  id cacheObject1 = [NSArray array];
  id cacheObject2 = [NSDictionary dictionary];
  id cacheObject3 = [NSSet set];
  [cache storeObject:cacheObject1 withName:@"obj1"];
  [cache storeObject:cacheObject2 withName:@"obj2"];
  [cache storeObject:cacheObject3 withName:@"obj3"];

  XCTAssertEqual(@"obj1", [cache nameOfLeastRecentlyUsedObject],
                 @"The least recently used object should be object 1.");
  XCTAssertEqual(@"obj3", [cache nameOfMostRecentlyUsedObject],
                 @"The most recently used object should be object 3.");

  // Make object 1 the most-recently-accessed
  [cache objectWithName:@"obj1"];

  XCTAssertEqual(@"obj2", [cache nameOfLeastRecentlyUsedObject],
                 @"The least recently used object should be object 2.");
  XCTAssertEqual(@"obj1", [cache nameOfMostRecentlyUsedObject],
                 @"The most recently used object should be object 1.");
}

- (void)testReduceMemoryUsage {
  NIMemoryCache* cache = [[NIMemoryCache alloc] init];

  id cacheObject1 = [NSArray array];
  [cache storeObject: cacheObject1
            withName: @"obj1"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];

  id cacheObject2 = [NSDictionary dictionary];
  [cache storeObject: cacheObject2
            withName: @"obj2"
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:10]];

  [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];

  // This makes [NSDate date] call our fakeDate implementation, which allows us to fake the
  // current time so that we don't have to pause the tests while we wait for the object to
  // expire.
  [NSDate swizzleMethodsForUnitTesting];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects.");

  [cache reduceMemoryUsage];

  XCTAssertNil([cache objectWithName:@"obj1"], @"Object 1 should have expired.");

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object left.");

  XCTAssertNotNil([cache objectWithName:@"obj2"], @"Object 2 should still be around.");

  // Reset the class implementations when we're done with them.
  [NSDate swizzleMethodsForUnitTesting];
}

#pragma mark - Image In-Memory Cache


// Create an image of a given size. The contents are undefined.
- (UIImage *)emptyImageWithSize:(CGSize)size {
  UIGraphicsBeginImageContext(size);
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

- (void)testImageCacheStoreNonImage {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  NIDebugAssertionsShouldBreak = NO;
  [cache storeObject:[NSArray array] withName:@"obj1"];
  NIDebugAssertionsShouldBreak = YES;

  XCTAssertEqual(cache.count, (NSUInteger)0, @"Cache should be empty.");
}

- (void)testImageCacheNoLimit {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  [cache storeObject:img1 withName:@"obj1"];
  [cache storeObject:img2 withName:@"obj2"];

  XCTAssertEqual(cache.count, (NSUInteger)2, @"Cache should have two objects.");
  XCTAssertNotNil([cache objectWithName:@"obj1"], @"Image 1 should still be around.");
  XCTAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}

- (void)testImageCacheRemoveAllObjects {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  [cache storeObject:img1 withName:@"obj1"];
  [cache storeObject:img2 withName:@"obj2"];

  XCTAssertEqual(cache.count, (NSUInteger)2, @"Cache should have two objects in it.");
  [cache removeAllObjects];
  XCTAssertEqual(cache.count, (NSUInteger)0, @"Cache should now be empty.");
  XCTAssertEqual(cache.numberOfPixels, (unsigned long long)0, @"Cache should have zero pixels.");
}

- (void)testImageCacheNils {
  // Disable NIDASSERTs from breaking the program execution.
  NIDebugAssertionsShouldBreak = NO;
  
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  [cache storeObject: nil
            withName: @"obj1"];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: nil
            withName: nil];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: [NSDictionary dictionary]
            withName: nil];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: [NSDictionary dictionary]
            withName: nil
        expiresAfter: nil];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: [NSDictionary dictionary]
            withName: nil
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: nil
            withName: @"obj1"
        expiresAfter: nil];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: nil
            withName: nil
        expiresAfter: [NSDate dateWithTimeIntervalSinceNow:1]];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  [cache storeObject: nil
            withName: nil
        expiresAfter: nil];
  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");

  XCTAssertNil([cache objectWithName:nil], @"The result should be nil");
  [cache removeObjectWithName:nil];

  XCTAssertEqual([cache count], (NSUInteger)0, @"No objects should have been stored in the cache.");
  
  NIDebugAssertionsShouldBreak = YES;
}

- (void)testImageCacheStoreTooMuch {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  static const NSUInteger numberOfPixelsInOneImage = 100 * 100;
  cache.maxNumberOfPixels = numberOfPixelsInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  // This second image will push out the first image.
  [cache storeObject: img2
            withName: @"obj2"];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");
  XCTAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  XCTAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}

- (void)testImageCacheReduceMemoryUsage {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  static const NSUInteger numberOfPixelsInOneImage = 100 * 100;
  cache.maxNumberOfPixels = numberOfPixelsInOneImage * 2;
  cache.maxNumberOfPixelsUnderStress = numberOfPixelsInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image. The first image should be the one
  // removed.
  [cache reduceMemoryUsage];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");
  XCTAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  XCTAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}

- (void)testImageCacheReduceMemoryUsageWithAccess {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  static const NSUInteger numberOfPixelsInOneImage = 100 * 100;
  cache.maxNumberOfPixels = numberOfPixelsInOneImage * 2;
  cache.maxNumberOfPixelsUnderStress = numberOfPixelsInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  // Update the access time for img1.
  [cache objectWithName:@"obj1"];

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image.
  [cache reduceMemoryUsage];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");
  XCTAssertNotNil([cache objectWithName:@"obj1"], @"Image 1 should still be around.");
  XCTAssertNil([cache objectWithName:@"obj2"], @"Image 2 should not still be around.");
}

- (void)testImageCacheReduceMemoryUsageWithThrashingAccess {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  static const NSUInteger numberOfPixelsInOneImage = 100 * 100;
  cache.maxNumberOfPixels = numberOfPixelsInOneImage * 2;
  cache.maxNumberOfPixelsUnderStress = numberOfPixelsInOneImage;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  [cache storeObject: img2
            withName: @"obj2"];

  for (NSInteger ix = 0; ix < 10; ++ix) {
    [cache objectWithName:@"obj1"];
    [cache objectWithName:@"obj2"];
  }

  XCTAssertEqual([cache count], (NSUInteger)2, @"Cache should have two objects.");

  // Our "low memory" cache size will only fit one image.
  [cache reduceMemoryUsage];

  XCTAssertEqual([cache count], (NSUInteger)1, @"Cache should have one object.");
  XCTAssertNil([cache objectWithName:@"obj1"], @"Image 1 should not still be around.");
  XCTAssertNotNil([cache objectWithName:@"obj2"], @"Image 2 should still be around.");
}

- (void)testImageCacheStoringWithTinyLimit {
  NIImageMemoryCache* cache = [[NIImageMemoryCache alloc] init];

  cache.maxNumberOfPixels = 1;

  UIImage* img1 = [self emptyImageWithSize:CGSizeMake(100, 100)];
  UIImage* img2 = [self emptyImageWithSize:CGSizeMake(100, 100)];

  [cache storeObject: img1
            withName: @"obj1"];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should have zero objects.");

  [cache storeObject: img2
            withName: @"obj2"];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should have zero objects.");

  [cache reduceMemoryUsage];

  XCTAssertEqual([cache count], (NSUInteger)0, @"Cache should have zero objects.");

}

@end
