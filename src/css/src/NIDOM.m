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

#import "NIDOM.h"

#import "NIStylesheet.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIDOM ()
@property (nonatomic,strong) NIStylesheet* stylesheet;
@property (nonatomic,strong) NSMutableArray* registeredViews;
@property (nonatomic,strong) NSMutableDictionary* viewToSelectorsMap;
@property (nonatomic,strong) NSMutableDictionary* idToViewMap;
@property (nonatomic,strong) NIDOM *parent;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIDOM


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)domWithStylesheet:(NIStylesheet *)stylesheet {
  return [[self alloc] initWithStylesheet:stylesheet];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)domWithStylesheetWithPathPrefix:(NSString *)pathPrefix paths:(NSString *)path, ... {
  va_list ap;
  va_start(ap, path);
  
  NIStylesheet* compositeStylesheet = [[NIStylesheet alloc] init];
  
  while (nil != path) {
    NIDASSERT([path isKindOfClass:[NSString class]]);
    
    if ([path isKindOfClass:[NSString class]]) {
      NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
      if ([stylesheet loadFromPath:path pathPrefix:pathPrefix]) {
        [compositeStylesheet addStylesheet:stylesheet];
      }
    }
    path = va_arg(ap, NSString*);
  }
  va_end(ap);
  
  return [[self alloc] initWithStylesheet:compositeStylesheet];
}

+(id)domWithStylesheet:(NIStylesheet *)stylesheet andParentStyles:(NIStylesheet *)parentStyles
{
  NIDOM *dom = [[self alloc] initWithStylesheet:stylesheet];
  if (parentStyles) {
    dom.parent = [NIDOM domWithStylesheet:parentStyles andParentStyles:nil];
  }
  return dom;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStylesheet:(NIStylesheet *)stylesheet {
  if ((self = [super init])) {
    _stylesheet = stylesheet;
    _registeredViews = [[NSMutableArray alloc] init];
    _viewToSelectorsMap = [[NSMutableDictionary alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Styling Views


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshStyleForView:(UIView *)view withSelectorName:(NSString *)selectorName {
  if (self.parent) {
    [self.parent.stylesheet applyStyleToView:view withClassName:selectorName inDOM:self];
  }
  [_stylesheet applyStyleToView:view withClassName:selectorName inDOM:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)keyForView:(UIView *)view {
  return [NSNumber numberWithLong:(long)view];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerSelector:(NSString *)selector withView:(UIView *)view {
  id key = [self keyForView:view];
  NSMutableArray* selectors = [_viewToSelectorsMap objectForKey:key];
  if (nil == selectors) {
    selectors = [[NSMutableArray alloc] init];
    [_viewToSelectorsMap setObject:selectors forKey:key];
  }
  [selectors addObject:selector];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerView:(UIView *)view {
  if (self.parent) {
    [self.parent registerView:view];
  }
  NSString* selector = NSStringFromClass([view class]);
  [self registerSelector:selector withView:view];
  
  NSArray *pseudos = nil;
  if ([view respondsToSelector:@selector(pseudoClasses)]) {
    pseudos = (NSArray*) [view performSelector:@selector(pseudoClasses)];
    if (pseudos) {
      for (NSString *ps in pseudos) {
        [self registerSelector:[selector stringByAppendingString:ps] withView:view];
      }
    }
  }
  
  [_registeredViews addObject:view];
  [self refreshStyleForView:view withSelectorName:selector];
  if (pseudos) {
    for (NSString *ps in pseudos) {
      [self refreshStyleForView:view withSelectorName:[selector stringByAppendingString:ps]];
    }
  }
}

- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass andId:(NSString *)viewId
{
  // These are basically the least specific selectors (by our simple rules), so this needs to get registered first
  [self registerView:view withCSSClass:cssClass];

  NSArray *pseudos = nil;
  if (viewId) {
    if (![viewId hasPrefix:@"#"]) { viewId = [@"#" stringByAppendingString:viewId]; }
    if (self.parent) {
      [self.parent registerSelector:viewId withView:view];
    }
    [self registerSelector:viewId withView:view];
    
    if ([view respondsToSelector:@selector(pseudoClasses)]) {
      pseudos = (NSArray*) [view performSelector:@selector(pseudoClasses)];
      if (pseudos) {
        for (NSString *ps in pseudos) {
          if (self.parent) {
            [self.parent registerSelector:[viewId stringByAppendingString:ps] withView:view];
          }
          [self registerSelector:[viewId stringByAppendingString:ps] withView:view];
        }
      }
    }

    if (!_idToViewMap) {
      _idToViewMap = [[NSMutableDictionary alloc] init];
    }
    [_idToViewMap setObject:view forKey:viewId];
    // Run the id selectors last so they take precedence
    [self refreshStyleForView:view withSelectorName:viewId];
    if (pseudos) {
      for (NSString *ps in pseudos) {
        [self refreshStyleForView:view withSelectorName:[viewId stringByAppendingString:ps]];
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass registerMainView: (BOOL) registerMainView
{
  if (registerMainView) {
    if (self.parent) {
      [self.parent registerView:view withCSSClass:cssClass registerMainView:NO];
    }
    [self registerView:view];
  }
  
  if (cssClass) {
    [self addCssClass:cssClass toView:view];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass {
  [self registerView:view withCSSClass:cssClass registerMainView:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addCssClass:(NSString *)cssClass toView:(UIView *)view
{
  NSString* selector = [@"." stringByAppendingString:cssClass];
  [self registerSelector:selector withView:view];
  
  // This registers both the UIKit class name and the css class name for this view
  // Now, we also want to register the 'state based' selectors. Fun.
  NSArray *pseudos = nil;
  if ([view respondsToSelector:@selector(pseudoClasses)]) {
    pseudos = (NSArray*) [view performSelector:@selector(pseudoClasses)];
    if (pseudos) {
      for (NSString *ps in pseudos) {
        [self registerSelector:[selector stringByAppendingString:ps] withView:view];
      }
    }
  }
  
  [self refreshStyleForView:view withSelectorName:selector];
  if (pseudos) {
    for (NSString *ps in pseudos) {
      [self refreshStyleForView:view withSelectorName:[selector stringByAppendingString:ps]];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeCssClass:(NSString *)cssClass fromView:(UIView *)view
{
  NSString* selector = [@"." stringByAppendingString:cssClass];
  NSString* pseudoBase = [selector stringByAppendingString:@":"];
  NSMutableArray *selectors = [_viewToSelectorsMap objectForKey:[self keyForView:view]];
  if (selectors) {
    // Iterate over the selectors finding the id selector (if any) so we can
    // also remove it from the id map
    for (int i = selectors.count-1; i >= 0; i--) {
      NSString *s = [selectors objectAtIndex:i];
      if ([s isEqualToString:selector] && [s hasPrefix:pseudoBase]) {
        [selectors removeObjectAtIndex:i];
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unregisterView:(UIView *)view {
  [_registeredViews removeObject:view];
  NSArray *selectors = [_viewToSelectorsMap objectForKey:[self keyForView:view]];
  if (selectors) {
    // Iterate over the selectors finding the id selector (if any) so we can
    // also remove it from the id map
    for (NSString *s in selectors) {
      if ([s characterAtIndex:0] == '#') {
        [_idToViewMap removeObjectForKey:s];
      }
    }
  }
  [_viewToSelectorsMap removeObjectForKey:[self keyForView:view]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unregisterAllViews {
  [_registeredViews removeAllObjects];
  [_viewToSelectorsMap removeAllObjects];
  [_idToViewMap removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refresh {
  for (UIView* view in _registeredViews) {
    for (NSString* selector in [_viewToSelectorsMap objectForKey:[self keyForView:view]]) {
      [self refreshStyleForView:view withSelectorName:selector];
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshView:(UIView *)view {
    for (NSString* selector in [_viewToSelectorsMap objectForKey:[self keyForView:view]]) {
        [self refreshStyleForView:view withSelectorName:selector];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIView *)viewById:(NSString *)viewId
{
  if (![viewId hasPrefix:@"#"]) { viewId = [@"#" stringByAppendingString:viewId]; }
  return [_idToViewMap objectForKey:viewId];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)descriptionForView:(UIView *)view withName:(NSString *)viewName
{
  NSMutableString *description = [[NSMutableString alloc] init];
  BOOL appendedStyleInfo = NO;
  
  for (NSString *selector in [_viewToSelectorsMap objectForKey:[self keyForView:view]]) {
    BOOL appendedSelectorInfo = NO;
    NSString *additional = nil;
    if (self.parent) {
      additional = [self.parent.stylesheet descriptionForView: view withClassName: selector inDOM:self andViewName: viewName];
      if (additional && additional.length) {
        if (!appendedStyleInfo) { appendedStyleInfo = YES; [description appendFormat:@"// Styles for %@\n", viewName]; }
        if (!appendedSelectorInfo) { appendedSelectorInfo = YES; [description appendFormat:@"// Selector %@\n", selector]; }
        [description appendString:additional];
      }
    }
    additional = [_stylesheet descriptionForView:view withClassName: selector inDOM:self andViewName: viewName];
    if (additional && additional.length) {
      if (!appendedStyleInfo) { appendedStyleInfo = YES; [description appendFormat:@"// Styles for %@\n", viewName]; }
      if (!appendedSelectorInfo) { [description appendFormat:@"// Selector %@\n", selector]; }
      [description appendString:additional];
    }
  }
  return description;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString *)descriptionForAllViews {
  NSMutableString *description = [[NSMutableString alloc] init];
  int viewCount = 0;
  for (UIView *view in _registeredViews) {
    [description appendString:@"\n///////////////////////////////////////////////////////////////////////////////////////////////////\n"];
    viewCount++;
    // This is a little hokey - because we don't get individual view names we have to come up with some.
    __block NSString *vid = nil;
    [[_viewToSelectorsMap objectForKey:[self keyForView:view]] enumerateObjectsUsingBlock:^(NSString *selector, NSUInteger idx, BOOL *stop) {
      if ([selector hasPrefix:@"#"]) {
        vid = [selector substringFromIndex:1];
        *stop = YES;
      }
    }];
    if (vid) {
      [description appendFormat:@"UIView *%@_%d = [dom viewById: @\"#%@\"];\n", [view class], viewCount, vid];
    }
    [description appendString:[self descriptionForView:view withName:[NSString stringWithFormat:@"%@_%d", [view class], viewCount]]];
  }
  return description;
}
@end
