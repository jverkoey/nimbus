//
// Copyright 2011-2014 NimbusKit
//
// Forked from Three20 June 9, 2011 - Copyright 2009-2011 Facebook
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

@interface RecyclableView : UIView <NIRecyclableView> {
@private
  NSString* _reuseIdentifier;
  BOOL _didReuse;
}
@property (nonatomic, copy) NSString* reuseIdentifier;
@property (nonatomic, assign) BOOL didReuse;
@end

@interface NIViewRecyclerTests : XCTestCase
@end

@implementation NIViewRecyclerTests


- (void)testNils {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:nil], @"Should be nil.");
  NIDebugAssertionsShouldBreak = NO;
  [recycler recycleView:nil];
  NIDebugAssertionsShouldBreak = YES;

  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:nil], @"Should be nil.");
}

- (void)testNoReuseIdentifierRecycling {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  NSString* reuseIdentifier = NSStringFromClass([RecyclableView class]);
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    [recycler recycleView:view];
    XCTAssertFalse(view.didReuse, @"Should not have reused this view yet.");
  }
  {
    RecyclableView* view = (RecyclableView*)[recycler dequeueReusableViewWithIdentifier:reuseIdentifier];
    XCTAssertTrue(view.didReuse, @"Should have reused this view.");
  }
  
  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:reuseIdentifier], @"Should be no views left.");
}

- (void)testRecycling {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  NSString* reuseIdentifier = NSStringFromClass([RecyclableView class]);
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    view.reuseIdentifier = reuseIdentifier;
    [recycler recycleView:view];
    XCTAssertFalse(view.didReuse, @"Should not have reused this view yet.");
  }
  {
    RecyclableView* view = (RecyclableView*)[recycler dequeueReusableViewWithIdentifier:reuseIdentifier];
    XCTAssertTrue(view.didReuse, @"Should have reused this view.");
  }

  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:reuseIdentifier], @"Should be no views left.");
}

- (void)testComplexRecycling {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    view.reuseIdentifier = @"1";
    [recycler recycleView:view];
  }
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    view.reuseIdentifier = @"2";
    [recycler recycleView:view];
  }

  {
    RecyclableView* view = (RecyclableView*)[recycler dequeueReusableViewWithIdentifier:@"1"];
    XCTAssertTrue(view.didReuse, @"Should have reused this view.");
    XCTAssertTrue([view.reuseIdentifier isEqualToString:@"1"], @"Reuse identifier should be 1.");

    XCTAssertNil([recycler dequeueReusableViewWithIdentifier:@"1"], @"Should be no '1' views left.");
  }

  {
    RecyclableView* view = (RecyclableView*)[recycler dequeueReusableViewWithIdentifier:@"2"];
    XCTAssertTrue(view.didReuse, @"Should have reused this view.");
    XCTAssertTrue([view.reuseIdentifier isEqualToString:@"2"], @"Reuse identifier should be 2.");
    
    XCTAssertNil([recycler dequeueReusableViewWithIdentifier:@"2"], @"Should be no '2' views left.");
  }
}

- (void)testMemoryWarning {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  NSString* reuseIdentifier = NSStringFromClass([RecyclableView class]);
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    view.reuseIdentifier = reuseIdentifier;
    [recycler recycleView:view];
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification
                                                      object:nil
                                                    userInfo:nil];
  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:reuseIdentifier], @"Should be no views left.");
}

- (void)testRemoveAllViews {
  NIViewRecycler* recycler = [[NIViewRecycler alloc] init];
  NSString* reuseIdentifier = NSStringFromClass([RecyclableView class]);
  {
    RecyclableView* view = [[RecyclableView alloc] init];
    view.reuseIdentifier = reuseIdentifier;
    [recycler recycleView:view];
  }
  [recycler removeAllViews];
  XCTAssertNil([recycler dequeueReusableViewWithIdentifier:reuseIdentifier], @"Should be no views left.");
}

@end


@implementation RecyclableView



- (void)prepareForReuse {
  _didReuse = YES;
}

@end
