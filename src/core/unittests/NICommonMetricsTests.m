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

#import "NimbusCore.h"

@interface NICommonMetricsTests : XCTestCase
@end


@implementation NICommonMetricsTests


- (void)testAutoresizingMasks {
  XCTAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleLeftMargin),
                @"Should have a flexible left margin.");
  XCTAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleTopMargin),
                @"Should have a flexible top margin.");
  XCTAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleRightMargin),
                @"Should have a flexible right margin.");
  XCTAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleBottomMargin),
                @"Should have a flexible bottom margin.");

  XCTAssertTrue((UIViewAutoresizingFlexibleDimensions & UIViewAutoresizingFlexibleWidth),
                @"Should have a flexible width.");
  XCTAssertTrue((UIViewAutoresizingFlexibleDimensions & UIViewAutoresizingFlexibleHeight),
                @"Should have a flexible height.");
}

- (void)testMetrics {
  // TODO (Jan 25, 2012): Test iPad logic as well.
  //STAssertEquals(NIToolbarHeightForOrientation(UIInterfaceOrientationPortrait), 44.f, @"Should match.");
  XCTAssertEqual(NIToolbarHeightForOrientation(UIInterfaceOrientationLandscapeLeft), 33.f, @"Should match.");
  XCTAssertEqual(NIStatusBarAnimationCurve(), UIViewAnimationCurveEaseIn, @"Should match.");
  XCTAssertEqual(NIStatusBarAnimationDuration(), 0.3, @"Should match.");
  XCTAssertEqual(NIStatusBarBoundsChangeAnimationCurve(), UIViewAnimationCurveEaseInOut, @"Should match.");
  XCTAssertEqual(NIStatusBarBoundsChangeAnimationDuration(), 0.35, @"Should match.");

  // TODO (Jan 25, 2012): Override the status bar functionality so that we can test the height code.
  //STAssertEquals(NIStatusBarHeight(), 0.f, @"Should match.");

  XCTAssertEqual(NIDeviceRotationDuration(YES), 0.8, @"Should match.");
  XCTAssertEqual(NIDeviceRotationDuration(NO), 0.4, @"Should match.");
  XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(NICellContentPadding(), UIEdgeInsetsMake(10, 10, 10, 10)),
                @"Should match.");
}

@end
