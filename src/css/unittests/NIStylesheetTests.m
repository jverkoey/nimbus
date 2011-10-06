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
  _unitTestBundle = [[NSBundle bundleWithIdentifier:@"com.nimbus.css.unittests"] retain];
  STAssertNotNil(_unitTestBundle, @"Unable to find the bundle %@", [NSBundle allBundles]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
  NI_RELEASE_SAFELY(_unitTestBundle);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testFailures {
  NIStylesheet* stylesheet = [[[NIStylesheet alloc] init] autorelease];

  STAssertFalse([stylesheet loadFromPath:nil], @"Parsing nil path should fail.");
  STAssertFalse([stylesheet loadFromPath:@""], @"Parsing empty path should fail.");
  STAssertFalse([stylesheet loadFromPath:@"nonexistent_file"], @"Parsing invalid file should fail.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testApplyStyleToUILabel {
  NIStylesheet* stylesheet = [[[NIStylesheet alloc] init] autorelease];
  NSString* pathToFile = NIPathForBundleResource(_unitTestBundle, @"UILabel.css");

  STAssertTrue([stylesheet loadFromPath:pathToFile], @"The stylesheet should have been parsed.");

  UILabel* label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  [stylesheet applyStyleToView:label];
}


@end
