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

#import "NIFoundationMethods.h"

#import "NIDebuggingTools.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CGRect Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(NIRectContract(rect, dx, dy), dx, dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSRange Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
NSRange NIMakeNSRangeFromCFRange(CFRange range) {
  // CFRange stores its values in signed longs, but we're about to copy the values into
  // unsigned integers, let's check whether we're about to lose any information.
  NIDASSERT(range.location >= 0 && range.location <= NSIntegerMax);
  NIDASSERT(range.length >= 0 && range.length <= NSIntegerMax);
  return NSMakeRange(range.location, range.length);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General Purpose Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat boundf(CGFloat value, CGFloat min, CGFloat max) {
  if (max < min) {
    max = min;
  }
  CGFloat bounded = value;
  if (bounded > max) {
    bounded = max;
  }
  if (bounded < min) {
    bounded = min;
  }
  return bounded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSInteger boundi(NSInteger value, NSInteger min, NSInteger max) {
  if (max < min) {
    max = min;
  }
  NSInteger bounded = value;
  if (bounded > max) {
    bounded = max;
  }
  if (bounded < min) {
    bounded = min;
  }
  return bounded;
}
