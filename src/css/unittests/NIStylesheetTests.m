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

#import "NimbusCSS.h"

@interface NIStylesheetTests : XCTestCase {
@private
  NSBundle* _unitTestBundle;
}

@end


@implementation NIStylesheetTests


- (void)setUp {
  _unitTestBundle = [NSBundle bundleWithIdentifier:@"com.nimbus.css.unittests"];
  XCTAssertNotNil(_unitTestBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
}

- (void)tearDown {
  _unitTestBundle = nil;
}

- (void)testFailures {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];

  XCTAssertFalse([stylesheet loadFromPath:nil], @"Parsing nil path should fail.");
  XCTAssertFalse([stylesheet loadFromPath:nil pathPrefix:nil], @"Parsing nil path should fail.");
  XCTAssertFalse([stylesheet loadFromPath:nil pathPrefix:nil delegate:nil], @"Parsing nil path should fail.");
  XCTAssertFalse([stylesheet loadFromPath:@""], @"Parsing empty path should fail.");
  XCTAssertFalse([stylesheet loadFromPath:@"nonexistent_file"], @"Parsing invalid file should fail.");
}

- (void)assertColor:(UIColor *)color1 equalsColor:(UIColor *)color2 {
  size_t nColors1 = CGColorGetNumberOfComponents(color1.CGColor);
  size_t nColors2 = CGColorGetNumberOfComponents(color2.CGColor);
  XCTAssertEqual(nColors1, nColors2, @"Should have the same number of components.");

  const CGFloat* colors1 = CGColorGetComponents(color1.CGColor);
  const CGFloat* colors2 = CGColorGetComponents(color2.CGColor);
  for (NSInteger ix = 0; ix < nColors1; ++ix) {
    XCTAssertEqualWithAccuracy(colors1[ix], colors2[ix], 0.0001, @"Colors should match.");
  }
}

- (void)testApplyStyleToUILabel {
  // Sadly nearly all of these tests don't work with SenTest. The error we get when we run these
  // tests is:
  // ERROR: System image table has not been initialized. Do not ask for images or set up UI before UIApplicationMain() has been called.
  return;

  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"UILabel.css");

  XCTAssertTrue([stylesheet loadFromPath:pathToFile], @"The stylesheet should have been parsed.");

  UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
  [stylesheet applyStyleToView:label withClassName:NSStringFromClass([label class]) inDOM:nil];

  [self assertColor:label.textColor equalsColor:[UIColor redColor]];
  [self assertColor:label.shadowColor equalsColor:[UIColor greenColor]];
  XCTAssertEqual(label.textAlignment, NSTextAlignmentRight, @"Alignment should match.");
  XCTAssertEqual(label.shadowOffset.width, 20.f, @"Shadow offset should match.");
  XCTAssertEqual(label.shadowOffset.height, -30.f, @"Shadow offset should match.");
  XCTAssertEqual(label.lineBreakMode, NSLineBreakByTruncatingTail, @"Should match.");
  XCTAssertEqual(label.numberOfLines, 5, @"Should match.");
  XCTAssertEqual(label.minimumFontSize, 5.f, @"Should match.");
  XCTAssertTrue(label.adjustsFontSizeToFitWidth, @"Should match.");
  XCTAssertEqual(label.baselineAdjustment, UIBaselineAdjustmentAlignCenters, @"Should match.");
  XCTAssertEqual(label.alpha, 0.5f, @"Should match.");
}

@end
