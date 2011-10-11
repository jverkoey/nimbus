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

#import "NIStylesheet.h"

#import "NICSSParser.h"
#import "NICSSRuleSet.h"
#import "NIStyleable.h"
#import "NimbusCore.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIStylesheet

@synthesize rawRuleSets = _rawRuleSets;
@synthesize classToRuleSetMap = _classToRuleSetMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  NI_RELEASE_SAFELY(_rawRuleSets);
  NI_RELEASE_SAFELY(_ruleSets);
  NI_RELEASE_SAFELY(_classToRuleSetMap);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _ruleSets = [[NSMutableDictionary alloc] init];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(didReceiveMemoryWarning:)
               name: UIApplicationDidReceiveMemoryWarningNotification
             object: nil];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Rule Sets


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)rebuildClassToRuleSetMap {
  NSMutableDictionary* classToRuleSetMap =
  [[NSMutableDictionary alloc] initWithCapacity:[_rawRuleSets count]];

  for (NSString* selector in _rawRuleSets) {
    NSArray* parts = [selector componentsSeparatedByString:@" "];
    NSString* mostSignificantIdent = [parts lastObject];

    // TODO (jverkoey Oct 6, 2011): We should respect CSS specificity. Right now this will
    // give higher precedance to newer styles. Instead, we should prefer styles that have more
    // selectors.
    NSMutableArray* selectors = [classToRuleSetMap objectForKey:mostSignificantIdent];
    if (nil == selectors) {
      selectors = [[NSMutableArray alloc] initWithObjects:selector, nil];
      [classToRuleSetMap setObject:selectors forKey:mostSignificantIdent];
      NI_RELEASE_SAFELY(selectors);
      
    } else {
      [selectors addObject:selector];
    }
  }
  
  [_classToRuleSetMap release];
  _classToRuleSetMap = [classToRuleSetMap copy];
  
  NI_RELEASE_SAFELY(classToRuleSetMap);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)ruleSetsDidChange {
  [self rebuildClassToRuleSetMap];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSNotifications


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reduceMemory {
  NI_RELEASE_SAFELY(_ruleSets);
  _ruleSets = [[NSMutableDictionary alloc] init];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning:(void*)object {
  [self reduceMemory];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadFromPath:(NSString *)path {
  BOOL loadDidSucceed = NO;

  NI_RELEASE_SAFELY(_rawRuleSets);
  NI_RELEASE_SAFELY(_ruleSets);
  NI_RELEASE_SAFELY(_classToRuleSetMap);

  _ruleSets = [[NSMutableDictionary alloc] init];

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NICSSParser* parser = [[NICSSParser alloc] init];

    NSDictionary* results = [parser rulesetsForCSSFileAtPath:path];
    if (nil != results && ![parser didFailToParse]) {
      _rawRuleSets = [results retain];
      loadDidSucceed = YES;
    }
    NI_RELEASE_SAFELY(parser);

    [self ruleSetsDidChange];
  }

  return loadDidSucceed;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addStylesheet:(NIStylesheet *)stylesheet {
  NIDASSERT(nil != stylesheet);
  if (nil == stylesheet) {
    return;
  }

  NSMutableDictionary* compositeRuleSets = [self.rawRuleSets mutableCopy];

  BOOL ruleSetsDidChange = NO;

  for (NSString* selector in stylesheet.rawRuleSets) {
    NSDictionary* incomingRuleSet   = [stylesheet.rawRuleSets objectForKey:selector];
    NSDictionary* existingRuleSet = [self.rawRuleSets objectForKey:selector];

    // Don't bother adding empty rulesets.
    if ([incomingRuleSet count] > 0) {
      ruleSetsDidChange = YES;

      if (nil == existingRuleSet) {
        // There is no rule set of this selector - simply add the new one.
        [compositeRuleSets setObject:incomingRuleSet forKey:selector];
        continue;
      }

      NSMutableDictionary* compositeRuleSet = [existingRuleSet mutableCopy];
      // Add the incoming rule set entries, overwriting any existing ones.
      [compositeRuleSet addEntriesFromDictionary:incomingRuleSet];

      [compositeRuleSets setObject:compositeRuleSet forKey:selector];
      NI_RELEASE_SAFELY(compositeRuleSet);
    }
  }

  NI_RELEASE_SAFELY(_rawRuleSets);
  _rawRuleSets = [compositeRuleSets copy];
  NI_RELEASE_SAFELY(compositeRuleSets);

  if (ruleSetsDidChange) {
    [self ruleSetsDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyRuleSet:(NICSSRuleSet *)ruleSet toView:(UIView *)view {
  if ([view respondsToSelector:@selector(applyStyleWithRuleSet:)]) {
    [(id<NIStyleable>)view applyStyleWithRuleSet:ruleSet];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleToView:(UIView *)view {
  Class viewClass = [view class];
  NSString* viewClassName = NSStringFromClass(viewClass);
  NSArray* selectors = [_classToRuleSetMap objectForKey:viewClassName];
  if ([selectors count] > 0) {
    // Gather all of the rule sets for this view into a composite rule set.
    NICSSRuleSet* ruleSet = [_ruleSets objectForKey:viewClassName];

    if (nil == ruleSet) {
      ruleSet = [[NICSSRuleSet alloc] init];

      // Composite the rule sets into one.
      for (NSString* selector in selectors) {
        [ruleSet addEntriesFromDictionary:[_rawRuleSets objectForKey:selector]];
      }

      NIDASSERT(nil != _ruleSets);
      [_ruleSets setObject:ruleSet forKey:viewClassName];
      [ruleSet release]; // We can release the ruleSet because it's retained by the dictionary.
    }

    [self applyRuleSet:ruleSet toView:view];
  }
}

@end
