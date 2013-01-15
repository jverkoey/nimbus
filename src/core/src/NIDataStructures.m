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

#import "NIDataStructures.h"

#import "NIDebuggingTools.h"
#import "NIPreprocessorMacros.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

// The internal representation of a single node.
@interface NILinkedListNode : NSObject
@property (nonatomic, readwrite, NI_STRONG) id object;
@property (nonatomic, readwrite, NI_STRONG) NILinkedListNode* prev;
@property (nonatomic, readwrite, NI_STRONG) NILinkedListNode* next;
@end

@implementation NILinkedListNode
@synthesize object = _object;
@synthesize prev = _prev;
@synthesize next = _next;
@end

@interface NILinkedListLocation()
+ (id)locationWithNode:(NILinkedListNode *)node;
- (id)initWithNode:(NILinkedListNode *)node;
@property (nonatomic, readwrite, NI_WEAK) NILinkedListNode* node;
@end

@implementation NILinkedListLocation
@synthesize node = _node;
+ (id)locationWithNode:(NILinkedListNode *)node {
  return [[self alloc] initWithNode:node];
}
- (id)initWithNode:(NILinkedListNode *)node {
  if ((self = [super init])) {
    _node = node;
  }
  return self;
}
- (BOOL)isEqual:(id)object {
  return ([object isKindOfClass:[NILinkedListLocation class]]
          && [object node] == self.node);
}
@end

@interface NILinkedList()
// Exposed so that the linked list enumerator can iterate over the nodes directly.
@property (nonatomic, readonly, NI_STRONG) NILinkedListNode* head;
@property (nonatomic, readonly, NI_STRONG) NILinkedListNode* tail;
@property (nonatomic, readwrite, assign) NSUInteger count;
@property (nonatomic, readwrite, assign) unsigned long modificationNumber;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @internal
 *
 * A implementation of NSEnumerator for NILinkedList.
 *
 * This class simply implements the nextObject NSEnumerator method and traverses a linked list.
 * The linked list is retained when this enumerator is created and released once the enumerator
 * is either released or deallocated.
 */
@interface NILinkedListEnumerator : NSEnumerator {
@private
  NILinkedList* _ll;
  NILinkedListNode* _iterator;
}

/**
 * Designated initializer. Retains the linked list.
 */
- (id)initWithLinkedList:(NILinkedList *)ll;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILinkedListEnumerator


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _iterator = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithLinkedList:(NILinkedList *)ll {
  if ((self = [super init])) {
    _ll = ll;
    _iterator = ll.head;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)nextObject {
  id object = nil;

  // Iteration step.
  if (nil != _iterator) {
    object = _iterator.object;
    _iterator = _iterator.next;

  // Completion step.
  } else {
    // As per the guidelines in the Objective-C docs for enumerators, we release the linked
    // list when we are finished enumerating.
    _ll = nil;
    
    // We don't have to set _iterator to nil here because is already is.
  }
  return object;
}


@end


#pragma mark -


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILinkedList

@synthesize count = _count;
@synthesize head = _head;
@synthesize tail = _tail;
@synthesize modificationNumber = _modificationNumber;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Linked List Creation


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NILinkedList *)linkedList {
  return [[[self class] alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NILinkedList *)linkedListWithArray:(NSArray *)array {
  return [[[self class] alloc] initWithArray:array];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithArray:(NSArray *)anArray {
  if ((self = [self init])) {
    for (id object in anArray) {
      [self addObject:object];
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_setCount:(NSUInteger)count {
  _count = count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_removeNode:(NILinkedListNode *)node {
  if (nil == node) {
    return;
  }

  if (nil != node.prev) {
    node.prev.next = node.next;

  } else {
    _head = node.next;
  }

  if (nil != node.next) {
    node.next.prev = node.prev;

  } else {
    _tail = node.prev;
  }

  node.next = nil;
  node.prev = nil;

  --_count;
  ++_modificationNumber;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSCopying


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)copyWithZone:(NSZone *)zone {
  NILinkedList* copy = [[[self class] allocWithZone:zone] init];

  NILinkedListNode* node = _head;

  while (0 != node) {
    [copy addObject:node.object];
    node = node.next;
  }

  copy.count = self.count;

  return copy;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeValueOfObjCType:@encode(NSUInteger) at:&_count];

  NILinkedListNode* node = _head;
  while (0 != node) {
    [coder encodeObject:node.object];
    node = node.next;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [super init])) {
    // We'll let addObject modify the count, so create a local count here so that we don't
    // double count every object.
    NSUInteger count = 0;
    [decoder decodeValueOfObjCType:@encode(NSUInteger) at:&count];

    for (NSUInteger ix = 0; ix < count; ++ix) {
      id object = [decoder decodeObject];

      [self addObject:object];
    }

    // Sanity check.
    NIDASSERT(count == self.count);
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFastEnumeration


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id *)stackbuf
                                    count:(NSUInteger)len {
  // Initialization condition.
  if (0 == state->state) {
    // Whenever the linked list is modified, the modification number increases. This allows
    // enumeration to bail out if the linked list is modified mid-flight.
    state->mutationsPtr = &_modificationNumber;
  }

  NSUInteger numberOfItemsReturned = 0;

  // If there is no _tail (i.e. this is an empty list) then this will end immediately.
  if ((void *)state->state != (__bridge void *)_tail) {
    state->itemsPtr = stackbuf;

    if (0 == state->state) {
      // Initialize the state here instead of above when we check 0 == state.state because
      // for single item linked lists head == tail. If we initialized it in the initialization
      // condition, state.state != _tail check would fail and we wouldn't return the single
      // object.
      state->state = (unsigned long)_head;
    }

    // Return *at most* the number of request objects.
    while ((0 != state->state) && (numberOfItemsReturned < len)) {
      NILinkedListNode* node = (__bridge NILinkedListNode *)(void *)state->state;
      stackbuf[numberOfItemsReturned] = node.object;
      state->state = (unsigned long)node.next;
      ++numberOfItemsReturned;
    }

    if (0 == state->state) {
      // Final step condition. We allow the above loop to overstep the end one iteration,
      // because we rewind it one step here (to ensure that the next time enumeration occurs,
      // state == _tail.
      state->state = (unsigned long)_tail;
    }

  } // else we've returned all of the items that we can; leave numberOfItemsReturned as 0 to
    // signal that there is nothing left to be done.

  return numberOfItemsReturned;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)firstObject {
  return (nil != _head) ? _head.object : nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)lastObject {
  return (nil != _tail) ? _tail.object : nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Extended Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)allObjects {
  NSMutableArray* mutableArrayOfObjects = [[NSMutableArray alloc] initWithCapacity:self.count];

  for (id object in self) {
    [mutableArrayOfObjects addObject:object];
  }

  return [mutableArrayOfObjects copy];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)containsObject:(id)anObject {
  for (id object in self) {
    if (object == anObject) {
      return YES;
    }
  }
  
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)description {
  // In general we should try to avoid cheating by using allObjects for memory performance reasons,
  // but the description method is complex enough that it's not worth reinventing the wheel here.
  return [[self allObjects] description];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectAtLocation:(NILinkedListLocation *)location {
  return location.node.object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSEnumerator *)objectEnumerator {
  return [[NILinkedListEnumerator alloc] initWithLinkedList:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NILinkedListLocation *)locationOfObject:(id)object {
  NILinkedListNode* node = _head;
  while (0 != node) {
    if (node.object == object) {
      return [NILinkedListLocation locationWithNode:node];
    }
    node = node.next;
  }
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeObjectAtLocation:(NILinkedListLocation *)location {
  if (nil == location) {
    return;
  }

  [self _removeNode:location.node];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NILinkedListLocation *)addObject:(id)object {
  // nil objects can not be added to a linked list.
  NIDASSERT(nil != object);
  if (nil == object) {
    return nil;
  }

  NILinkedListNode* node = [[NILinkedListNode alloc] init];
  node.object = object;

  // Empty condition.
  if (nil == _tail) {
    _head = node;
    _tail = node;

  } else {
    // Non-empty condition.
    _tail.next = node;
    node.prev = _tail;
    _tail = node;
  }

  ++self.count;
  ++_modificationNumber;

  return [NILinkedListLocation locationWithNode:node];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addObjectsFromArray:(NSArray *)array {
  for (id object in array) {
    [self addObject:object];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Mutable Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllObjects {
  NILinkedListNode* node = _head;
  while (nil != node) {
    NILinkedListNode* next = node.next;
    node.prev = nil;
    node.next = nil;
    node = next;
  }

  _head = nil;
  _tail = nil;
  
  self.count = 0;
  ++_modificationNumber;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeObject:(id)object {
  NILinkedListLocation* location = [self locationOfObject:object];
  if (0 != location) {
    [self removeObjectAtLocation:location];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFirstObject {
  [self _removeNode:_head];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeLastObject {
  [self _removeNode:_tail];
}

@end
