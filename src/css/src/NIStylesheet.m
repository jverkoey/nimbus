//
// Copyright 2011-2014 NimbusKit
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
#import "NICSSRuleset.h"
#import "NIStyleable.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NSString* const NIStylesheetDidChangeNotification = @"NIStylesheetDidChangeNotification";
static Class _rulesetClass;

@interface NIStylesheet()
@property (nonatomic, readonly, copy) NSDictionary* rawRulesets;
@property (nonatomic, readonly, copy) NSDictionary* significantScopeToScopes;
@end

@implementation NIStylesheet



- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

#pragma mark - Rule Sets


// Builds a map of significant scopes to full scopes.
//
// For example, consider the following rulesets:
//
// .root UIButton {
// }
// .apple UIButton {
// }
// UIButton UIView {
// }
// UIView {
// }
//
// The generated scope map will look like:
//
// UIButton => (.root UIButton, .apple UIButton)
// UIView => (UIButton UIView, UIView)
//
- (void)rebuildSignificantScopeToScopes {
  NSMutableDictionary* significantScopeToScopes =
  [[NSMutableDictionary alloc] initWithCapacity:[_rawRulesets count]];

  for (NSString* scope in _rawRulesets) {
    NSArray* parts = [scope componentsSeparatedByString:@" "];
    NSString* mostSignificantScopePart = [parts lastObject];

    // TODO (jverkoey Oct 6, 2011): We should respect CSS specificity. Right now this will
    // give higher precedance to newer styles. Instead, we should prefer styles that have more
    // selectors.
    NSMutableArray* scopes = [significantScopeToScopes objectForKey:mostSignificantScopePart];
    if (nil == scopes) {
      scopes = [[NSMutableArray alloc] initWithObjects:scope, nil];
      [significantScopeToScopes setObject:scopes forKey:mostSignificantScopePart];
      
    } else {
      [scopes addObject:scope];
    }
  }

  _significantScopeToScopes = [significantScopeToScopes copy];
}

- (void)ruleSetsDidChange {
  [self rebuildSignificantScopeToScopes];
}

#pragma mark - NSNotifications


- (void)reduceMemory {
  _ruleSets = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning:(void*)object {
  [self reduceMemory];
}

#pragma mark - Public


- (BOOL)loadFromPath:(NSString *)path {
  return [self loadFromPath:path pathPrefix:nil delegate:nil];
}

- (BOOL)loadFromPath:(NSString *)path pathPrefix:(NSString *)pathPrefix {
  return [self loadFromPath:path pathPrefix:pathPrefix delegate:nil];
}

- (BOOL)loadFromPath:(NSString *)path
          pathPrefix:(NSString *)pathPrefix
            delegate:(id<NICSSParserDelegate>)delegate {
  BOOL loadDidSucceed = NO;

  @synchronized(self) {
    _rawRulesets = nil;
    _significantScopeToScopes = nil;

    _ruleSets = [[NSMutableDictionary alloc] init];

    NICSSParser* parser = [[NICSSParser alloc] init];

    NSDictionary* results = [parser dictionaryForPath:path
                                           pathPrefix:pathPrefix
                                             delegate:delegate];
    if (nil != results && ![parser didFailToParse]) {
      _rawRulesets = results;
      loadDidSucceed = YES;
    }

    if (loadDidSucceed) {
      [self ruleSetsDidChange];
    }
  }

  return loadDidSucceed;
}

- (void)addStylesheet:(NIStylesheet *)stylesheet {
  NIDASSERT(nil != stylesheet);
  if (nil == stylesheet) {
    return;
  }

  @synchronized(self) {
    NSMutableDictionary* compositeRuleSets = [self.rawRulesets mutableCopy];

    BOOL ruleSetsDidChange = NO;

    for (NSString* selector in stylesheet.rawRulesets) {
      NSDictionary* incomingRuleSet   = [stylesheet.rawRulesets objectForKey:selector];
      NSDictionary* existingRuleSet = [self.rawRulesets objectForKey:selector];

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
      }
    }

    _rawRulesets = [compositeRuleSets copy];

    if (ruleSetsDidChange) {
      [self ruleSetsDidChange];
    }
  }
}

- (NSString*)descriptionForView:(UIView *)view withClassName:(NSString *)className inDOM:(NIDOM *)dom andViewName:(NSString *)viewName {
  NSMutableString *description = [[NSMutableString alloc] init];
  NICSSRuleset *ruleset = [self rulesetForClassName:className];
  if (nil != ruleset) {
    NSRange r = [className rangeOfString:@":"];
    if ([view respondsToSelector:@selector(descriptionWithRuleSet:forPseudoClass:inDOM:withViewName:)]) {
      if (r.location != NSNotFound) {
        [description appendString:[(id<NIStyleable>)view descriptionWithRuleSet:ruleset forPseudoClass:[className substringFromIndex:r.location+1] inDOM:dom withViewName:viewName]];
      } else {
        [description appendString:[(id<NIStyleable>)view descriptionWithRuleSet:ruleset forPseudoClass:nil inDOM:dom withViewName:viewName]];
      }
    } else {
      [description appendFormat:@"// Description not supported for %@ with selector %@\n", view, className];
    }
  }
  return description;
}

#pragma mark Applying Styles to Views


- (void)applyRuleSet:(NICSSRuleset *)ruleSet toView:(UIView *)view inDOM: (NIDOM*)dom {
  if ([view respondsToSelector:@selector(applyStyleWithRuleSet:inDOM:)]) {
    [(id<NIStyleable>)view applyStyleWithRuleSet:ruleSet inDOM:dom];
  }
  if ([view respondsToSelector:@selector(applyStyleWithRuleSet:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [(id<NIStyleable>)view applyStyleWithRuleSet:ruleSet];
#pragma clang diagnostic pop
  }
}

- (void)applyStyleToView:(UIView *)view withClassName:(NSString *)className inDOM:(NIDOM *)dom {
  NICSSRuleset *ruleset = [self rulesetForClassName:className];
  if (nil != ruleset) {
    NSRange r = [className rangeOfString:@":"];
    if (r.location != NSNotFound && [view respondsToSelector:@selector(applyStyleWithRuleSet:forPseudoClass:inDOM:)]) {
      [(id<NIStyleable>)view applyStyleWithRuleSet:ruleset forPseudoClass: [className substringFromIndex:r.location+1] inDOM:dom];
    } else {
      [self applyRuleSet:ruleset toView:view inDOM:dom];
    }
  }
}

- (NICSSRuleset*) addSelectors: (NSArray*) selectors toRuleset: (NICSSRuleset*) ruleSet forClassName: (NSString*) className
{
  if ([selectors count] > 0) {
    // Gather all of the rule sets for this view into a composite rule set.
    ruleSet = ruleSet ?: [_ruleSets objectForKey:className];
    
    if (nil == ruleSet) {
      ruleSet = [[[NIStylesheet rulesetClass] alloc] init];
      
      // Composite the rule sets into one.
      for (NSString* selector in selectors) {
        [ruleSet addEntriesFromDictionary:[_rawRulesets objectForKey:selector]];
      }
      
      NIDASSERT(nil != _ruleSets);
      [_ruleSets setObject:ruleSet forKey:className];
    }
  }
  
  return ruleSet;
}

- (NICSSRuleset *)rulesetForClassName:(NSString *)className {
  NSArray* selectors = [_significantScopeToScopes objectForKey:className];
  return [self addSelectors:selectors toRuleset:nil forClassName:className];
}

- (NSSet *)dependencies {
  return [_rawRulesets objectForKey:kDependenciesSelectorKey];
}

+(Class)rulesetClass
{
  return _rulesetClass ?: [NICSSRuleset class];
}

+(void)setRulesetClass:(Class)rulesetClass
{
  _rulesetClass = rulesetClass;
}

@end
