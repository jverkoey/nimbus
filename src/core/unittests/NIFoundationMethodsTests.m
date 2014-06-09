//
// Copyright 2011-2014 NimbusKit
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

#import <XCTest/XCTest.h>

#import "NIFoundationMethods.h"

@interface NIFoundationMethodsTests : XCTestCase {
}

@end

@implementation NIFoundationMethodsTests


#pragma mark - CGRect Methods


- (void)testCGRectMethods {
  CGRect rect = CGRectMake(0, 0, 100, 100);

  XCTAssertTrue(CGRectEqualToRect(CGRectMake(0, 0, 90, 90),
                                 NIRectContract(rect, 10, 10)),
                @"Contracting a rect should only modify the right and bottom edges.");

  XCTAssertTrue(CGRectEqualToRect(CGRectMake(10, 10, 90, 90),
                                 NIRectShift(rect, 10, 10)),
                @"Shifting a rect should only modify the left and top edges.");
}

- (void)testCGRectCenterWithin {
  UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
  
  CGRect centeredFrame = NIFrameOfCenteredViewWithinView(subview, containerView);
  
  XCTAssertTrue(CGRectEqualToRect(centeredFrame, CGRectMake(45, 45, 10, 10)), @"Rect should be centered.");
}


#pragma mark - NSRange Methods


- (void)testNSRangeMethods {
  CFRange cfRange = CFRangeMake(0, 10);
  NSRange nsRange = NIMakeNSRangeFromCFRange(cfRange);

  XCTAssertEqual(nsRange.location, (NSUInteger)cfRange.location,
                 @"The two locations should be equal.");

  XCTAssertEqual(nsRange.length, (NSUInteger)cfRange.length,
                 @"The two lengths should be equal.");
}

#pragma mark - NSData Methods


- (void)testNSDataHashing {
  const char* bytes = "nimbus";
  NSData* data = [[NSData alloc] initWithBytes:bytes length:strlen(bytes)];
  
  XCTAssertTrue([NIMD5HashFromData(data) isEqualToString:@"0e78d66f33c484a3c3b36d69bd3114cf"],
                @"MD5 hashes don't match.");
  XCTAssertTrue([NISHA1HashFromData(data) isEqualToString:@"c1b42d95fd18ad8a56d4fd7bbb4105952620d857"],
                @"SHA1 hashes don't match.");
}

#pragma mark - NSString Methods


- (void)testNIIsStringWithWhitespaceAndNewlines {
  XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(@""), @"Empty string should be whitespace and newlines.");
  XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(@" "), @"Space should be whitespace and newlines.");
  XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(@"    \n\r"), @"Whitespace and newlines should be whitespace and newlines.");
  XCTAssertFalse(NIIsStringWithWhitespaceAndNewlines(nil), @"nil is not a string");
  XCTAssertFalse(NIIsStringWithWhitespaceAndNewlines(@"cat"), @"Words are not whitespace and newlines");

  for (unsigned short unicode = 0x000A; unicode <= 0x000D; ++unicode) {
    NSString* str = [NSString stringWithFormat:@"%C", unicode];
    XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(str),
                  @"Unicode string #%X should be whitespace.", unicode);
  }

  NSString* str = [NSString stringWithFormat:@"%C", (unsigned short)0x0085];
  XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(str), @"Unicode string should be whitespace.");
  
  XCTAssertTrue(NIIsStringWithWhitespaceAndNewlines(@" \t\r\n"), @"Empty string should be whitespace.");
  
  XCTAssertTrue(!NIIsStringWithWhitespaceAndNewlines(@"a"), @"Text should not be whitespace.");
  XCTAssertTrue(!NIIsStringWithWhitespaceAndNewlines(@" \r\n\ta\r\n "), @"Text should not be whitespace.");
}

#pragma mark - General Purpose Methods


- (void)testNIBoundf {
  XCTAssertEqual(NIBoundf(1, 0, 2), 1.f, @"Should be equal.");
  XCTAssertEqual(NIBoundf(20, 0, 2), 2.f, @"Should be equal.");
  XCTAssertEqual(NIBoundf(-500, 0, 2), 0.f, @"Should be equal.");
  XCTAssertEqual(NIBoundf(5234, 0, -500), 0.f, @"Should be equal.");
}

- (void)testNIBoundi {
  XCTAssertEqual(NIBoundi(1, 0, 2), 1, @"Should be equal.");
  XCTAssertEqual(NIBoundi(20, 0, 2), 2, @"Should be equal.");
  XCTAssertEqual(NIBoundi(-500, 0, 2), 0, @"Should be equal.");
  XCTAssertEqual(NIBoundi(5234, 0, -500), 0, @"Should be equal.");
}

@end
