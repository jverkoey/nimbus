//
// Copyright 2011-2014 NimbusKit
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

#import "NIPreprocessorMacros.h"
#import "NIRuntimeClassModifications.h"

#pragma mark - Unit Test Documentation

/**
 * @fn NISwapInstanceMethods(Class, SEL, SEL)
 *
 * - [test] Swap two instance methods on a class.
 */

/**
 * @fn NISwapClassMethods(Class, SEL, SEL)
 *
 * - [test] Swap two static methods on a class.
 */

static NSInteger sClassValue = 0;

@interface NIRuntimeClassModificationsTests : XCTestCase {
@private
  NSInteger _value;
}

- (void)setValueToOne;
- (void)setValueToTwo;

+ (void)setValueToThree;
+ (void)setValueToFour;

@end


@implementation NIRuntimeClassModificationsTests


- (void)testSwapInstanceMethods {
  _value = 0;

  [self setValueToOne];
  XCTAssertEqual(_value, (NSInteger)1, @"value should be 1");

  [self setValueToTwo];
  XCTAssertEqual(_value, (NSInteger)2, @"value should be 2");

  NISwapInstanceMethods([NIRuntimeClassModificationsTests class],
                        @selector(setValueToOne), @selector(setValueToTwo));

  [self setValueToOne];
  XCTAssertEqual(_value, (NSInteger)2, @"value should be 2");

  [self setValueToTwo];
  XCTAssertEqual(_value, (NSInteger)1, @"value should be 1");
}

- (void)testSwapClassMethods {
  sClassValue = 0;

  [[self class] setValueToThree];
  XCTAssertEqual(sClassValue, (NSInteger)3, @"value should be 3");

  [[self class] setValueToFour];
  XCTAssertEqual(sClassValue, (NSInteger)4, @"value should be 4");

  NISwapClassMethods([NIRuntimeClassModificationsTests class],
                     @selector(setValueToThree), @selector(setValueToFour));

  [[self class] setValueToThree];
  XCTAssertEqual(sClassValue, (NSInteger)4, @"value should be 4");

  [[self class] setValueToFour];
  XCTAssertEqual(sClassValue, (NSInteger)3, @"value should be 3");
}

#pragma mark - Class Methods


- (void)setValueToOne {
  _value = 1;
}

- (void)setValueToTwo {
  _value = 2;
}

+ (void)setValueToThree {
  sClassValue = 3;
}

+ (void)setValueToFour {
  sClassValue = 4;
}

@end
