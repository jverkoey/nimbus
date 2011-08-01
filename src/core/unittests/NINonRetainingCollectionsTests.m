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

#import "NIPreprocessorMacros.h"
#import "NINonRetainingCollections.h"


#pragma mark -
#pragma mark Unit Test Documentation

/**
 * @fn NICreateNonRetainingMutableArray()
 *
 * - [test] Verify that the retain count of objects aren't modified when added to and removed from
 *   non-retaining arrays.
 */

/**
 * @fn NICreateNonRetainingMutableDictionary()
 *
 * - [test] Verify that the retain count of objects aren't modified when added to and removed from
 *   non-retaining dictionaries.
 */

/**
 * @fn NICreateNonRetainingMutableSet()
 *
 * - [test] Verify that the retain count of objects aren't modified when added to and removed from
 *   non-retaining sets.
 */

@interface NINonRetainingCollectionsTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINonRetainingCollectionsTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingArray {
  NSMutableArray* array = NICreateNonRetainingMutableArray();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [array addObject:testObject];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  NI_RELEASE_SAFELY(array);

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [testObject release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingDictionary {
  NSMutableDictionary* dictionary = NICreateNonRetainingMutableDictionary();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [dictionary setObject:testObject forKey:@"obj"];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  NI_RELEASE_SAFELY(dictionary);

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [testObject release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingSet {
  NSMutableSet* set = NICreateNonRetainingMutableSet();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [set addObject:testObject];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  NI_RELEASE_SAFELY(set);

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [testObject release];
}


@end
