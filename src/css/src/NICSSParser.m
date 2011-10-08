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
      NIDASSERT(nil != _activePropertyName);

      if (nil != _activePropertyName) {
        NSMutableArray* values = [_activeRuleSet objectForKey:_activePropertyName];
        [values addObject:lowercaseTextAsString];

      } else {
        [self setFailFlag];
      }
      break;
    }

    // Parse individual characters.
    case CSSUNKNOWN: {
      switch (text[0]) {

        // Commit the current selector and start a new one.
        case ',': {
          [self commitCurrentSelector];
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
              NSDictionary* iteratorProperties = [_activeRuleSet copy];

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
              [[existingProperties objectForKey:_activeRuleSet] addObjectsFromArray:
               [_activeRuleSet objectForKey:kRuleSetOrderKey]];
              NI_RELEASE_SAFELY(iteratorProperties);
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

          } else {
            [self setFailFlag];
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)rulesetsForCSSFileAtPath:(NSString *)filename {
  if (0 == [filename length] || ![[NSFileManager defaultManager] fileExistsAtPath:filename]) {
    return nil;
  }

  _ruleSets = [[NSMutableDictionary alloc] init];
  _activeCssSelectors = [[NSMutableArray alloc] init];
  _currentSelector = [[NSMutableArray alloc] init];

  _didFailToParse = NO;

  pthread_mutex_lock(&gMutex); {
    cssin = fopen([filename UTF8String], "r");
    gActiveParser = self;
    csslex();
    fclose(cssin);
  }
  pthread_mutex_unlock(&gMutex);

  NSDictionary* result = [[_ruleSets copy] autorelease];

  [self shutdown];

  return result;
}

@end
