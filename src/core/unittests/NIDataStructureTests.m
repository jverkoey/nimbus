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

#import "NimbusCore/NimbusCore.h"

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
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  STAssertEquals([ll count], (unsigned long)0, @"Initial linked list should be empty.");
  STAssertNil(ll.head, @"Initial linked list should not have a head object.");
  STAssertNil(ll.tail, @"Initial linked list should not have a tail object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddSingleItem {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  NSArray* object = [NSArray array];
  [ll addObject:object];
  STAssertEquals(ll.count, (unsigned long)1, @"There should be exactly one object.");
  STAssertEquals(ll.head, object, @"Head should be the object.");
  STAssertEquals(ll.tail, object, @"Tail should be the object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddTwoItems {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  [ll addObject:object1];
  [ll addObject:object2];
  STAssertEquals(ll.count, (unsigned long)2, @"There should be exactly two objects.");
  STAssertEquals(ll.head, object1, @"Head should be the first object.");
  STAssertEquals(ll.tail, object2, @"Tail should be the second object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListAddThreeItems {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  STAssertEquals(ll.count, (unsigned long)3, @"There should be exactly three objects.");
  STAssertEquals(ll.head, object1, @"Head should be the first object.");
  STAssertEquals(ll.tail, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListObjectAtLocation {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

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
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeFirstObject];
  STAssertEquals(ll.count, (unsigned long)2, @"There should be exactly two objects.");
  STAssertEquals(ll.head, object2, @"Head should be the second object.");
  STAssertEquals(ll.tail, object3, @"Tail should be the third object.");

  [ll removeFirstObject];
  STAssertEquals(ll.count, (unsigned long)1, @"There should be exactly one object.");
  STAssertEqualObjects(ll.head, object3, @"Head should be the third object.");
  STAssertEqualObjects(ll.tail, object3, @"Tail should be the third object.");

  [ll removeFirstObject];
  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveLastObject {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeLastObject];
  STAssertEquals(ll.count, (unsigned long)2, @"There should be exactly two objects.");
  STAssertEquals(ll.head, object1, @"Head should be the first object.");
  STAssertEquals(ll.tail, object2, @"Tail should be the second object.");

  [ll removeLastObject];
  STAssertEquals(ll.count, (unsigned long)1, @"There should be exactly one object.");
  STAssertEquals(ll.head, object1, @"Head should be the first object.");
  STAssertEquals(ll.tail, object1, @"Tail should be the first object.");

  [ll removeLastObject];
  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveAllObjects {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeAllObjects];

  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveTooManyObjects {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeAllObjects];

  [ll removeLastObject];

  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");

  [ll removeFirstObject];

  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");

  [ll removeAllObjects];

  STAssertEquals(ll.count, (unsigned long)0, @"There should be exactly zero objects.");
  STAssertNil(ll.head, @"Head should be nil.");
  STAssertNil(ll.tail, @"Tail should be nil.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListLocationOfObject {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  NILinkedListLocation* location = [ll addObject:object2];
  [ll addObject:object3];
  STAssertEquals(location, [ll locationOfObject:object2],
                 @"The locations should match up");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListRemoveObjectAtLocation {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];
  [ll removeObjectAtLocation:[ll locationOfObject:object2]];

  STAssertEquals(ll.count, (unsigned long)2, @"There should be exactly two objects.");
  STAssertEquals(ll.head, object1, @"Head should be the first object.");
  STAssertEquals(ll.tail, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListIteration {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

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
- (void)testLinkedListCopying {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NILinkedList* ll2 = [[ll copy] autorelease];
  STAssertEquals(ll2.count, (unsigned long)3, @"There should be exactly three objects.");
  STAssertEquals(ll2.head, object1, @"Head should be the first object.");
  STAssertEquals(ll2.tail, object3, @"Tail should be the third object.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLinkedListCoding {
  NILinkedList* ll = [[[NILinkedList alloc] init] autorelease];

  id object1 = [NSArray array];
  id object2 = [NSDictionary dictionary];
  id object3 = [NSSet set];
  [ll addObject:object1];
  [ll addObject:object2];
  [ll addObject:object3];

  NSData* data = [NSKeyedArchiver archivedDataWithRootObject:ll];
  NILinkedList* ll2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  STAssertEquals(ll2.count, (unsigned long)3, @"There should be exactly three objects.");
  STAssertEquals(ll2.head, object1, @"Head should be the first object.");
  STAssertEquals(ll2.tail, object3, @"Tail should be the third object.");
}


@end
