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
  [_operations cancelAllOperations];
  NI_RELEASE_SAFELY(_stylesheetCache);
  NI_RELEASE_SAFELY(_stylesheetPaths);
  NI_RELEASE_SAFELY(_operations);
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
    _operations = [[NSOperationQueue alloc] init];

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
        error = nil;
        [fm copyItemAtPath:path toPath:cachePath error:&error];
        NIDASSERT(nil == error);
      }
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadStylesheetWithFilename:(NSString *)path {
  NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:path]];
  NINetworkRequestOperation* op = [[[NINetworkRequestOperation alloc] initWithURL:url] autorelease];
  op.delegate = self;
  [_operations addOperation:op];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)pathFromPath:(NSString *)path {
  return [path md5Hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIOperationDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFail:(NSOperation *)operation withError:(NSError *)error {
  if (_retryCount < kMaxNumberOfRetries) {
    ++_retryCount;

    [self watchSkinChanges];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationWillFinish:(NINetworkRequestOperation *)operation {
  if (![operation.url.path isEqualToString:@"/watch"]) {
    NSMutableArray* changedStylesheets = [NSMutableArray array];
    NSArray* pathParts = [[operation.url absoluteString] pathComponents];
    NSString* path = [[pathParts subarrayWithRange:NSMakeRange(2, [pathParts count] - 2)]
                      componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* hashedPath = [self pathFromPath:path];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:hashedPath];
    [operation.data writeToFile:diskPath atomically:YES];

    NIStylesheet* stylesheet = [_stylesheetCache stylesheetWithPath:path loadFromDisk:NO];
    if ([stylesheet loadFromPath:path pathPrefix:rootPath delegate:self]) {
      [changedStylesheets addObject:stylesheet];
    }
    
    for (NSString* iteratingPath in _stylesheetPaths) {
      stylesheet = [_stylesheetCache stylesheetWithPath:iteratingPath loadFromDisk:NO];
      if ([stylesheet.dependencies containsObject:path]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFromPath:iteratingPath pathPrefix:rootPath delegate:self]) {
          [changedStylesheets addObject:stylesheet];
        }
      }
    }

    operation.processedObject = changedStylesheets;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)nimbusOperationDidFinish:(NINetworkRequestOperation *)operation {
  if ([operation.url.path isEqualToString:@"/watch"]) {
    NSString* stringData = [[[NSString alloc] initWithData:operation.data
                                                  encoding:NSUTF8StringEncoding] autorelease];

    NSArray* files = [stringData componentsSeparatedByString:@"\n"];
    for (NSString* filename in files) {
      [self downloadStylesheetWithFilename:filename];
    }

    // Immediately start watching for more skin changes.
    [self watchSkinChanges];

  } else {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    for (NIStylesheet* stylesheet in operation.processedObject) {
      [nc postNotificationName:NIStylesheetDidChangeNotification
                        object:stylesheet
                      userInfo:nil];
    }
  }
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
  NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:@"watch"]];
  NINetworkRequestOperation* op = [[[NINetworkRequestOperation alloc] initWithURL:url] autorelease];
  op.delegate = self;
  op.timeout = kTimeoutInterval;
  [_operations addOperation:op];
}


@end
