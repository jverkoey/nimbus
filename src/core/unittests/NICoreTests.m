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

@interface NimbusCoreTests : SenTestCase {
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NimbusCoreTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSuccess {
  // This is just a test to ensure that you're building the unit tests properly.
  STAssertTrue(YES, @"Something is terribly, terribly wrong.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Non-Retaining Collections


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingArray {
  NSMutableArray* array = NICreateNonRetainingArray();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [array addObject:testObject];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [array release];
  [testObject release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingDictionary {
  NSMutableDictionary* dictionary = NICreateNonRetainingDictionary();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [dictionary setObject:testObject forKey:@"obj"];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [dictionary release];
  [testObject release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNonRetainingSet {
  NSMutableSet* set = NICreateNonRetainingSet();
  id testObject = [[NSArray alloc] init];
  NSUInteger initialRetainCount = [testObject retainCount];

  STAssertTrue(initialRetainCount > 0, @"Improper initial retain count");

  [set addObject:testObject];
  STAssertEquals([testObject retainCount], initialRetainCount, @"Improper new retain count");

  STAssertEquals([testObject retainCount], initialRetainCount,
                 @"Improper retain count after release");

  [set release];
  [testObject release];
}


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

  [array release];
  [dictionary release];
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

  [set release];
  [dictionary release];
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

  [string release];
  [dictionary release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CGRect Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testCGRectMethods {
  CGRect rect = CGRectMake(0, 0, 100, 100);

  STAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, 90, 90),
                                 NIRectContract(rect, 10, 10)),
               @"Contracting a rect should only modify the right and bottom edges.");

  STAssertTrue(CGRectEqualToRect(CGRectMake(10, 10, 90, 90),
                                 NIRectShift(rect, 10, 10)),
               @"Shifting a rect should only modify the left and top edges.");

  STAssertTrue(CGRectEqualToRect(CGRectMake(10, 10, 80, 80),
                                 NIRectInset(rect, UIEdgeInsetsMake(10, 10, 10, 10))),
               @"Insetting a rect should modify all edges.");
}


@end
