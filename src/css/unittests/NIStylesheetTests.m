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

#import "NimbusCSS.h"

@interface NIStylesheetTests : SenTestCase {
@private
  NSBundle* _unitTestBundle;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIStylesheetTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  _unitTestBundle = [NSBundle bundleWithIdentifier:@"com.nimbus.css.unittests"];
  STAssertNotNil(_unitTestBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
  _unitTestBundle = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testFailures {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];

  STAssertFalse([stylesheet loadFromPath:nil], @"Parsing nil path should fail.");
  STAssertFalse([stylesheet loadFromPath:nil pathPrefix:nil], @"Parsing nil path should fail.");
  STAssertFalse([stylesheet loadFromPath:nil pathPrefix:nil delegate:nil], @"Parsing nil path should fail.");
  STAssertFalse([stylesheet loadFromPath:@""], @"Parsing empty path should fail.");
  STAssertFalse([stylesheet loadFromPath:@"nonexistent_file"], @"Parsing invalid file should fail.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)assertColor:(UIColor *)color1 equalsColor:(UIColor *)color2 {
  size_t nColors1 = CGColorGetNumberOfComponents(color1.CGColor);
  size_t nColors2 = CGColorGetNumberOfComponents(color2.CGColor);
  STAssertEquals(nColors1, nColors2, @"Should have the same number of components.");

  const float* colors1 = CGColorGetComponents(color1.CGColor);
  const float* colors2 = CGColorGetComponents(color2.CGColor);
  for (NSInteger ix = 0; ix < nColors1; ++ix) {
    STAssertEqualsWithAccuracy(colors1[ix], colors2[ix], 0.0001, @"Colors should match.");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testApplyStyleToUILabel {
  // Sadly nearly all of these tests don't work with SenTest. The error we get when we run these
  // tests is:
  // ERROR: System image table has not been initialized. Do not ask for images or set up UI before UIApplicationMain() has been called.
  return;

  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"UILabel.css");

  STAssertTrue([stylesheet loadFromPath:pathToFile], @"The stylesheet should have been parsed.");

  UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
  [stylesheet applyStyleToView:label withClassName:NSStringFromClass([label class])];

  [self assertColor:label.textColor equalsColor:[UIColor redColor]];
  [self assertColor:label.shadowColor equalsColor:[UIColor greenColor]];
  STAssertEquals(label.textAlignment, UITextAlignmentRight, @"Alignment should match.");
  STAssertEquals(label.shadowOffset.width, 20.f, @"Shadow offset should match.");
  STAssertEquals(label.shadowOffset.height, -30.f, @"Shadow offset should match.");
  STAssertEquals(label.lineBreakMode, UILineBreakModeTailTruncation, @"Should match.");
  STAssertEquals(label.numberOfLines, 5, @"Should match.");
  STAssertEquals(label.minimumFontSize, 5.f, @"Should match.");
  STAssertTrue(label.adjustsFontSizeToFitWidth, @"Should match.");
  STAssertEquals(label.baselineAdjustment, UIBaselineAdjustmentAlignCenters, @"Should match.");
  STAssertEquals(label.alpha, 0.5f, @"Should match.");
}


@end
