//
// Copyright 2012 Jeff Verkoeyen
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
#import <UIKit/UIKit.h>

#import "NIState.h"

@interface NIStateTests : SenTestCase
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIStateTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingletonAccess {
  STAssertNotNil([Nimbus imageMemoryCache], @"Singleton object should be created automatically.");
  STAssertNotNil([Nimbus networkOperationQueue], @"Singleton object should be created automatically.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testSingletonSetting {
  NIImageMemoryCache *cache = [[NIImageMemoryCache alloc] init];
  [Nimbus setImageMemoryCache:cache];
  STAssertEquals([Nimbus imageMemoryCache], cache, @"Singleton object should have been set.");

  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  [Nimbus setNetworkOperationQueue:queue];
  STAssertEquals([Nimbus networkOperationQueue], queue, @"Singleton object should have been set.");
}

@end
