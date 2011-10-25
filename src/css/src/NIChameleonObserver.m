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
#import "NIStylesheetCache.h"
#import "NimbusCore+Additions.h"

static NSString* const kWatchFilenameKey = @"___watch___";
static const NSTimeInterval kTimeoutInterval = 1000;
static const NSInteger kMaxNumberOfRetries = 3;

@interface NIChameleonObserver()
- (NSString *)pathFromPath:(NSString *)path;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIChameleonObserver


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  for (NISimpleRequest* request in _activeRequests) {
    [request cancel];
    request.delegate = nil;
  }
  NI_RELEASE_SAFELY(_stylesheetCache);
  NI_RELEASE_SAFELY(_stylesheetPaths);
  NI_RELEASE_SAFELY(_activeRequests);
  NI_RELEASE_SAFELY(_host);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStylesheetCache:(NIStylesheetCache *)stylesheetCache host:(NSString *)host {
  if ((self = [super init])) {
    // You must provide a stylesheet cache.
    NIDASSERT(nil != stylesheetCache);
    _stylesheetCache = [stylesheetCache retain];
    _stylesheetPaths = [[NSMutableArray alloc] init];
    _activeRequests = [[NSMutableArray alloc] init];

    if ([host hasSuffix:@"/"]) {
      _host = [host copy];

    } else {
      _host = [[host stringByAppendingString:@"/"] copy];
    }

    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* de = [fm enumeratorAtPath:_stylesheetCache.pathPrefix];

    NSString* filename;
    while ((filename = [de nextObject])) {
      BOOL isFolder = NO;
      NSString* path = [_stylesheetCache.pathPrefix stringByAppendingPathComponent:filename];
      if ([fm fileExistsAtPath:path isDirectory:&isFolder]
          && !isFolder
          && [[filename pathExtension] isEqualToString:@"css"]) {
        [_stylesheetPaths addObject:filename];
        NSString* cachePath = NIPathForDocumentsResource([self pathFromPath:filename]);
        NSError* error = nil;
        [fm removeItemAtPath:cachePath error:&error];
        [fm copyItemAtPath:path toPath:cachePath error:&error];
        NIDASSERT(nil == error);
      }
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadStylesheetWithFilename:(NSString *)path {
  NSURL* fileURL = [NSURL URLWithString:[_host stringByAppendingString:path]];
  NISimpleRequest* request = [NISimpleRequest requestWithURL:fileURL
                                             timeoutInterval:kTimeoutInterval];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)pathFromPath:(NSString *)path {
  return [path md5Hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NISimpleRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFail:(NISimpleRequest *)request withError:(NSError *)error {
  if (_retryCount < kMaxNumberOfRetries) {
    ++_retryCount;

    [self watchSkinChanges];
  }

  [_activeRequests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinish:(NISimpleRequest *)request withData:(NSData *)data {
  NSString* stringData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                          autorelease];
  if ([request.url.path isEqualToString:@"/watch"]) {
    NSArray* files = [stringData componentsSeparatedByString:@"\n"];
    for (NSString* filename in files) {
      [self downloadStylesheetWithFilename:filename];
    }

    // Immediately start watching for more skin changes.
    [self watchSkinChanges];

  } else {
    NSArray* pathParts = [[request.url absoluteString] pathComponents];
    NSString* path = [[pathParts subarrayWithRange:NSMakeRange(2, [pathParts count] - 2)]
                      componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* hashedPath = [self pathFromPath:path];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:hashedPath];
    [data writeToFile:diskPath atomically:YES];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    NIStylesheet* stylesheet = [_stylesheetCache stylesheetWithPath:path loadFromDisk:NO];
    if ([stylesheet loadFromPath:path pathPrefix:rootPath delegate:self]) {
      [nc postNotificationName:NIStylesheetDidChangeNotification
                        object:stylesheet
                      userInfo:nil];
    }
    for (NSString* iteratingPath in _stylesheetPaths) {
      stylesheet = [_stylesheetCache stylesheetWithPath:iteratingPath loadFromDisk:NO];
      if ([stylesheet.dependencies containsObject:path]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFromPath:iteratingPath pathPrefix:rootPath delegate:self]) {
          [nc postNotificationName:NIStylesheetDidChangeNotification
                            object:stylesheet
                          userInfo:nil];
        }
      }
    }
  }

  [_activeRequests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NICSSParserDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)cssParser:(NICSSParser *)parser pathFromPath:(NSString *)path {
  return [self pathFromPath:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIStylesheet *)stylesheetForPath:(NSString *)path {
  return [_stylesheetCache stylesheetWithPath:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)watchSkinChanges {
  NSURL* watchURL = [NSURL URLWithString:[_host stringByAppendingString:@"watch"]];
  NISimpleRequest* request = [NISimpleRequest requestWithURL:watchURL
                                             timeoutInterval:kTimeoutInterval];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


@end
