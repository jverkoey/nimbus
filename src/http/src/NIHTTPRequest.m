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

#import "NIHTTPRequest.h"

#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIHTTPRequest


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)initialize {
  // Disable ASIHTTPRequest's network activity indicator logic because it doesn't play nice with
  // Nimbus' network activity logic.
  [ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  // Sometimes the request will be deallocated before it completes or fails, so let's be sure
  // we clear out the network indicator before we go away.
  if (_didStartNetworkRequest) {
    NINetworkActivityTaskDidFinish();
    _didStartNetworkRequest = NO;
  }

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestStarted {
  // Only show the network indicator while a network request is within a request.
  // By default, ASIHTTPRequest enables the network indicator any time a request thread is
  // running which makes it appear that more network activity is occurring than there actually
  // is.
  if (!_didStartNetworkRequest) {
    _didStartNetworkRequest = YES;
    NINetworkActivityTaskDidStart();
  }

  [super requestStarted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestFinished {
  if (_didStartNetworkRequest) {
    NINetworkActivityTaskDidFinish();
    _didStartNetworkRequest = NO;
  }

  [super requestFinished];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)failWithError:(NSError *)theError {
  if (_didStartNetworkRequest) {
    NINetworkActivityTaskDidFinish();
    _didStartNetworkRequest = NO;
  }

  [super failWithError:theError];
}


@end
