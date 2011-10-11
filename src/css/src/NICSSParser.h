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

extern NSString* const kRuleSetOrderKey;
extern NSString* const kDependenciesSelectorKey;

@class NICSSParser;

@protocol NICSSParserDelegate <NSObject>
@required
- (NSString *)cssParser:(NICSSParser *)parser filenameFromFilename:(NSString *)filename;
@end

@interface NICSSParser : NSObject {
@private
  NSMutableDictionary* _ruleSets;
  NSMutableArray* _currentSelector;
  NSMutableArray* _activeCssSelectors;
  NSMutableDictionary* _activeRuleSet;
  NSString* _activePropertyName;
  NSMutableArray* _importedFilenames;

  NSString* _lastTokenText;
  int _lastToken;

  BOOL _didFailToParse;

  union {
    struct {
      int InsideRuleSet : 1; // Within `ruleset {...}`
      int InsideProperty : 1; // Defining a `property: ...`
      int InsideFunction : 1; // Within a `function(...)`
    } Flags;
    int _data;
  } _state;
}

- (NSDictionary *)rulesetsForCSSRelativeFilename:(NSString *)relFilename
                                        rootPath:(NSString *)rootPath;

- (NSDictionary *)rulesetsForCSSRelativeFilename:(NSString *)relFilename
                                        rootPath:(NSString *)rootPath
                                        delegate:(id<NICSSParserDelegate>)delegate;

@property (nonatomic, readonly, assign) BOOL didFailToParse;

@end


