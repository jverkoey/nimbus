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

#import <Foundation/Foundation.h>

@class NIStylesheet;

@interface NIDOM : NSObject {
@private
  NIStylesheet* _stylesheet;
  NSMutableSet* _registeredViews;
  NSMutableDictionary* _viewToSelectorsMap;
}

// Designated initializer.
- (id)initWithStylesheet:(NIStylesheet *)stylesheet;

+ (id)domWithStylesheet:(NIStylesheet *)stylesheet;
+ (id)domWithStylesheetRootPath:(NSString *)rootPath filenames:(NSString *)stylesheetPath, ...;

- (void)registerView:(UIView *)view;
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass;
- (void)unregisterView:(UIView *)view;
- (void)refresh;

@end
