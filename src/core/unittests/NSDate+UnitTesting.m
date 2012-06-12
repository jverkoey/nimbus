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

#import "NSDate+UnitTesting.h"

#import "NimbusCore.h"

static NSDate* sFakeDate = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSDate (NIUnitTesting)


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)swizzleMethodsForUnitTesting {
  NISwapClassMethods([NSDate class], @selector(date), @selector(fakeDate));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)fakeDate {
  if (nil == sFakeDate) {
    // This method is meant to be swizzled, so calling fakeDate will actually call the swizzlee.
    return [self fakeDate];

  } else {
    return sFakeDate;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setFakeDate:(NSDate *)date {
  sFakeDate = date;
}


@end
