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

#import "NINonEmptyCollectionTesting.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

BOOL NIIsArrayWithObjects(id object) {
  return [object isKindOfClass:[NSArray class]] && [(NSArray*)object count] > 0;
}

BOOL NIIsSetWithObjects(id object) {
  return [object isKindOfClass:[NSSet class]] && [(NSSet*)object count] > 0;
}

BOOL NIIsStringWithAnyText(id object) {
  return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}
