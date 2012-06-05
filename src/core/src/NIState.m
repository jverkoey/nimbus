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

#import "NIState.h"

#import "NIInMemoryCache.h"

static NIImageMemoryCache* sNimbusGlobalMemoryCache = nil;
static NSOperationQueue* sNimbusGlobalOperationQueue = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation Nimbus


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setImageMemoryCache:(NIImageMemoryCache *)imageMemoryCache {
  if (sNimbusGlobalMemoryCache != imageMemoryCache) {
    [sNimbusGlobalMemoryCache release];
    sNimbusGlobalMemoryCache = [imageMemoryCache retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIImageMemoryCache *)imageMemoryCache {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sNimbusGlobalMemoryCache = [[NIImageMemoryCache alloc] init];
  });
  
  return sNimbusGlobalMemoryCache;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setNetworkOperationQueue:(NSOperationQueue *)queue {
  if (sNimbusGlobalOperationQueue != queue) {
    [sNimbusGlobalOperationQueue release];
    sNimbusGlobalOperationQueue = [queue retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSOperationQueue *)networkOperationQueue {
  if (nil == sNimbusGlobalOperationQueue) {
    sNimbusGlobalOperationQueue = [[NSOperationQueue alloc] init];
  }
  return sNimbusGlobalOperationQueue;
}


@end
