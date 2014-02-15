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

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore.h"

@interface NICommonMetricsTests : SenTestCase
@end


@implementation NICommonMetricsTests


- (void)testAutoresizingMasks {
  STAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleLeftMargin),
               @"Should have a flexible left margin.");
  STAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleTopMargin),
               @"Should have a flexible top margin.");
  STAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleRightMargin),
               @"Should have a flexible right margin.");
  STAssertTrue((UIViewAutoresizingFlexibleMargins & UIViewAutoresizingFlexibleBottomMargin),
               @"Should have a flexible bottom margin.");

  STAssertTrue((UIViewAutoresizingFlexibleDimensions & UIViewAutoresizingFlexibleWidth),
               @"Should have a flexible width.");
  STAssertTrue((UIViewAutoresizingFlexibleDimensions & UIViewAutoresizingFlexibleHeight),
               @"Should have a flexible height.");
}

- (void)testMetrics {
  // TODO (Jan 25, 2012): Test iPad logic as well.
  //STAssertEquals(NIToolbarHeightForOrientation(UIInterfaceOrientationPortrait), 44.f, @"Should match.");
  STAssertEquals(NIToolbarHeightForOrientation(UIInterfaceOrientationLandscapeLeft), 33.f, @"Should match.");
  STAssertEquals(NIStatusBarAnimationCurve(), UIViewAnimationCurveEaseIn, @"Should match.");
  STAssertEquals(NIStatusBarAnimationDuration(), 0.3, @"Should match.");
  STAssertEquals(NIStatusBarBoundsChangeAnimationCurve(), UIViewAnimationCurveEaseInOut, @"Should match.");
  STAssertEquals(NIStatusBarBoundsChangeAnimationDuration(), 0.35, @"Should match.");

  // TODO (Jan 25, 2012): Override the status bar functionality so that we can test the height code.
  //STAssertEquals(NIStatusBarHeight(), 0.f, @"Should match.");

  STAssertEquals(NIDeviceRotationDuration(YES), 0.8, @"Should match.");
  STAssertEquals(NIDeviceRotationDuration(NO), 0.4, @"Should match.");
  STAssertTrue(UIEdgeInsetsEqualToEdgeInsets(NICellContentPadding(), UIEdgeInsetsMake(10, 10, 10, 10)),
               @"Should match.");
}

@end
