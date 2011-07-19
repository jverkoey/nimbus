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

#import "NIJSONHTTPProcessor.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIJSONHTTPRequest

@synthesize rootObject = _rootObject;
@synthesize processorDelegate = _processorDelegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_rootObject);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestStarted {
  NI_RELEASE_SAFELY(_rootObject);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished {
  NSData* responseData = [self responseData];

  _rootObject = [[JSONDecoder decoder] objectWithData:responseData];
  responseData = nil;

  // Release the raw response data immediately.
  [self setRawResponseData:nil];

  if ([_processorDelegate respondsToSelector:@selector(request:processRootObject:)]) {
    _rootObject = [[_processorDelegate request:self processRootObject:_rootObject] retain];

  } else {
    _rootObject = nil;
  }

  [super requestFinished];
}


@end
