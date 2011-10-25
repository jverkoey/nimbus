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

#import "NISimpleRequest.h"

#import "NIPreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISimpleRequest

@synthesize url = _url;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_connection cancel];
  NI_RELEASE_SAFELY(_connection);
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_url);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)requestWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval {
  return [[[self alloc] initWithURL:url timeoutInterval:timeoutInterval] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval {
  if ((self = [super init])) {
    _url = [url retain];

    NSURLRequest* request = [NSURLRequest requestWithURL: url
                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval: timeoutInterval];

    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self
                                          startImmediately:NO];
    
    _data = [[NSMutableData alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)send {
  [_connection start];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  [_connection cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSURLConnectionDataDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [_data setLength:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [_data appendData:data];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if ([self.delegate respondsToSelector:@selector(requestDidFail:withError:)]) {
    [self.delegate requestDidFail:self withError:error];
  }
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_connection);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if ([self.delegate respondsToSelector:@selector(requestDidFinish:withData:)]) {
    [self.delegate requestDidFinish:self withData:_data];
  }
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_connection);
}

@end
