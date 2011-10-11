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
#import "NimbusCore+Additions.h"

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


@interface NIChameleonObserver()

- (BOOL)loadStylesheetWithFilename:(NSString *)filename;

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
  NI_RELEASE_SAFELY(_rootFolder);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRootFolder:(NSString *)rootFolder {
  if ((self = [super init])) {
    _rootFolder = [rootFolder copy];
    _stylesheets = [[NSMutableDictionary alloc] init];
    _activeRequests = [[NSMutableArray alloc] init];

    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* bundleRootPath = NIPathForBundleResource(nil, rootFolder);
    NSDirectoryEnumerator* de = [fm enumeratorAtPath:bundleRootPath];

    NSString* filename;
    while ((filename = [de nextObject])) {
      if ([[filename pathExtension] isEqualToString:@"css"]) {
        NSString* cachePath = NIPathForDocumentsResource([filename md5Hash]);
        NSError* error = nil;
        [fm removeItemAtPath:cachePath error:&error];
        [fm copyItemAtPath:[bundleRootPath stringByAppendingPathComponent:filename]
                    toPath:cachePath error:&error];

        [self loadStylesheetWithFilename:filename];
      }
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadStylesheetWithFilename:(NSString *)filename {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  BOOL didSucceed = [stylesheet loadFilename:filename
                              relativeToPath:NIPathForBundleResource(nil, _rootFolder)];

  if (didSucceed) {
    [_stylesheets setObject:stylesheet forKey:filename];

  } else {
    NIDASSERT(NO);
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
    NSString* cssFilename = [[path subarrayWithRange:NSMakeRange(2, [path count] - 2)] componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* filename = [cssFilename md5Hash];
    NSData* data = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:filename];
    [data writeToFile:diskPath atomically:YES];

    NIStylesheet* stylesheet = [_stylesheets objectForKey:cssFilename];
    if ([stylesheet loadFilename:cssFilename relativeToPath:rootPath delegate:self]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:NIChameleonSkinDidChangeNotification
                                                          object:stylesheet
                                                        userInfo:nil];
    }
    for (NSString* pathKey in _stylesheets) {
      NIStylesheet* stylesheet = [_stylesheets objectForKey:pathKey];
      if ([stylesheet.dependencies containsObject:cssFilename]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFilename:pathKey relativeToPath:rootPath delegate:self]) {
          [[NSNotificationCenter defaultCenter] postNotificationName:NIChameleonSkinDidChangeNotification
                                                              object:stylesheet
                                                            userInfo:nil];
        }
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NICSSParserDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cssParser:(NICSSParser *)parser filenameFromFilename:(NSString *)filename {
  return [filename md5Hash];
}


@end
