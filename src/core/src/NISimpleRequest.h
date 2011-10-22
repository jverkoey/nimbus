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

#import <Foundation/Foundation.h>

@protocol NISimpleRequestDelegate;

/**
 * A simple network request object.
 *
 * This object is designed to be simple and light-weight. It does not cache requests, handle
 * redirecting, and many other common features found in more powerful networking objects.
 */
@interface NISimpleRequest : NSObject <NSURLConnectionDataDelegate> {
@private
  NSURLConnection* _connection;
  NSMutableData* _data;
  NSURL* _url;
  id<NISimpleRequestDelegate> _delegate;
}

+ (id)requestWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval;
- (id)initWithURL:(NSURL *)url timeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)send;
- (void)cancel;

@property (nonatomic, readwrite, retain) NSURL* url;
@property (nonatomic, readwrite, assign) id<NISimpleRequestDelegate> delegate;
@end

/**
 * The delegate for NISimpleRequest.
 */
@protocol NISimpleRequestDelegate <NSObject>
@optional

/**
 * The request failed with a given error.
 */
- (void)requestDidFail:(NISimpleRequest *)request withError:(NSError *)error;

/**
 * The request finished successfully.
 */
- (void)requestDidFinish:(NISimpleRequest *)request withData:(NSData *)data;

@end

/**
 * Returns an autoreleased request initialized with the given URL and timeout.
 *
 *      @fn NISimpleRequest::requestWithURL:timeoutInterval:
 */

/**
 * Initializes a newly allocated request with a given url and timeout.
 *
 *      @fn NISimpleRequest::initWithURL:timeoutInterval:
 */

/**
 * Initiates the NSURLConnection.
 *
 *      @fn NISimpleRequest::send
 */

/**
 * Cancels the NSURLConnection.
 *
 *      @fn NISimpleRequest::cancel
 */

/**
 * The URL this request is fetching.
 *
 *      @fn NISimpleRequest::url
 */

/**
 * This request's delegate.
 *
 *      @fn NISimpleRequest::delegate
 */
