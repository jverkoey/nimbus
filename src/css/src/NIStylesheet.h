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

@protocol NICSSParserDelegate;

@interface NIStylesheet : NSObject {
@private
  NSDictionary* _rawRuleSets;
  NSMutableDictionary* _ruleSets;
  NSDictionary* _classToRuleSetMap;
}

@property (nonatomic, readonly, copy) NSDictionary* rawRuleSets;
@property (nonatomic, readonly, copy) NSDictionary* classToRuleSetMap;
@property (nonatomic, readonly, copy) NSSet* dependencies;

- (BOOL)loadFilename:(NSString *)filename relativeToPath:(NSString *)path;
- (BOOL)loadFilename:(NSString *)filename
      relativeToPath:(NSString *)path
            delegate:(id<NICSSParserDelegate>)delegate;
- (void)addStylesheet:(NIStylesheet *)stylesheet;

- (void)applyStyleToView:(UIView *)view withSelectorName:(NSString *)selectorName;

@end
