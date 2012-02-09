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

#import "NIFoundationMethods.h"

@interface NIFoundationMethodsTests : SenTestCase {
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIFoundationMethodsTests


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
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSRange Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testNSRangeMethods {
  CFRange cfRange = CFRangeMake(0, 10);
  NSRange nsRange = NIMakeNSRangeFromCFRange(cfRange);

  STAssertEquals(nsRange.location, (NSUInteger)cfRange.location,
                 @"The two locations should be equal.");

  STAssertEquals(nsRange.length, (NSUInteger)cfRange.length,
                 @"The two lengths should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General Purpose Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testboundf {
  STAssertEquals(boundf(1, 0, 2), 1.f, @"Should be equal.");
  STAssertEquals(boundf(20, 0, 2), 2.f, @"Should be equal.");
  STAssertEquals(boundf(-500, 0, 2), 0.f, @"Should be equal.");
  STAssertEquals(boundf(5234, 0, -500), 0.f, @"Should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testboundi {
  STAssertEquals(boundi(1, 0, 2), 1, @"Should be equal.");
  STAssertEquals(boundi(20, 0, 2), 2, @"Should be equal.");
  STAssertEquals(boundi(-500, 0, 2), 0, @"Should be equal.");
  STAssertEquals(boundi(5234, 0, -500), 0, @"Should be equal.");
}


@end
