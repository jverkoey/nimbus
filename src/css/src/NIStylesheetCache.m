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

#import "NIStylesheetCache.h"

#import "NIStylesheet.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@implementation NIStylesheetCache



- (id)initWithPathPrefix:(NSString *)pathPrefix {
  if ((self = [super init])) {
    _pathToStylesheet = [[NSMutableDictionary alloc] init];
    _pathPrefix = [pathPrefix copy];
  }
  return self;
}

- (id)init {
  // This method should not be called directly.
  NIDASSERT(NO);
  return [self initWithPathPrefix:nil];
}

- (NIStylesheet *)stylesheetWithPath:(NSString *)path loadFromDisk:(BOOL)loadFromDisk {
  NIStylesheet* stylesheet = [_pathToStylesheet objectForKey:path];

  if (nil == stylesheet) {
    stylesheet = [[NIStylesheet alloc] init];
    if (loadFromDisk) {
      BOOL didSucceed = [stylesheet loadFromPath:path
                                      pathPrefix:_pathPrefix];

      if (didSucceed) {
        [_pathToStylesheet setObject:stylesheet forKey:path];

      } else {
        [_pathToStylesheet removeObjectForKey:path];
        stylesheet = nil;
      }

    } else {
      [_pathToStylesheet setObject:stylesheet forKey:path];
    }
  }
  
  return stylesheet;
}

- (NIStylesheet *)stylesheetWithPath:(NSString *)path {
  return [self stylesheetWithPath:path loadFromDisk:YES];
}

@end
