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
 * For classic computer science data structures.
 *
 * iOS provides most of the important data structures such as arrays, dictionaries, and sets.
 * However, it is missing some lesser-used data structures such as linked lists and easy-to-use
 * trees structures. Nimbus makes use of the linked list data structure to provide an efficient
 * least-recently-used cache removal policy for its in-memory cache, NIMemoryCache.
 *
 *      @ingroup NimbusCore
 *      @defgroup Data-Structures Data Structures
 *      @{
 */

struct NILinkedListNode {
  id    object;
  struct NILinkedListNode* prev;
  struct NILinkedListNode* next;
};

typedef void NILinkedListLocation;

/**
 * A singly linked list implementation.
 *
 * This data structure provides constant time insertion and deletion of objects
 * in a collection.
 *
 * A linked list is different from an NSMutableArray solely in the runtime of adding and
 * removing objects. It is always possible to remove objects from both the beginning and end of
 * a linked list in constant time, contrasted with an NSMutableArray where removing an object
 * from the beginning of the list could result in O(N) linear time in the best of cases, where
 * N is the number of objects in the collection when the action is performed.
 * If an object's location is known, it is possible to get O(1) constant time removal
 * with a linked list, where an NSMutableArray would get at best O(N) linear time.
 */
@interface NILinkedList : NSObject <NSCopying, NSCoding, NSFastEnumeration> {
@private
  struct NILinkedListNode* _head;
  struct NILinkedListNode* _tail;
  unsigned long _count;

  // Used internally to track modifications to the linked list.
  unsigned long _modificationNumber;
}


/**
 * @name Creating a Linked List
 * @{
 */
#pragma mark Creating a Linked List

/**
 * Designated initializer.
 *
 * Creates an empty mutable linked list.
 */
- (id)init;

/**
 * Convenience method for creating an autoreleased linked list.
 *
 * Identical to [[[NILinkedList alloc] init] autorelease];
 */
+ (NILinkedList *)linkedList;

/**@}*/// End of Creating a Linked List


/**
 * @name Querying a Linked List
 * @{
 */
#pragma mark Querying a Linked List

/**
 * The first object in the linked list.
 */
@property (nonatomic, readonly) id firstObject;

/**
 * The last object in the linked list.
 */
@property (nonatomic, readonly) id lastObject;

/**
 * The number of objects in the linked list.
 */
@property (nonatomic, readonly) unsigned long count;

/**@}*/// End of Querying a Linked List


/**
 * @name Adding Objects
 * @{
 */
#pragma mark Adding Objects

/**
 * Append an object to the linked list.
 *
 *      Run-time: O(1)
 *
 *      @returns A location within the linked list.
 */
- (NILinkedListLocation *)addObject:(id)object;

/**@}*/// End of Adding Objects


/**
 * @name Removing Objects
 * @{
 */
#pragma mark Removing Objects

/**
 * Remove all objects from the linked list.
 *
 *      Run-time: Theta(count)
 */
- (void)removeAllObjects;

/**
 * Remove an object from the linked list.
 *
 *      Run-time: O(count)
 */
- (void)removeObject:(id)object;

/**
 * Remove the first object from the linked list.
 *
 *      Run-time: O(1)
 */
- (void)removeFirstObject;

/**
 * Remove the last object from the linked list.
 *
 *      Run-time: O(1)
 */
- (void)removeLastObject;

/**@}*/// End of Removing Objects


/**
 * @name Constant-Time Access
 * @{
 */
#pragma mark Constant-Time Access

/**
 * Search for an object in the linked list.
 *
 * The NILinkedListLocation object will remain valid as long as the object is still in the
 * linked list. Once the object is removed from the linked list, however, the location object
 * is released from memory and should no longer be used.
 *
 * TODO (jverkoey July 1, 2011): Consider creating a wrapper object for the location so that
 *                               we can deal with incorrect usage more safely.
 *
 *      Run-time: O(count)
 *
 *      @returns A location within the linked list.
 */
- (NILinkedListLocation *)locationOfObject:(id)object;

/**
 * Retrieve the object at a specific location.
 *
 *      Run-time: O(1)
 */
- (id)objectAtLocation:(NILinkedListLocation *)location;

/**
 * Remove an object at a predetermined location.
 *
 * It is assumed that this location still exists in the linked list. If the object this
 * location refers to has since been removed then this method will have undefined results.
 *
 * This is provided as an optimization over the O(n) removal method but should be used with care.
 *
 *      Run-time: O(1)
 *
 */
- (void)removeObjectAtLocation:(NILinkedListLocation *)location;

/**@}*/// End of Constant-Time Access

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Data Structures //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * @class NILinkedList
 *
 * <h2>Modifying a linked list</h2>
 *
 * To add an object to a linked list, you may use @link NILinkedList::addObject: addObject:@endlink.
 *
 * @code
 *  [ll addObject:object];
 * @endcode
 *
 * To remove some arbitrary object in linear time (meaning we must perform a scan of the list), use
 * @link NILinkedList::removeObject: removeObject:@endlink
 *
 * @code
 *  [ll removeObject:object];
 * @endcode
 *
 * Note that using a linked list in this way is way is identical to using an
 * NSMutableArray in performance time.
 *
 *
 * <h2>Accessing a Linked List</h2>
 *
 * You can access the first and last objects with constant time by using
 * @link NILinkedList::firstObject firstObject@endlink and
 * @link NILinkedList::lastObject lastObject@endlink.
 *
 * @code
 *  id firstObject = ll.firstObject;
 *  id lastObject = ll.lastObject;
 * @endcode
 *
 *
 * <h2>Traversing a Linked List</h2>
 *
 * NILinkedList implements the NSFastEnumeration protocol, allowing you to use foreach-style
 * iteration over the objects of a linked list. Note that you cannot modify a linked list
 * during fast iteration and doing so will fire an assertion.
 *
 * @code
 *  for (id object in ll) {
 *    // perform operations on the object
 *  }
 * @endcode
 *
 * If you need to modify the linked list while traversing it, an acceptable algorithm is to
 * successively remove either the head or tail object, depending on the order in which you wish
 * to traverse the linked list.
 *
 * <h3>Traversing Forward by Removing Objects from the List</h3>
 *
 * @code
 *  while (nil != ll.firstObject) {
 *    id object = [ll firstObject];
 *
 *    // Remove the head of the linked list in constant time.
 *    [ll removeFirstObject];
 *  }
 * @endcode
 *
 * <h3>Traversing Backward by Removing Objects from the List</h3>
 *
 * @code
 *  while (nil != ll.lastObject) {
 *    id object = [ll lastObject];
 *
 *    // Remove the tail of the linked list in constant time.
 *    [ll removeLastObject];
 *  }
 * @endcode
 *
 *
 * <h2>Examples</h2>
 *
 *
 * <h3>Building a first-in-first-out list of operations</h3>
 *
 * @code
 *  NILinkedList* ll = [NILinkedList linkedList];
 *
 *  // Add the operations to the linked list like you would an array.
 *  [ll addObject:operation1];
 *
 *  // Each addObject call appends the object to the end of the linked list.
 *  [ll addObject:operation2];
 *
 *  while (nil != ll.firstObject) {
 *    NSOperation* op1 = [ll firstObject];
 *    // Process the operation...
 *
 *    // Remove the head of the linked list in constant time.
 *    [ll removeFirstObject];
 *  }
 * @endcode
 *
 *
 * <h3>Removing an item from the middle of the list</h3>
 *
 * @code
 *  NILinkedList* ll = [NILinkedList linkedList];
 *
 *  [ll addObject:obj1];
 *  [ll addObject:obj2];
 *  [ll addObject:obj3];
 *  [ll addObject:obj4];
 *
 *  // Find an object in the linked list in linear time.
 *  NILinkedListLocation* location = [ll locationOfObject:obj3];
 *
 *  // Remove the object in constant time.
 *  [ll removeObjectAtLocation:location];
 *
 *  // Location has been released by this point.
 *  location = nil;
 *
 *  // Remove an object in linear time. This is simply a more concise version of the above.
 *  [ll removeObject:obj4];
 *
 *  // We would use the NILinkedListLocation to remove the object if we were storing the location
 *  // in an external data structure and wanted constant time removal, for example. See
 *  // NIMemoryCache for an example of this in action.
 * @endcode
 *
 *      @sa NIMemoryCache
 */
