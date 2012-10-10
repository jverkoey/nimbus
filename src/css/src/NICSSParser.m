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

#import "NICSSParser.h"

#import "CSSTokens.h"
#import "NimbusCore.h"

#import <pthread.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static pthread_mutex_t gMutex = PTHREAD_MUTEX_INITIALIZER;
NSString* const kPropertyOrderKey = @"__kRuleSetOrder__";
NSString* const kDependenciesSelectorKey = @"__kDependencies__";

// Damn you, flex. Due to the nature of flex we can only have one active parser at any given time.
NICSSParser* gActiveParser = nil;

int cssConsume(char* text, int token);
@interface NICSSParser()
- (void)consumeToken:(int)token text:(char*)text;
@end

// The entry point of the flex css parser.
// Flex is inherently designed to operate as a singleton.
int cssConsume(char* text, int token) {
  [gActiveParser consumeToken:token text:text];
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICSSParser

@synthesize didFailToParse = _didFailToParse;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shutdown {
  _rulesets = nil;
  _scopesForActiveRuleset = nil;
  _mutatingScope = nil;
  _mutatingRuleset = nil;
  _currentPropertyName = nil;
  _importedFilenames = nil;
  _lastTokenText = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFailFlag {
  if (!self.didFailToParse) {
    _didFailToParse = YES;

    [self shutdown];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)commitCurrentSelector {
  [_scopesForActiveRuleset addObject:[_mutatingScope componentsJoinedByString:@" "]];
  [_mutatingScope removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)consumeToken:(int)token text:(char*)text {
  if (_didFailToParse) {
    return;
  }

  NSString* textAsString = [[NSString alloc] initWithCString:text encoding:NSUTF8StringEncoding];
  NSString* lowercaseTextAsString = [textAsString lowercaseString];

  switch (token) {
    case CSSHASH: // #{name}
    case CSSIDENT: { // {ident}(:{ident})?

      if (_state.Flags.InsideRuleset) {
        NIDASSERT(nil != _mutatingRuleset);
        if (nil == _mutatingRuleset) {
          [self setFailFlag];
        }

        // Treat CSSIDENT as a new property if we're not already defining one.
        if (CSSIDENT == token && !_state.Flags.InsideProperty) {
          // Properties are case insensitive.
          _currentPropertyName = lowercaseTextAsString;
          
          NSMutableArray* ruleSetOrder = [_mutatingRuleset objectForKey:kPropertyOrderKey];
          [ruleSetOrder addObject:_currentPropertyName];

          // Clear any existing values for the given property.
          NSMutableArray* values = [[NSMutableArray alloc] init];
          [_mutatingRuleset setObject:values forKey:_currentPropertyName];

        } else {
          // This is a value for the active property; add it.
          NIDASSERT(nil != _currentPropertyName);

          if (nil != _currentPropertyName) {
            NSMutableArray* values = [_mutatingRuleset objectForKey:_currentPropertyName];
            [values addObject:lowercaseTextAsString];

          } else {
            [self setFailFlag];
          }
        }

      } else { // if not inside a rule set...
        [_mutatingScope addObject:textAsString];

        // Ensure that we're not modifying a property.
        _currentPropertyName = nil;
      }
      break;
    }

    case CSSFUNCTION: {
      // Functions can only exist within properties.
      if (_state.Flags.InsideProperty) {
        _state.Flags.InsideFunction = YES;

        NIDASSERT(nil != _currentPropertyName);
        if (nil != _currentPropertyName) {
          NSMutableArray* values = [_mutatingRuleset objectForKey:_currentPropertyName];
          [values addObject:lowercaseTextAsString];

        } else {
          [self setFailFlag];
        }
      }
      break;
    }

    case CSSSTRING:
    case CSSEMS:
    case CSSEXS:
    case CSSLENGTH:
    case CSSANGLE:
    case CSSTIME:
    case CSSFREQ:
    case CSSDIMEN:
    case CSSPERCENTAGE:
    case CSSNUMBER:
    case CSSURI: {
      if (_lastToken == CSSIMPORT && token == CSSURI) {
        NSInteger prefixLength = @"url(\"".length;
        NSString* filename = [textAsString substringWithRange:NSMakeRange(prefixLength,
                                                                          textAsString.length
                                                                          - prefixLength - 2)];
        [_importedFilenames addObject:filename];

      } else {
        NIDASSERT(nil != _currentPropertyName);

        if (nil != _currentPropertyName) {
          NSMutableArray* values = [_mutatingRuleset objectForKey:_currentPropertyName];
          [values addObject:textAsString];

        } else {
          [self setFailFlag];
        }
      }
      break;
    }

    // Parse individual characters.
    case CSSUNKNOWN: {
      switch (text[0]) {

        // Commit the current selector and start a new one.
        case ',': {
          if (!_state.Flags.InsideRuleset) {
            [self commitCurrentSelector];
          }
          break;
        }

        // Start a new rule set.
        case '{': {
          NIDASSERT(nil != _mutatingScope);
          if ([_mutatingScope count] > 0
              && !_state.Flags.InsideRuleset && !_state.Flags.InsideFunction) {
            [self commitCurrentSelector];

            _state.Flags.InsideRuleset = YES;
            _state.Flags.InsideFunction = NO;

            _mutatingRuleset = [[NSMutableDictionary alloc] init];
            [_mutatingRuleset setObject:[NSMutableArray array] forKey:kPropertyOrderKey];

          } else {
            [self setFailFlag];
          }
          break;
        }

        // Commit an existing rule set.
        case '}': {
          for (NSString* name in _scopesForActiveRuleset) {
            NSMutableDictionary* existingProperties = [_rulesets objectForKey:name];

            if (nil == existingProperties) {
              NSMutableDictionary* ruleSet = [_mutatingRuleset mutableCopy];
              [_rulesets setObject:ruleSet forKey:name];

            } else {
              // Properties already exist, so overwrite them.
              // Merge the orders.
              {
                NSMutableArray* order = [existingProperties objectForKey:kPropertyOrderKey];
                [order addObjectsFromArray:[_mutatingRuleset objectForKey:kPropertyOrderKey]];
                [_mutatingRuleset setObject:order forKey:kPropertyOrderKey];
              }

              for (NSString* key in _mutatingRuleset) {
                [existingProperties setObject:[_mutatingRuleset objectForKey:key] forKey:key];
              }
              // Add the order of the new properties.
              NSMutableArray* order = [existingProperties objectForKey:kPropertyOrderKey];
              [order addObjectsFromArray:[_mutatingRuleset objectForKey:kPropertyOrderKey]];
            }
          }

          _mutatingRuleset = nil;
          [_scopesForActiveRuleset removeAllObjects];
          _state.Flags.InsideRuleset = NO;
          _state.Flags.InsideProperty = NO;
          _state.Flags.InsideFunction = NO;
          break;
        }

        case ':': {
          // Defining a property value.
          if (_state.Flags.InsideRuleset) {
            _state.Flags.InsideProperty = YES;
          }
          break;
        }

        case ')': {
          if (_state.Flags.InsideFunction && nil != _currentPropertyName) {
            NSMutableArray* values = [_mutatingRuleset objectForKey:_currentPropertyName];
            [values addObject:lowercaseTextAsString];
          }
          _state.Flags.InsideFunction = NO;
          break;
        }

        case ';': {
          // Committing a property value.
          if (_state.Flags.InsideRuleset) {
            _state.Flags.InsideProperty = NO;
          }
          break;
        }
      }
      break;
    }
  }

  _lastTokenText = textAsString;
  _lastToken = token;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setup {
  [self shutdown];

  _rulesets = [[NSMutableDictionary alloc] init];
  _scopesForActiveRuleset = [[NSMutableArray alloc] init];
  _mutatingScope = [[NSMutableArray alloc] init];
  _importedFilenames = [[NSMutableArray alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseFileAtPath:(NSString *)path {
  // flex is not thread-safe so we force it to be by creating a single-access lock here.
  pthread_mutex_lock(&gMutex); {
    cssin = fopen([path UTF8String], "r");
    gActiveParser = self;
    csslex();
    fclose(cssin);
  }
  pthread_mutex_unlock(&gMutex);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)mergeCompositeRulesets:(NSMutableArray *)compositeRulesets dependencyFilenames:(NSSet *)dependencyFilenames {
  NIDASSERT([compositeRulesets count] > 0);
  if ([compositeRulesets count] == 0) {
    return nil;
  }

  NSDictionary* result = nil;

  if ([compositeRulesets count] == 1) {
    if ([dependencyFilenames count] > 0) {
      [[compositeRulesets objectAtIndex:0] setObject:dependencyFilenames
                                              forKey:kDependenciesSelectorKey];
    }
    result = [[compositeRulesets objectAtIndex:0] copy];

  } else {
    NSMutableDictionary* mergedResult = [compositeRulesets lastObject];
    [compositeRulesets removeLastObject];

    // Merge all of the rulesets into one.
    for (NSDictionary* ruleSet in [compositeRulesets reverseObjectEnumerator]) {
      for (NSString* scope in ruleSet) {
        if (![mergedResult objectForKey:scope]) {
          // New scope means we can just add it.
          [mergedResult setObject:[ruleSet objectForKey:scope] forKey:scope];

        } else {
          // Existing scope means we need to overwrite existing properties.
          NSMutableDictionary* mergedScopeProperties = [mergedResult objectForKey:scope];
          NSMutableDictionary* properties = [ruleSet objectForKey:scope];

          for (NSString* propertyName in properties) {

            if (!(nil != [mergedScopeProperties objectForKey:propertyName]
                  && [propertyName isEqualToString:kPropertyOrderKey])) {
              // Overwrite the existing property's value.
              [mergedScopeProperties setObject:[properties objectForKey:propertyName]
                                        forKey:propertyName];

            } else {
              // Append the property order.
              NSMutableArray *order = [mergedScopeProperties objectForKey:kPropertyOrderKey];
              [order addObjectsFromArray:[properties objectForKey:kPropertyOrderKey]];
            }
          }
        }
      }
    }
    
    if ([dependencyFilenames count] > 0) {
      [mergedResult setObject:dependencyFilenames forKey:kDependenciesSelectorKey];
    }
    result = [mergedResult copy];
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryForPath:(NSString *)path {
  return [self dictionaryForPath:path pathPrefix:nil delegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryForPath:(NSString *)path pathPrefix:(NSString *)pathPrefix {
  return [self dictionaryForPath:path pathPrefix:pathPrefix delegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)dictionaryForPath:(NSString *)aPath
                         pathPrefix:(NSString *)pathPrefix
                           delegate:(id<NICSSParserDelegate>)delegate {
  // Bail out early if there was no path given.
  if ([aPath length] == 0) {
    _didFailToParse = YES;
    return nil;
  }

  _didFailToParse = NO;

  NSMutableArray* compositeRulesets = [[NSMutableArray alloc] init];

  // Maintain a set of filenames that we've looked at for two reasons:
  // 1) To avoid visiting the same CSS file twice.
  // 2) To collect a list of dependencies for this stylesheet.
  NSMutableSet* processedFilenames = [[NSMutableSet alloc] init];

  // Imported CSS files will be added to the queue.
  NILinkedList* filenameQueue = [NILinkedList linkedList];
  [filenameQueue addObject:aPath];

  while ([filenameQueue count] > 0) {
    // Om nom nom
    NSString* path = [filenameQueue firstObject];
    [filenameQueue removeFirstObject];

    // Skip files that we've already processed in order to avoid infinite loops.
    if ([processedFilenames containsObject:path]) {
      continue;
    }
    [processedFilenames addObject:path];

    // Allow the delegate to rename the file.
    if ([delegate respondsToSelector:@selector(cssParser:pathFromPath:)]) {
      NSString* reprocessedFilename = [delegate cssParser:self pathFromPath:path];
      if (nil != reprocessedFilename) {
        path = reprocessedFilename;
      }
    }

    // Add the prefix, if it exists.
    if (pathPrefix.length > 0) {
      path = [pathPrefix stringByAppendingPathComponent:path];
    }

    // Verify that the file exists.
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
      [self shutdown];
      return nil;
    }

    [self setup];
    [self parseFileAtPath:path];
    if (self.didFailToParse) {
      break;
    }

    [filenameQueue addObjectsFromArray:_importedFilenames];
    [_importedFilenames removeAllObjects];

    [compositeRulesets addObject:_rulesets];
    [self shutdown];
  }

  NSDictionary* result = nil;

  if (!self.didFailToParse) {
    // processedFilenames will be the set of dependencies, so remove the initial path.
    [processedFilenames removeObject:aPath];

    result = [self mergeCompositeRulesets:compositeRulesets
                      dependencyFilenames:processedFilenames];

  }

  [self shutdown];

  return result;
}

@end
