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

#import "NINonEmptyCollectionTesting.h"


#pragma mark -
#pragma mark Unit Test Documentation

/**
 * @fn NIIsArrayWithObjects(id)
 *
 * - [test] nil.
 * - [test] Empty array.
 * - [test] Non-array.
 * - [test] Array with any objects.
 */

/**
 * @fn NIIsSetWithObjects(id)
 *
 * - [test] nil.
 * - [test] Empty set.
 * - [test] Non-set.
 * - [test] Set with any objects.
 */

/**
 * @fn NIIsStringWithAnyText(id)
 *
 * - [test] nil.
 * - [test] Newly-allocated string.
 * - [test] @""
 * - [test] Non-string.
 * - [test] String with any text.
 */

@interface NINonEmptyCollectionTestingTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NINonEmptyCollectionTestingTests


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Non-Empty Collection Testing


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsArrayWithObjects {
  STAssertTrue(!NIIsArrayWithObjects(nil), @"nil should not be an array with items.");

  NSMutableArray* array = [[NSMutableArray alloc] init];

  STAssertTrue(!NIIsArrayWithObjects(array), @"This array should not have any items.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!NIIsArrayWithObjects(dictionary), @"This is not an array.");

  [array addObject:dictionary];
  STAssertTrue(NIIsArrayWithObjects(array), @"This array should have items.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsSetWithObjects {
  STAssertTrue(!NIIsSetWithObjects(nil), @"nil should not be a set with items.");

  NSMutableSet* set = [[NSMutableSet alloc] init];

  STAssertTrue(!NIIsSetWithObjects(set), @"This set should not have any items.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!NIIsSetWithObjects(dictionary), @"This is not an set.");

  [set addObject:dictionary];
  STAssertTrue(NIIsSetWithObjects(set), @"This set should have items.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testIsStringWithAnyText {
  STAssertTrue(!NIIsStringWithAnyText(nil), @"nil should not be a string with any text.");

  NSString* string = [[NSString alloc] init];

  STAssertTrue(!NIIsStringWithAnyText(string), @"This should be an empty string.");

  NSDictionary* dictionary = [[NSDictionary alloc] init];
  STAssertTrue(!NIIsStringWithAnyText(dictionary), @"This is not a string.");

  STAssertTrue(!NIIsStringWithAnyText(@""), @"This should be an empty string.");
  STAssertTrue(NIIsStringWithAnyText(@"three20"), @"This should be a string with text.");
}


@end
