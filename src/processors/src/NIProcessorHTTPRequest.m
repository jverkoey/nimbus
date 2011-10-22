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

#import "NIProcessorHTTPRequest.h"

#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIProcessorHTTPRequest

@synthesize processedObject = _processedObject;
@synthesize processorDelegate = _processorDelegate;
#if NS_BLOCKS_AVAILABLE
@synthesize processDataBlock = _processDataBlock;
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestStarted {
  _processedObject = nil;

  [super requestStarted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectFromResponseData:(NSData *)data error:(NSError **)error {
  // Do nothing in the base implementation. Subclasses should implement this method and
  // do something more interesting.
  return data;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished {
  NSData* responseData = [self responseData];

  // First, let the subclass process the data.
  NSError* processingError = nil;
  _processedObject = [self objectFromResponseData:responseData error:&processingError];

  // Release the raw response data immediately.
  [self setRawResponseData:nil];
  responseData = nil;

#if NS_BLOCKS_AVAILABLE
  // Second, let the block further chew on the data.
  if (nil != self.processDataBlock) {
    _processedObject = self.processDataBlock(_processedObject, &processingError);
  }
#endif

  // Third, let the delegate process the data last.
  if ([_processorDelegate respondsToSelector:@selector(processor:processObject:error:)]) {
    id oldObject = _processedObject;
    _processedObject = [_processorDelegate processor: self
                                        processObject: oldObject
                                                error: &processingError];
  }

  [super requestFinished];
}


@end
