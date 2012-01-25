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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore.h"

@interface NICommonMetricsTests : SenTestCase
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICommonMetricsTests


///////////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testMetrics {
  
}


@end
