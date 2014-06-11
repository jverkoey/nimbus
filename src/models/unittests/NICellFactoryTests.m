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
#import "NimbusModels.h"

@interface NICellFactoryTests : XCTestCase
@end

@implementation NICellFactoryTests

- (void)testKeyClassMapping {
  NSMutableDictionary* map = [NSMutableDictionary dictionary];
  [map setObject:[NSObject class] forKey:(id<NSCopying>)[NSString class]];

  // @"" is the constant NSString class, which is a subclass of NSString.
  Class class = [NIActions objectFromKeyClass:[@"" class] map:map];
  XCTAssertNotNil(class, @"NSString constant should be a subclass of NSString, but no class returned from the map.");
  XCTAssertEqual(map.count, (NSUInteger)2, @"Should be two classes mapped to NSObject now.");
  for (class in map.allValues) {
    XCTAssertEqual(class, [NSObject class], @"All the mappings should be to NSObject.");
  }

  class = [NIActions objectFromKeyClass:NSNumber.class map:map];
  XCTAssertNil(class, @"NSNumber should not be mapped.");
  XCTAssertEqual(map.count, (NSUInteger)3, @"Should now be three classes mapped.");

  class = [NIActions objectFromKeyClass:NSNumber.class map:map];
  XCTAssertNil(class, @"NSNumber should still not be mapped.");
  XCTAssertEqual(map.count, (NSUInteger)3, @"Should now be three classes mapped.");
}

@end
