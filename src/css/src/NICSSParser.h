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

extern NSString* const kPropertyOrderKey;
extern NSString* const kDependenciesSelectorKey;

@protocol NICSSParserDelegate;

/**
 * An Objective-C wrapper for the flex CSS parser.
 *
 *      @ingroup NimbusCSS
 *
 * Generates a dictionary of raw CSS rules from a given CSS file.
 *
 * It is recommended that you do NOT use this object directly. Use NIStylesheet instead.
 *
 * Terminology note: CSS selectors are referred to as "scopes" to avoid confusion with
 * Objective-C selectors.
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

- (NSDictionary *)dictionaryForPath:(NSString *)path
                         pathPrefix:(NSString *)pathPrefix
                           delegate:(id<NICSSParserDelegate>)delegate;

- (NSDictionary *)dictionaryForPath:(NSString *)path pathPrefix:(NSString *)rootPath;
- (NSDictionary *)dictionaryForPath:(NSString *)path;

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
- (NSString *)cssParser:(NICSSParser *)parser pathFromPath:(NSString *)path;

@end

/**
 * Reads a CSS file from a given path and returns a dictionary of raw CSS rule sets.
 *
 * If a pathPrefix is provided then all paths will be prefixed with this value.
 *
 * For example, if a path prefix of "/bundle/css" is given and a CSS file has the
 * statement "@import url('user/profile.css')", the loaded file will be
 * "/bundle/css/user/profile.css".
 *
 *      @fn NICSSParser::dictionaryForPath:pathPrefix:delegate:
 *      @param path         The path of the file to be read.
 *      @param pathPrefix   [optional] A prefix path that will be prepended to the given path
 *                          as well as any imported files.
 *      @param delegate     [optional] A delegate that can reprocess paths.
 *      @returns A dictionary mapping CSS scopes to dictionaries of property names to values.
 */

/**
 *      @fn NICSSParser::dictionaryForPath:pathPrefix:
 *      @sa NICSSParser::dictionaryForPath:pathPrefix:delegate:
 */

/**
 *      @fn NICSSParser::dictionaryForPath:
 *      @sa NICSSParser::dictionaryForPath:pathPrefix:delegate:
 */

/**
 * Will be YES after retrieving a dictionary if the parser failed to parse the file in any way.
 *
 *      @fn NICSSParser::didFailToParse
 */
