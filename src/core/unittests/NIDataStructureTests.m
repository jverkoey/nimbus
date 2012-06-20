//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 9, 2011 - Copyright 2009-2011 Facebook
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

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore.h"

@interface NIDataStructureTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIDataStructureTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Linked List


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testEmptyLinkedList {
  NILinkedList* ll = [[NILinkedList alloc] init];

  STAssertEquals([ll count], (NSUInteger)0, @"Initial linked list should be empty.");
  STAssertNil(ll.firstObject, @"Initial linked list should not have a head object.");
  STAssertNil(ll.lastObject, @"Initial linked list should not have a tail object.");

  ll = [NILinkedList linkedList];

  STAssertEquals([ll count], (NSUInteger)0, @"Initial linked list should be empty.");
  STAssertNil(ll.firstObject, @"Initial linked list should not have a head object.");
  STAssertNil(ll.lastObject, @"Initial linked list should not have a tail object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListDescription {
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  NSArray* array = [NSArray arrayWithObjects:object1, object2, object3, nil];

  NILinkedList* ll = [[NILinkedList alloc] initWithArray:array];

  STAssertTrue([[ll description] isEqualToString:[array description]], @"Should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListWithArray {
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  NSArray* array = [NSArray arrayWithObjects:object1, object2, object3, nil];
  
  NILinkedList* ll = [[NILinkedList alloc] initWithArray:array];
  
  STAssertEquals([ll count], (NSUInteger)3, @"Should have 3 objects.");
  STAssertEquals(ll.firstObject, object1, @"Head object should be object1.");
  STAssertEquals(ll.lastObject, object3, @"Tail object should be object3.");

  ll = [NILinkedList linkedListWithArray:array];
  
  STAssertEquals([ll count], (NSUInteger)3, @"Should have 3 objects.");
  STAssertEquals(ll.firstObject, object1, @"Head object should be object1.");
  STAssertEquals(ll.lastObject, object3, @"Tail object should be object3.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddNilItem {
  NILinkedList* ll = [[NILinkedList alloc] init];

  NIDebugAssertionsShouldBreak = NO;
  [ll addObject:nil];
  NIDebugAssertionsShouldBreak = YES;
  STAssertEquals(ll.count, (NSUInteger)0, @"There should be no objects.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddSingleItem {
  NILinkedList* ll = [[NILinkedList alloc] init];

  NSArray* object = [NSArray array];
  [ll addObject:object];
  STAssertEquals(ll.count, (NSUInteger)1, @"There should be exactly one object.");
  STAssertEquals(ll.firstObject, object, @"Head should be the object.");
  STAssertEquals(ll.lastObject, object, @"Tail should be the object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddTwoItems {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  [ll addObject:object1];
  [ll addObject:object2];
  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object2, @"Tail should be the second object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddThreeItems {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  STAssertEquals(ll.count, (NSUInteger)3, @"There should be exactly three objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddArrayOfItems {
  NILinkedList* ll = [[NILinkedList alloc] init];
  
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObjectsFromArray:[NSArray arrayWithObjects:object1, object2, object3, nil]];
  STAssertEquals(ll.count, (NSUInteger)3, @"There should be exactly three objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListCount {
  NILinkedList* ll = [[NILinkedList alloc] init];
  
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  [ll addObject:object1];
  STAssertEquals(ll.count, (NSUInteger)1, @"There should be exactly one object.");
  [ll addObject:object2];
  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  [ll addObject:object3];
  STAssertEquals(ll.count, (NSUInteger)3, @"There should be exactly three objects.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAllObjects {
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  NSArray* array = [NSArray arrayWithObjects:object1, object2, object3, nil];
  
  NILinkedList* ll = [NILinkedList linkedListWithArray:array];
  
  array = [ll allObjects];

  STAssertEquals([array count], (NSUInteger)3, @"There should be 3 objects in the array.");
  STAssertEquals([array objectAtIndex:0], object1, @"The first object should be object1.");
  STAssertEquals([array objectAtIndex:1], object2, @"The second object should be object2.");
  STAssertEquals([array objectAtIndex:2], object3, @"The third object should be object3.");

  // Test empty case.
  array = [NSArray array];
  
  ll = [NILinkedList linkedListWithArray:array];

  array = [ll allObjects];

  STAssertEquals([array count], (NSUInteger)0, @"There should be no objects in the array.");

  // Test nil case.
  ll = [NILinkedList linkedListWithArray:nil];
  
  array = [ll allObjects];
  
  STAssertEquals([array count], (NSUInteger)0, @"There should be no objects in the array.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListContainsObject {
  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  NSArray* array = [NSArray arrayWithObjects:object1, object2, nil];
  
  NILinkedList* ll = [NILinkedList linkedListWithArray:array];
  
  STAssertTrue([ll containsObject:object1], @"The linked list should contain object1.");
  STAssertTrue([ll containsObject:object2], @"The linked list should contain object2.");
  STAssertFalse([ll containsObject:object3], @"The linked list should not contain object3.");
  STAssertFalse([ll containsObject:nil], @"Checking for the nil object should never be true.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListObjectAtLocation {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  NILinkedListLocation* location = [ll addObject:object2];
  [ll addObject:object3];
  STAssertEquals([ll objectAtLocation:location], object2,
                 @"The location should point to the second object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveFirstObject {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeFirstObject];
  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object2, @"Head should be the second object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");

  [ll removeFirstObject];
  STAssertEquals(ll.count, (NSUInteger)1, @"There should be exactly one object.");
  STAssertEqualObjects(ll.firstObject, object3, @"Head should be the third object.");
  STAssertEqualObjects(ll.lastObject, object3, @"Tail should be the third object.");

  [ll removeFirstObject];
  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveLastObject {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeLastObject];
  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object2, @"Tail should be the second object.");

  [ll removeLastObject];
  STAssertEquals(ll.count, (NSUInteger)1, @"There should be exactly one object.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object1, @"Tail should be the first object.");

  [ll removeLastObject];
  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveAllObjects {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeAllObjects];

  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveTooManyObjects {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeAllObjects];

  [ll removeLastObject];

  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");

  [ll removeFirstObject];

  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");

  [ll removeAllObjects];

  STAssertEquals(ll.count, (NSUInteger)0, @"There should be exactly zero objects.");
  STAssertNil(ll.firstObject, @"Head should be nil.");
  STAssertNil(ll.lastObject, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListLocationOfObject {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  NILinkedListLocation* location = [ll addObject:object2];
  [ll addObject:object3];
  STAssertTrue([location isEqual:[ll locationOfObject:object2]], @"The locations should match up");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveObject {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeObject:object2];

  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");

  // Test removing an object that has already been removed.
  [ll removeObject:object2];

  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");

  // Test removing the tail.
  [ll removeObject:object3];

  STAssertEquals(ll.count, (NSUInteger)1, @"There should be exactly one object.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object1, @"Tail should be the first object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveObjectAtLocation {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeObjectAtLocation:[ll locationOfObject:object2]];

  STAssertEquals(ll.count, (NSUInteger)2, @"There should be exactly two objects.");
  STAssertEquals(ll.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll.lastObject, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListIteration {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NSInteger ix = 0;
  for (id object in ll) {
    if (ix == 0) {
      STAssertEquals(object, object1, @"The first object should be object1.");

    } else if (ix == 1) {
      STAssertEquals(object, object2, @"The second object should be object2.");

    } else if (ix == 2) {
      STAssertEquals(object, object3, @"The third object should be object3.");
    }
    ++ix;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListEnumeration {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NSEnumerator* enumerator = [ll objectEnumerator];
  STAssertEquals([enumerator nextObject], object1, @"The first object should be object1.");
  STAssertEquals([enumerator nextObject], object2, @"The first object should be object2.");
  STAssertEquals([enumerator nextObject], object3, @"The first object should be object3.");
  STAssertNil([enumerator nextObject], @"The final object should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListCopying {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NILinkedList* ll2 = [ll copy];
  STAssertEquals(ll2.count, (NSUInteger)3, @"There should be exactly three objects.");
  STAssertEquals(ll2.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll2.lastObject, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListCoding {
  NILinkedList* ll = [[NILinkedList alloc] init];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NSData* data = [NSKeyedArchiver archivedDataWithRootObject:ll];
  NILinkedList* ll2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  STAssertEquals(ll2.count, (NSUInteger )3, @"There should be exactly three objects.");
  STAssertEquals(ll2.firstObject, object1, @"Head should be the first object.");
  STAssertEquals(ll2.lastObject, object3, @"Tail should be the third object.");
}


@end
