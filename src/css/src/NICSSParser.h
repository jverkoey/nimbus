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

extern NSString* const kRulesetOrderKey;
extern NSString* const kDependenciesSelectorKey;

@protocol NICSSParserDelegate;

/**
 *
 * This object is not thread-safe.
 */
@interface NICSSParser : NSObject {
@private
  // CSS state
  NSMutableDictionary* _mutatingRuleset;
  NSMutableDictionary* _rulesets;
  NSMutableArray* _mutatingScope;
  NSMutableArray* _scopesForActiveRuleset;
  NSString* _currentPropertyName;
  NSMutableArray* _importedFilenames;

  union {
    struct {
      int InsideRuleset : 1; // Within `ruleset {...}`
      int InsideProperty : 1; // Defining a `property: ...`
      int InsideFunction : 1; // Within a `function(...)`
    } Flags;
    int _data;
  } _state;

  // Parser state
  NSString* _lastTokenText;
  int _lastToken;

  // Result state
  BOOL _didFailToParse;
}

- (NSDictionary *)dictionaryForPath:(NSString *)path;
- (NSDictionary *)dictionaryForPath:(NSString *)path pathPrefix:(NSString *)rootPath;
- (NSDictionary *)dictionaryForPath:(NSString *)path
                         pathPrefix:(NSString *)pathPrefix
                           delegate:(id<NICSSParserDelegate>)delegate;

@property (nonatomic, readonly, assign) BOOL didFailToParse;

@end

/**
 * The delegate protocol for NICSSParser.
 */
@protocol NICSSParserDelegate <NSObject>
@required

/**
 * The implementor may use this method to change the filename that will be used to load
 * the CSS file from disk.
 *
 * If nil is returned then the given filename will be used.
 *
 * Example:
 * This is used by the Chameleon observer to hash filenames with md5, effectively flattening
 * the path structure so that the files can be accessed without creating subdirectories.
 */
- (NSString *)cssParser:(NICSSParser *)parser filenameFromFilename:(NSString *)filename;

@end
