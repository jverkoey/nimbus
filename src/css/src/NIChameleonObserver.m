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
static const NSTimeInterval kTimeoutInterval = 1000;
static const NSInteger kMaxNumberOfRetries = 3;

@interface NIChameleonObserver()
- (BOOL)loadStylesheetWithFilename:(NSString *)filename;
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
  NI_RELEASE_SAFELY(_stylesheets);
  NI_RELEASE_SAFELY(_activeRequests);
  NI_RELEASE_SAFELY(_pathPrefix);
  NI_RELEASE_SAFELY(_host);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPathPrefix:(NSString *)pathPrefix host:(NSString *)host {
  if ((self = [super init])) {
    _pathPrefix = [pathPrefix copy];
    _stylesheets = [[NSMutableDictionary alloc] init];
    _activeRequests = [[NSMutableArray alloc] init];

    if ([host hasSuffix:@"/"]) {
      _host = [host copy];

    } else {
      _host = [[host stringByAppendingString:@"/"] copy];
    }

    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* de = [fm enumeratorAtPath:pathPrefix];

    NSString* filename;
    while ((filename = [de nextObject])) {
      BOOL isFolder = NO;
      NSString* path = [pathPrefix stringByAppendingPathComponent:filename];
      if ([fm fileExistsAtPath:path isDirectory:&isFolder]
          && !isFolder
          && [[filename pathExtension] isEqualToString:@"css"]) {
        NSString* cachePath = NIPathForDocumentsResource([filename md5Hash]);
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
- (BOOL)loadStylesheetWithFilename:(NSString *)filename {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  BOOL didSucceed = [stylesheet loadFromPath:filename
                                  pathPrefix:_pathPrefix];

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
  if (nil == [_stylesheets objectForKey:filename]) {
    [self loadStylesheetWithFilename:filename];
  }
  return [_stylesheets objectForKey:filename];
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadStylesheetWithFilename:(NSString *)filename {
  NSURL* fileURL = [NSURL URLWithString:[_host stringByAppendingString:filename]];
  NISimpleRequest* request = [NISimpleRequest requestWithURL:fileURL
                                             timeoutInterval:kTimeoutInterval];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
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
    NSArray* path = [[request.url absoluteString] pathComponents];
    NSString* cssFilename = [[path subarrayWithRange:NSMakeRange(2, [path count] - 2)]
                             componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* filename = [cssFilename md5Hash];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:filename];
    [data writeToFile:diskPath atomically:YES];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    NIStylesheet* stylesheet = [_stylesheets objectForKey:cssFilename];
    if ([stylesheet loadFromPath:cssFilename pathPrefix:rootPath delegate:self]) {
      [nc postNotificationName:NIChameleonSkinDidChangeNotification
                        object:stylesheet
                      userInfo:nil];
    }
    for (NSString* pathKey in _stylesheets) {
      stylesheet = [_stylesheets objectForKey:pathKey];
      if ([stylesheet.dependencies containsObject:cssFilename]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFromPath:pathKey pathPrefix:rootPath delegate:self]) {
          [nc postNotificationName:NIChameleonSkinDidChangeNotification
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
  return [path md5Hash];
}


@end
