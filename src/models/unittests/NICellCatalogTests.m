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

#import <XCTest/XCTest.h>

#import "NimbusCore.h"
#import "NimbusModels.h"

@interface NICellCatalogTests : XCTestCase
@end

@interface TestTitleCellObject : NITitleCellObject
@property (nonatomic, assign) BOOL designatedInitializerWasExecuted;
@end

@interface TestSubtitleCellObject : NISubtitleCellObject
@property (nonatomic, assign) BOOL designatedInitializerWasExecuted;
@end

@implementation NICellCatalogTests

- (void)testCellObjectSubclassInitialization {
  TestTitleCellObject *titleCellObject = [[TestTitleCellObject alloc] initWithTitle:@"Title"];
  XCTAssertTrue(titleCellObject.designatedInitializerWasExecuted,
                @"%@'s designated initializer override did not run.", [titleCellObject class]);
  TestSubtitleCellObject *subtitleCellObject = [[TestSubtitleCellObject alloc] initWithTitle:@"Title"];
  XCTAssertTrue(subtitleCellObject.designatedInitializerWasExecuted,
                @"%@'s designated initializer override did not run.", [subtitleCellObject class]);
}

@end

@implementation TestTitleCellObject

- (id)initWithTitle:(NSString *)title image:(UIImage *)image {
  self = [super initWithTitle:title image:image];
  if (self) {
    _designatedInitializerWasExecuted = YES;
  }
  return self;
}

@end

@implementation TestSubtitleCellObject

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
  self = [super initWithTitle:title subtitle:subtitle image:image];
  if (self) {
    _designatedInitializerWasExecuted = YES;
  }
  return self;
}

@end
