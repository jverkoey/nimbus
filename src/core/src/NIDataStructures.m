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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILinkedList

@synthesize count = _count;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self removeAllObjects];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [super init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NILinkedList *)linkedList {
  return [[[[self class] alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_eraseNode:(struct NILinkedListNode *)node {
  [node->object release];
  free(node);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_setHead:(struct NILinkedListNode *)head {
  _head = head;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_setTail:(struct NILinkedListNode *)tail {
  _tail = tail;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_setCount:(unsigned long)count {
  _count = count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCopying


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)copyWithZone:(NSZone *)zone {
  NILinkedList* copy = [[[self class] allocWithZone:zone] init];

  struct NILinkedListNode* prevCopiedNode = 0;

  struct NILinkedListNode* node = _head;
  while (0 != node) {

    struct NILinkedListNode* copiedNode = malloc(sizeof(struct NILinkedListNode));
    memset(copiedNode, 0, sizeof(struct NILinkedListNode));
    copiedNode->object = [node->object retain];
    copiedNode->prev = prevCopiedNode;

    if (0 != prevCopiedNode) {
      prevCopiedNode->next = copiedNode;

    } else {
      [copy _setHead:copiedNode];
    }

    [copy _setTail:copiedNode];

    prevCopiedNode = node;
    node = node->next;
  }

  [copy _setCount:_count];

  return copy;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSCoding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeValueOfObjCType:@encode(unsigned long) at:&_count];

  struct NILinkedListNode* node = _head;
  while (0 != node) {
    [coder encodeObject:node->object];
    node = node->next;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [super init])) {
    [decoder decodeValueOfObjCType:@encode(unsigned long) at:&_count];

    struct NILinkedListNode* prevNode = 0;

    for (unsigned long ix = 0; ix < _count; ++ix) {
      id object = [decoder decodeObject];

      struct NILinkedListNode* node = malloc(sizeof(struct NILinkedListNode));
      memset(node, 0, sizeof(struct NILinkedListNode));
      node->object = [object retain];
      node->prev = prevNode;

      if (0 != prevNode) {
        prevNode->next = node;

      } else {
        _head = node;
      }

      _tail = node;

      prevNode = node;
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFastEnumeration


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)countByEnumeratingWithState: (NSFastEnumerationState *)state
                                  objects: (id *)stackbuf
                                    count: (NSUInteger)len {
  // Initialization condition.
  if (0 == state->state) {
    // Whenever the linked list is modified, the modification number increases.
    state->mutationsPtr = &_modificationNumber;
  }

  NSUInteger numberOfItemsReturned = 0;

  // If there is no _tail (i.e. this is an empty list) then this will end immediately.
  if ((struct NILinkedListNode *)state->state != _tail) {
    state->itemsPtr = stackbuf;

    if (0 == state->state) {
      // Initialize the state here instead of above when we check 0 == state->state because
      // for single item linked lists head == tail.
      state->state = (unsigned long)_head;
    }

    while ((0 != state->state) && (numberOfItemsReturned < len)) {
      struct NILinkedListNode* node = (struct NILinkedListNode *)state->state;
      stackbuf[numberOfItemsReturned] = node->object;
      state->state = (unsigned long)node->next;
      ++numberOfItemsReturned;
    }

    if (0 == state->state) {
      state->state = (unsigned long)_tail;
    }

  } // else we've returned all of the items that we can; leave numberOfItemsReturned as 0 to
    // signal that there is nothing left to be done.

  return numberOfItemsReturned;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)firstObject {
  return (nil != _head) ? _head->object : nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)lastObject {
  return (nil != _tail) ? _tail->object : nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NILinkedListLocation *)addObject:(id)object {
  // nil objects can not be added to a linked list.
  NIDASSERT(nil != object);
  if (nil == object) {
    return nil;
  }

  struct NILinkedListNode* node = malloc(sizeof(struct NILinkedListNode));
  memset(node, 0, sizeof(struct NILinkedListNode));
  node->object = [object retain];
  if (nil == _tail) {
    _head = node;
    _tail = node;

  } else {
    _tail->next = (struct NILinkedListNode*)node;
    node->prev = (struct NILinkedListNode*)_tail;
    _tail = node;
  }

  ++_count;
  ++_modificationNumber;

  return (NILinkedListLocation *)node;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectAtLocation:(NILinkedListLocation *)location {
  return ((struct NILinkedListNode *)location)->object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllObjects {
  struct NILinkedListNode* node = _head;
  while (nil != node) {
    struct NILinkedListNode* next = (struct NILinkedListNode *)node->next;
    [self _eraseNode:node];
    node = next;
  }

  _head = nil;
  _tail = nil;

  _count = 0;
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
  [self removeObjectAtLocation:_head];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeLastObject {
  [self removeObjectAtLocation:_tail];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NILinkedListLocation *)locationOfObject:(id)object {
  struct NILinkedListNode* node = _head;
  while (0 != node) {
    if (node->object == object) {
      return (NILinkedListLocation *)node;
    }
    node = node->next;
  }
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeObjectAtLocation:(NILinkedListLocation *)location {
  if (0 == location) {
    return;
  }

  struct NILinkedListNode* node = (struct NILinkedListNode *)location;

  if (0 != node->prev) {
    node->prev->next = node->next;

  } else {
    _head = node->next;
  }

  if (0 != node->next) {
    node->next->prev = node->prev;

  } else {
    _tail = node->prev;
  }

  [self _eraseNode:node];

  --_count;
  ++_modificationNumber;
}


@end

