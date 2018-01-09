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

#import "NimbusPagingScrollView.h"

@interface NIPagingScrollViewTests : XCTestCase
@end

@implementation NIPagingScrollViewTests

/** Test that rotating with a zero frame does not throw exceptions. */
- (void)testRotationWithZeroFrame {
  NIPagingScrollView *pagingScrollView = [[NIPagingScrollView alloc] initWithFrame:CGRectZero];
  UIInterfaceOrientation targetInterfaceOrientation = UIInterfaceOrientationPortrait;
  XCTAssertNoThrow([pagingScrollView willRotateToInterfaceOrientation:targetInterfaceOrientation
                                                             duration:0.25]);
  XCTAssertNoThrow([pagingScrollView willAnimateRotationToInterfaceOrientation:targetInterfaceOrientation
                                                                      duration:0.25]);

}

@end
