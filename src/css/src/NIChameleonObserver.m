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
  NI_RELEASE_SAFELY(_rootFolder);
  NI_RELEASE_SAFELY(_host);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRootFolder:(NSString *)rootFolder host:(NSString *)host {
  if ((self = [super init])) {
    _rootFolder = [rootFolder copy];
    _stylesheets = [[NSMutableDictionary alloc] init];
    _activeRequests = [[NSMutableArray alloc] init];
    if ([host hasSuffix:@"/"]) {
      _host = [host copy];

    } else {
      _host = [[host stringByAppendingString:@"/"] copy];
    }

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
      }
    }
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadStylesheetWithFilename:(NSString *)filename {
  NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
  BOOL didSucceed = [stylesheet loadFromPath:filename
                                  pathPrefix:NIPathForBundleResource(nil, _rootFolder)];

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
  NISimpleRequest* request = [NISimpleRequest requestWithURL:watchURL];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)downloadStylesheetWithFilename:(NSString *)filename {
  NSURL* fileURL = [NSURL URLWithString:[_host stringByAppendingString:filename]];
  NISimpleRequest* request = [NISimpleRequest requestWithURL:fileURL];
  request.delegate = self;
  [_activeRequests addObject:request];
  [request send];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NISimpleDataRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinish:(NISimpleRequest *)request withStringData:(NSString *)stringData {
  if ([[request.url absoluteString] hasSuffix:@"/watch"]) {
    NSArray* files = [stringData componentsSeparatedByString:@"\n"];
    for (NSString* filename in files) {
      [self downloadStylesheetWithFilename:filename];
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
    if ([stylesheet loadFromPath:cssFilename pathPrefix:rootPath delegate:self]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:NIChameleonSkinDidChangeNotification
                                                          object:stylesheet
                                                        userInfo:nil];
    }
    for (NSString* pathKey in _stylesheets) {
      stylesheet = [_stylesheets objectForKey:pathKey];
      if ([stylesheet.dependencies containsObject:cssFilename]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFromPath:pathKey pathPrefix:rootPath delegate:self]) {
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
- (NSString *)cssParser:(NICSSParser *)parser pathFromPath:(NSString *)path {
  return [path md5Hash];
}


@end
