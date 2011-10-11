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

#import "NIChameleonObserver.h"

#import "NIStylesheet.h"
#import "NimbusCore.h"

NSString* const NIChameleonSkinDidChangeNotification = @"NIChameleonSkinDidChangeNotification";
static NSString* const kWatchFilenameKey = @"___watch___";

@interface NISimpleDataRequest : NSObject <NSURLConnectionDataDelegate> {
@private
  NSURLConnection* _connection;
  NSMutableData* _data;
  NSURL* _url;
  id<NISimpleDataRequestDelegate> _delegate;
}
+ (id)requestWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;
- (void)send;
- (void)cancel;

@property (nonatomic, readwrite, retain) NSURL* url;
@property (nonatomic, readwrite, assign) id<NISimpleDataRequestDelegate> delegate;
@end

@implementation NISimpleDataRequest

@synthesize url = _url;
@synthesize delegate = _delegate;

- (void)dealloc {
  [_connection cancel];
  NI_RELEASE_SAFELY(_connection);
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_url);

  [super dealloc];
}

+ (id)requestWithURL:(NSURL *)url {
  return [[[self alloc] initWithURL:url] autorelease];
}

- (id)initWithURL:(NSURL *)url {
  if ((self = [super init])) {
    _url = [url retain];

    NSURLRequest* request = [NSURLRequest requestWithURL: url
                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval: 1000];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self
                                          startImmediately:NO];
    
    _data = [[NSMutableData alloc] init];
  }
  return self;
}

- (void)send {
  [_connection start];
}

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
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_connection);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if ([self.delegate respondsToSelector:@selector(requestDidFinish:withStringData:)]) {
    NSString* result = [[NSString alloc] initWithData:_data
                                             encoding:NSUTF8StringEncoding];

    [self.delegate requestDidFinish:self withStringData:result];

    NI_RELEASE_SAFELY(result);
  }
  NI_RELEASE_SAFELY(_data);
  NI_RELEASE_SAFELY(_connection);
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIChameleonObserver


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  for (NISimpleDataRequest* request in _activeRequests) {
    [request cancel];
    request.delegate = nil;
  }
  NI_RELEASE_SAFELY(_stylesheets);
  NI_RELEASE_SAFELY(_activeRequests);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _stylesheets = [[NSMutableDictionary alloc] init];
    _activeRequests = [[NSMutableArray alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadStylesheetWithFilename:(NSString *)filename {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  BOOL didSucceed = [stylesheet loadFromPath:NIPathForBundleResource(nil, filename)];

  if (didSucceed) {
    [_stylesheets setObject:stylesheet forKey:filename];

  } else {
    [_stylesheets removeObjectForKey:filename];
  }

  NI_RELEASE_SAFELY(stylesheet);
  return didSucceed;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIStylesheet *)stylesheetForFilename:(NSString *)filename {
  return [_stylesheets objectForKey:filename];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)watchSkinChanges {
  NSURL* watchURL = [NSURL URLWithString:@"http://localhost:8888/watch"];
  NISimpleDataRequest* request = [NISimpleDataRequest requestWithURL:watchURL];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadStylesheetWithFilename:(NSString *)filename {
  NSURL* fileURL = [NSURL URLWithString:[@"http://localhost:8888/" stringByAppendingString:filename]];
  NISimpleDataRequest* request = [NISimpleDataRequest requestWithURL:fileURL];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NISimpleDataRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinish:(NISimpleDataRequest *)request withStringData:(NSString *)stringData {
  if ([[request.url absoluteString] hasSuffix:@"/watch"]) {
    NSArray* files = [stringData componentsSeparatedByString:@"\n"];
    for (NSString* filename in files) {
      if (nil != [_stylesheets objectForKey:filename]) {
        [self downloadStylesheetWithFilename:filename];
      }
    }

    [self watchSkinChanges];

  } else {
    NSArray* path = [[request.url absoluteString] pathComponents];
    NSString* cssFilename = [path lastObject];
    NSString* diskPath = NIPathForDocumentsResource(cssFilename);
    NSData* data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [data writeToFile:diskPath atomically:YES];
    
    NIStylesheet* stylesheet = [_stylesheets objectForKey:cssFilename];
    if ([stylesheet loadFromPath:diskPath]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:NIChameleonSkinDidChangeNotification
                                                          object:stylesheet
                                                        userInfo:nil];
    }
    
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:diskPath error:&error];
  }
}

@end
