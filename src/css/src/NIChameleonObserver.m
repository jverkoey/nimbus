//
// Copyright 2011-2014 NimbusKit
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
#import "NIUserInterfaceString.h"
#import "NimbusCore+Additions.h"
#import "AFNetworking.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static NSString* const kWatchFilenameKey = @"___watch___";
static const NSTimeInterval kTimeoutInterval = 1000;
static const NSTimeInterval kRetryInterval = 10000;
static const NSInteger kMaxNumberOfRetries = 3;

NSString* const NIJSONDidChangeNotification = @"NIJSONDidChangeNotification";
NSString* const NIJSONDidChangeFilePathKey = @"NIJSONPathKey";
NSString* const NIJSONDidChangeNameKey = @"NIJSONNameKey";

@interface NIChameleonObserver() <
    NSNetServiceBrowserDelegate,
    NSNetServiceDelegate
>
- (NSString *)pathFromPath:(NSString *)path;
@property (nonatomic,strong) NSNetServiceBrowser *netBrowser;
@property (nonatomic,strong) NSNetService *netService;
@end

@implementation NIChameleonObserver


- (void)dealloc {
  [_queue cancelAllOperations];
}

- (id)initWithStylesheetCache:(NIStylesheetCache *)stylesheetCache host:(NSString *)host {
  if ((self = [super init])) {
    // You must provide a stylesheet cache.
    NIDASSERT(nil != stylesheetCache);
    _stylesheetCache = stylesheetCache;
    _stylesheetPaths = [[NSMutableArray alloc] init];
    _queue = [[NSOperationQueue alloc] init];

    if ([host hasSuffix:@"/"]) {
      _host = [host copy];

    } else if (host) {
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

- (void)downloadStylesheetWithFilename:(NSString *)path {
  NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:path]];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

  AFHTTPRequestOperation* requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];

  [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSMutableArray* changedStylesheets = [NSMutableArray array];
    NSArray* pathParts = [[operation.request.URL absoluteString] pathComponents];
    NSString* resultPath = [[pathParts subarrayWithRange:NSMakeRange(2, [pathParts count] - 2)]
                            componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* hashedPath = [self pathFromPath:resultPath];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:hashedPath];
    [responseObject writeToFile:diskPath atomically:YES];
    
    NIStylesheet* stylesheet = [_stylesheetCache stylesheetWithPath:resultPath loadFromDisk:NO];
    if ([stylesheet loadFromPath:resultPath pathPrefix:rootPath delegate:self]) {
      [changedStylesheets addObject:stylesheet];
    }
    
    for (NSString* iteratingPath in _stylesheetPaths) {
      stylesheet = [_stylesheetCache stylesheetWithPath:iteratingPath loadFromDisk:NO];
      if ([stylesheet.dependencies containsObject:resultPath]) {
        // This stylesheet has the changed stylesheet as a dependency so let's refresh it.
        if ([stylesheet loadFromPath:iteratingPath pathPrefix:rootPath delegate:self]) {
          [changedStylesheets addObject:stylesheet];
        }
      }
    }

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    for (NIStylesheet* changedStylesheet in changedStylesheets) {
      [nc postNotificationName:NIStylesheetDidChangeNotification
                        object:changedStylesheet
                      userInfo:nil];
    }

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
  [_queue addOperation:requestOp];
}

- (void)downloadStringsWithFilename:(NSString *)path {
  NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:path]];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  
  AFHTTPRequestOperation* requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSArray* pathParts = [[operation.request.URL absoluteString] pathComponents];
    NSString* resultPath = [[pathParts subarrayWithRange:NSMakeRange(2, [pathParts count] - 2)]
                            componentsJoinedByString:@"/"];
    NSString* rootPath = NIPathForDocumentsResource(nil);
    NSString* hashedPath = [self pathFromPath:resultPath];
    NSString* diskPath = [rootPath stringByAppendingPathComponent:hashedPath];
    [responseObject writeToFile:diskPath atomically:YES];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:NIStringsDidChangeNotification object:nil userInfo:@{
        NIStringsDidChangeFilePathKey: diskPath
     }];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
  }];
  [_queue addOperation:requestOp];
}

- (void)downloadJSONWithFilename:(NSString *)path {
    NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:path]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation* requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray* pathParts = [[operation.request.URL absoluteString] pathComponents];
        NSString* resultPath = [[pathParts subarrayWithRange:NSMakeRange(2, [pathParts count] - 2)]
                                componentsJoinedByString:@"/"];
        NSString* rootPath = NIPathForDocumentsResource(nil);
        NSString* hashedPath = [self pathFromPath:resultPath];
        NSString* diskPath = [rootPath stringByAppendingPathComponent:hashedPath];
        [responseObject writeToFile:diskPath atomically:YES];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:NIJSONDidChangeNotification object:nil userInfo:@{
            NIJSONDidChangeFilePathKey: diskPath,
            NIJSONDidChangeNameKey: path
         }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    [_queue addOperation:requestOp];
}

- (NSString *)pathFromPath:(NSString *)path {
  return NIMD5HashFromString(path);
}

#pragma mark - NICSSParserDelegate


- (NSString *)cssParser:(NICSSParser *)parser pathFromPath:(NSString *)path {
  return [self pathFromPath:path];
}

#pragma mark - Public


- (NIStylesheet *)stylesheetForPath:(NSString *)path {
  return [_stylesheetCache stylesheetWithPath:path];
}

- (void)watchSkinChanges {
  NSURL* url = [NSURL URLWithString:[_host stringByAppendingString:@"watch"]];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  request.timeoutInterval = kTimeoutInterval;
  AFHTTPRequestOperation* requestOp = [[AFHTTPRequestOperation alloc] initWithRequest:request];

  [requestOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSString* stringData = [[NSString alloc] initWithData:responseObject
                                                 encoding:NSUTF8StringEncoding];

    NSArray* files = [stringData componentsSeparatedByString:@"\n"];
    for (NSString* filename in files) {
      if ([[filename lowercaseString] hasSuffix:@".strings"]) {
        [self downloadStringsWithFilename: filename];
      } else if ([[filename lowercaseString] hasSuffix:@".json"]) {
        [self downloadJSONWithFilename:filename];
      } else {
        [self downloadStylesheetWithFilename:filename];
      }
    }

    // Immediately start watching for more skin changes.
    _retryCount = 0;
    [self watchSkinChanges];

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    if (_retryCount < kMaxNumberOfRetries) {
      ++_retryCount;
      
      dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRetryInterval * NSEC_PER_MSEC));
      dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self watchSkinChanges];
      });
    }
  }];

  [_queue addOperation:requestOp];
}

-(void)enableBonjourDiscovery:(NSString *)serviceName
{
    self.netBrowser = [[NSNetServiceBrowser alloc] init];
    self.netBrowser.delegate = self;
    [self.netBrowser searchForServicesOfType:[NSString stringWithFormat:@"_%@._tcp", serviceName] inDomain:@""];
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.netBrowser stop];
    self.netBrowser = nil;

    self.netService = aNetService;
    aNetService.delegate = self;
    [aNetService resolveWithTimeout:15.0];
}

-(void)netServiceDidResolveAddress:(NSNetService *)sender
{
    _host = [NSString stringWithFormat:@"http://%@:%zd/", [sender hostName], [sender port]];
    self.netService = nil;
    [self watchSkinChanges];
}

@end
