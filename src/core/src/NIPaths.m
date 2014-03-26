//
// Copyright 2011-2014 NimbusKit
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import "NIPaths.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NSString* NIPathForBundleResource(NSBundle* bundle, NSString* relativePath) {
  NSString* resourcePath = [(nil == bundle ? [NSBundle mainBundle] : bundle) resourcePath];
  return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* NIPathForDocumentsResource(NSString* relativePath) {
  static NSString* documentsPath = nil;
  if (nil == documentsPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                        NSUserDomainMask,
                                                        YES);
    documentsPath = [dirs objectAtIndex:0];
  }
  return [documentsPath stringByAppendingPathComponent:relativePath];
}

NSString* NIPathForLibraryResource(NSString* relativePath) {
  static NSString* libraryPath = nil;
  if (nil == libraryPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                        NSUserDomainMask,
                                                        YES);
    libraryPath = [dirs objectAtIndex:0];
  }
  return [libraryPath stringByAppendingPathComponent:relativePath];
}

NSString* NIPathForCachesResource(NSString* relativePath) {
  static NSString* cachesPath = nil;
  if (nil == cachesPath) {
    NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                        NSUserDomainMask,
                                                        YES);
    cachesPath = [dirs objectAtIndex:0];
  }
  return [cachesPath stringByAppendingPathComponent:relativePath];
}
