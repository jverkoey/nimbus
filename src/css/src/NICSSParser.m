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

static pthread_mutex_t gMutex = PTHREAD_MUTEX_INITIALIZER;
NSString* const kRuleSetOrderKey = @"__kRuleSetOrder__";
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
  NI_RELEASE_SAFELY(_ruleSets);
  NI_RELEASE_SAFELY(_activeCssSelectors);
  NI_RELEASE_SAFELY(_currentSelector);
  NI_RELEASE_SAFELY(_activeRuleSet);
  NI_RELEASE_SAFELY(_activePropertyName);
  NI_RELEASE_SAFELY(_importedFilenames);
  NI_RELEASE_SAFELY(_lastTokenText);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self shutdown];

  [super dealloc];
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
  [_activeCssSelectors addObject:[_currentSelector componentsJoinedByString:@" "]];
  [_currentSelector removeAllObjects];
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

      if (_state.Flags.InsideRuleSet) {
        NIDASSERT(nil != _activeRuleSet);
        if (nil == _activeRuleSet) {
          [self setFailFlag];
        }

        // Treat CSSIDENT as a new property if we're not already defining one.
        if (CSSIDENT == token && !_state.Flags.InsideProperty) {
          NI_RELEASE_SAFELY(_activePropertyName);

          // Properties are case insensitive.
          _activePropertyName = [lowercaseTextAsString retain];
          
          NSMutableArray* ruleSetOrder = [_activeRuleSet objectForKey:kRuleSetOrderKey];
          [ruleSetOrder addObject:_activePropertyName];

          // Clear any existing values for the given property.
          NSMutableArray* values = [[NSMutableArray alloc] init];
          [_activeRuleSet setObject:values forKey:_activePropertyName];
          NI_RELEASE_SAFELY(values);

        } else {
          // This is a value for the active property; add it.
          NIDASSERT(nil != _activePropertyName);

          if (nil != _activePropertyName) {
            NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
            [values addObject:lowercaseTextAsString];

          } else {
            [self setFailFlag];
          }
        }

      } else { // if not inside a rule set...
        [_currentSelector addObject:textAsString];

        // Ensure that we're not modifying a property.
        NI_RELEASE_SAFELY(_activePropertyName);
      }
      break;
    }

    case CSSFUNCTION: {
      // Functions can only exist within properties.
      if (_state.Flags.InsideProperty) {
        _state.Flags.InsideFunction = YES;

        NIDASSERT(nil != _activePropertyName);
        if (nil != _activePropertyName) {
          NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
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
        NIDASSERT(nil != _activePropertyName);

        if (nil != _activePropertyName) {
          NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
          [values addObject:lowercaseTextAsString];

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
          if (!_state.Flags.InsideRuleSet) {
            [self commitCurrentSelector];
          }
          break;
        }

        // Start a new rule set.
        case '{': {
          NIDASSERT(nil != _currentSelector);
          if ([_currentSelector count] > 0
              && !_state.Flags.InsideRuleSet && !_state.Flags.InsideFunction) {
            [self commitCurrentSelector];

            _state.Flags.InsideRuleSet = YES;
            _state.Flags.InsideFunction = NO;

            NI_RELEASE_SAFELY(_activeRuleSet);
            _activeRuleSet = [[NSMutableDictionary alloc] init];
            [_activeRuleSet setObject:[NSMutableArray array] forKey:kRuleSetOrderKey];

          } else {
            [self setFailFlag];
          }
          break;
        }

        // Commit an existing rule set.
        case '}': {
          for (NSString* name in _activeCssSelectors) {
            NSMutableDictionary* existingProperties = [_ruleSets objectForKey:name];

            if (nil == existingProperties) {
              NSMutableDictionary* ruleSet = [_activeRuleSet mutableCopy];
              [_ruleSets setObject:ruleSet forKey:name];
              NI_RELEASE_SAFELY(ruleSet);

            } else {
              // Properties already exist, so overwrite them.
              // Merge the orders.
              {
                NSMutableArray* order = [existingProperties objectForKey:kRuleSetOrderKey];
                [order addObjectsFromArray:[_activeRuleSet objectForKey:kRuleSetOrderKey]];
                [_activeRuleSet setObject:order forKey:kRuleSetOrderKey];
              }

              for (NSString* key in _activeRuleSet) {
                [existingProperties setObject:[_activeRuleSet objectForKey:key] forKey:key];
              }
              // Add the order of the new properties.
              [[existingProperties objectForKey:kRuleSetOrderKey] addObjectsFromArray:
               [_activeRuleSet objectForKey:kRuleSetOrderKey]];
            }
          }

          NI_RELEASE_SAFELY(_activeRuleSet);
          [_activeCssSelectors removeAllObjects];
          _state.Flags.InsideRuleSet = NO;
          _state.Flags.InsideProperty = NO;
          _state.Flags.InsideFunction = NO;
          break;
        }

        case ':': {
          // Defining a property value.
          if (_state.Flags.InsideRuleSet) {
            _state.Flags.InsideProperty = YES;
          }
          break;
        }

        case ')': {
          if (_state.Flags.InsideFunction && nil != _activePropertyName) {
            NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
            [values addObject:lowercaseTextAsString];
          }
          _state.Flags.InsideFunction = NO;
          break;
        }

        case ';': {
          // Committing a property value.
          if (_state.Flags.InsideRuleSet) {
            _state.Flags.InsideProperty = NO;
          }
          break;
        }
      }
      break;
    }
  }

  NI_RELEASE_SAFELY(textAsString);

  [_lastTokenText release];
  _lastTokenText = [textAsString retain];
  _lastToken = token;
}


- (void)setup {
  _ruleSets = [[NSMutableDictionary alloc] init];
  _activeCssSelectors = [[NSMutableArray alloc] init];
  _currentSelector = [[NSMutableArray alloc] init];
  _importedFilenames = [[NSMutableArray alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)rulesetsForCSSRelativeFilename:(NSString *)relFilename
                                        rootPath:(NSString *)rootPath {
  return [self rulesetsForCSSRelativeFilename:relFilename rootPath:rootPath delegate:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)rulesetsForCSSRelativeFilename:(NSString *)relFilename
                                        rootPath:(NSString *)rootPath
                                        delegate:(id<NICSSParserDelegate>)delegate {
  _didFailToParse = NO;

  NSMutableSet* processedFilenames = [[[NSMutableSet alloc] init] autorelease];
  NSMutableArray* filenameQueue = [[[NSMutableArray alloc] initWithObjects:relFilename, nil]
                                   autorelease];
  NSMutableArray* allRuleSets = [[[NSMutableArray alloc] init] autorelease];

  while ([filenameQueue count] > 0) {
    NSString* activeFilename = [filenameQueue objectAtIndex:0];
    [filenameQueue removeObjectAtIndex:0];

    // Skip files that we've already processed to avoid infinite loops.
    if ([processedFilenames containsObject:activeFilename]) {
      continue;
    }

    [processedFilenames addObject:activeFilename];

    if ([delegate respondsToSelector:@selector(cssParser:filenameFromFilename:)]) {
      activeFilename = [delegate cssParser:self filenameFromFilename:activeFilename];
    }

    // Verify that the file exists.
    NSString* filename = [rootPath stringByAppendingPathComponent:activeFilename];
    if (0 == [filename length] || ![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
      [self shutdown];
      return nil;
    }

    [self setup];
    
    NSLog(@"%@: %@", filename, [[[NSString alloc] initWithData:[NSData dataWithContentsOfFile:filename]
                                          encoding:NSUTF8StringEncoding] autorelease]);

    // flex is not thread-safe so we force it to be by creating a single-access lock here.
    pthread_mutex_lock(&gMutex); {
      cssin = fopen([filename UTF8String], "r");
      gActiveParser = self;
      csslex();
      fclose(cssin);
    }
    pthread_mutex_unlock(&gMutex);

    [filenameQueue addObjectsFromArray:_importedFilenames];
    [_importedFilenames removeAllObjects];

    [allRuleSets addObject:_ruleSets];
    [self shutdown];
  }

  NSDictionary* result = nil;

  if ([allRuleSets count] > 1) {
    // Merge all of the rulesets into one.
    NSMutableDictionary* mergedResult = [[[allRuleSets lastObject] retain] autorelease];

    // Skip the last ruleset.
    [allRuleSets removeLastObject];

    for (NSDictionary* ruleSet in [allRuleSets reverseObjectEnumerator]) {
      for (NSString* selector in ruleSet) {
        if (![mergedResult objectForKey:selector]) {
          [mergedResult setObject:[ruleSet objectForKey:selector] forKey:selector];

        } else {
          NSMutableDictionary* mergedSelectorValue = [mergedResult objectForKey:selector];
          NSMutableDictionary* selectorValue = [ruleSet objectForKey:selector];
          for (NSString* key in selectorValue) {
            if (nil == [mergedSelectorValue objectForKey:key] || ![key isEqualToString:kRuleSetOrderKey]) {
              // The merged rule set doesn't have this key yet so just add it.
              [mergedSelectorValue setObject:[selectorValue objectForKey:key] forKey:key];

            } else {
              // Merge the rule set orders then.
              [[mergedSelectorValue objectForKey:kRuleSetOrderKey] addObjectsFromArray:
               [selectorValue objectForKey:kRuleSetOrderKey]];
            }
          }
        }
      }
    }

    [mergedResult setObject:processedFilenames forKey:kDependenciesSelectorKey];
    result = [[mergedResult copy] autorelease];

  } else {
    [[allRuleSets objectAtIndex:0] setObject:processedFilenames forKey:kDependenciesSelectorKey];
    result = [[[allRuleSets objectAtIndex:0] copy] autorelease];
  }

  [processedFilenames removeObject:relFilename];

  [self shutdown];
  return result;
}

@end
