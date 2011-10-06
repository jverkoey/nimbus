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

// This color table is generated on-demand and is released when a memory warning is encountered.
static NSDictionary* sColorTable = nil;

@interface NIStylesheet()
// Instantiates the color table if it does not already exist.
+ (NSDictionary *)colorTable;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIStylesheet

@synthesize ruleSets = _ruleSets;
@synthesize classToRuleSetMap = _classToRuleSetMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  NI_RELEASE_SAFELY(_ruleSets);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
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
  [[NSMutableDictionary alloc] initWithCapacity:[_ruleSets count]];

  for (NSString* selector in _ruleSets) {
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
  NI_RELEASE_SAFELY(sColorTable);
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

  NI_RELEASE_SAFELY(_ruleSets);

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NICSSParser* parser = [[NICSSParser alloc] init];

    NSDictionary* results = [parser rulesetsForCSSFileAtPath:path];
    if (nil != results && ![parser didFailToParse]) {
      _ruleSets = [results retain];
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

  NSMutableDictionary* compositeRuleSets = [self.ruleSets mutableCopy];

  BOOL ruleSetsDidChange = NO;

  for (NSString* selector in stylesheet.ruleSets) {
    NSDictionary* incomingRuleSet   = [stylesheet.ruleSets objectForKey:selector];
    NSDictionary* existingRuleSet = [self.ruleSets objectForKey:selector];

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

  NI_RELEASE_SAFELY(_ruleSets);
  _ruleSets = [compositeRuleSets copy];
  NI_RELEASE_SAFELY(compositeRuleSets);

  if (ruleSetsDidChange) {
    [self ruleSetsDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyRuleSet:(NICSSRuleSet *)ruleSet toView:(UIView *)view {
  if ([view respondsToSelector:@selector(styleWithRuleSet:)]) {
    [(id<NIStyleable>)view styleWithRuleSet:ruleSet];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleToView:(UIView *)view {
  Class viewClass = [view class];
  NSString* viewClassName = NSStringFromClass(viewClass);
  NSArray* selectors = [_classToRuleSetMap objectForKey:viewClassName];
  if ([selectors count] > 0) {
    // Apply each of these styles to the view.
    for (NSString* selector in selectors) {
      NICSSRuleSet* ruleSet = [[NICSSRuleSet alloc] initWithDictionary:
                               [_ruleSets objectForKey:selector]];
      [self applyRuleSet:ruleSet toView:view];
      NI_RELEASE_SAFELY(ruleSet);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Color Tables


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDictionary *)colorTable {
  if (nil == sColorTable) {
    // This color table was generated from http://www.w3.org/TR/css3-color/
    //
    // The output was sorted,
    // > pbpaste | sort | pbcopy
    //
    // reformatted using a regex,
    // ^(.+)\t(.+)\t(.+) => RGBCOLOR($3), @"$1",
    //
    // and then uniq'd
    // > pbpaste | uniq | pbcopy
    NSMutableDictionary* colorTable =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     RGBCOLOR(240,248,255), @"aliceblue",
     RGBCOLOR(250,235,215), @"antiquewhite",
     RGBCOLOR(0,255,255), @"aqua",
     RGBCOLOR(127,255,212), @"aquamarine",
     RGBCOLOR(240,255,255), @"azure",
     RGBCOLOR(245,245,220), @"beige",
     RGBCOLOR(255,228,196), @"bisque",
     RGBCOLOR(0,0,0), @"black",
     RGBCOLOR(255,235,205), @"blanchedalmond",
     RGBCOLOR(0,0,255), @"blue",
     RGBCOLOR(138,43,226), @"blueviolet",
     RGBCOLOR(165,42,42), @"brown",
     RGBCOLOR(222,184,135), @"burlywood",
     RGBCOLOR(95,158,160), @"cadetblue",
     RGBCOLOR(127,255,0), @"chartreuse",
     RGBCOLOR(210,105,30), @"chocolate",
     RGBCOLOR(255,127,80), @"coral",
     RGBCOLOR(100,149,237), @"cornflowerblue",
     RGBCOLOR(255,248,220), @"cornsilk",
     RGBCOLOR(220,20,60), @"crimson",
     RGBCOLOR(0,255,255), @"cyan",
     RGBCOLOR(0,0,139), @"darkblue",
     RGBCOLOR(0,139,139), @"darkcyan",
     RGBCOLOR(184,134,11), @"darkgoldenrod",
     RGBCOLOR(169,169,169), @"darkgray",
     RGBCOLOR(0,100,0), @"darkgreen",
     RGBCOLOR(169,169,169), @"darkgrey",
     RGBCOLOR(189,183,107), @"darkkhaki",
     RGBCOLOR(139,0,139), @"darkmagenta",
     RGBCOLOR(85,107,47), @"darkolivegreen",
     RGBCOLOR(255,140,0), @"darkorange",
     RGBCOLOR(153,50,204), @"darkorchid",
     RGBCOLOR(139,0,0), @"darkred",
     RGBCOLOR(233,150,122), @"darksalmon",
     RGBCOLOR(143,188,143), @"darkseagreen",
     RGBCOLOR(72,61,139), @"darkslateblue",
     RGBCOLOR(47,79,79), @"darkslategray",
     RGBCOLOR(47,79,79), @"darkslategrey",
     RGBCOLOR(0,206,209), @"darkturquoise",
     RGBCOLOR(148,0,211), @"darkviolet",
     RGBCOLOR(255,20,147), @"deeppink",
     RGBCOLOR(0,191,255), @"deepskyblue",
     RGBCOLOR(105,105,105), @"dimgray",
     RGBCOLOR(105,105,105), @"dimgrey",
     RGBCOLOR(30,144,255), @"dodgerblue",
     RGBCOLOR(178,34,34), @"firebrick",
     RGBCOLOR(255,250,240), @"floralwhite",
     RGBCOLOR(34,139,34), @"forestgreen",
     RGBCOLOR(255,0,255), @"fuchsia",
     RGBCOLOR(220,220,220), @"gainsboro",
     RGBCOLOR(248,248,255), @"ghostwhite",
     RGBCOLOR(255,215,0), @"gold",
     RGBCOLOR(218,165,32), @"goldenrod",
     RGBCOLOR(128,128,128), @"gray",
     RGBCOLOR(0,128,0), @"green",
     RGBCOLOR(173,255,47), @"greenyellow",
     RGBCOLOR(128,128,128), @"grey",
     RGBCOLOR(240,255,240), @"honeydew",
     RGBCOLOR(255,105,180), @"hotpink",
     RGBCOLOR(205,92,92), @"indianred",
     RGBCOLOR(75,0,130), @"indigo",
     RGBCOLOR(255,255,240), @"ivory",
     RGBCOLOR(240,230,140), @"khaki",
     RGBCOLOR(230,230,250), @"lavender",
     RGBCOLOR(255,240,245), @"lavenderblush",
     RGBCOLOR(124,252,0), @"lawngreen",
     RGBCOLOR(255,250,205), @"lemonchiffon",
     RGBCOLOR(173,216,230), @"lightblue",
     RGBCOLOR(240,128,128), @"lightcoral",
     RGBCOLOR(224,255,255), @"lightcyan",
     RGBCOLOR(250,250,210), @"lightgoldenrodyellow",
     RGBCOLOR(211,211,211), @"lightgray",
     RGBCOLOR(144,238,144), @"lightgreen",
     RGBCOLOR(211,211,211), @"lightgrey",
     RGBCOLOR(255,182,193), @"lightpink",
     RGBCOLOR(255,160,122), @"lightsalmon",
     RGBCOLOR(32,178,170), @"lightseagreen",
     RGBCOLOR(135,206,250), @"lightskyblue",
     RGBCOLOR(119,136,153), @"lightslategray",
     RGBCOLOR(119,136,153), @"lightslategrey",
     RGBCOLOR(176,196,222), @"lightsteelblue",
     RGBCOLOR(255,255,224), @"lightyellow",
     RGBCOLOR(0,255,0), @"lime",
     RGBCOLOR(50,205,50), @"limegreen",
     RGBCOLOR(250,240,230), @"linen",
     RGBCOLOR(255,0,255), @"magenta",
     RGBCOLOR(128,0,0), @"maroon",
     RGBCOLOR(102,205,170), @"mediumaquamarine",
     RGBCOLOR(0,0,205), @"mediumblue",
     RGBCOLOR(186,85,211), @"mediumorchid",
     RGBCOLOR(147,112,219), @"mediumpurple",
     RGBCOLOR(60,179,113), @"mediumseagreen",
     RGBCOLOR(123,104,238), @"mediumslateblue",
     RGBCOLOR(0,250,154), @"mediumspringgreen",
     RGBCOLOR(72,209,204), @"mediumturquoise",
     RGBCOLOR(199,21,133), @"mediumvioletred",
     RGBCOLOR(25,25,112), @"midnightblue",
     RGBCOLOR(245,255,250), @"mintcream",
     RGBCOLOR(255,228,225), @"mistyrose",
     RGBCOLOR(255,228,181), @"moccasin",
     RGBCOLOR(255,222,173), @"navajowhite",
     RGBCOLOR(0,0,128), @"navy",
     RGBCOLOR(253,245,230), @"oldlace",
     RGBCOLOR(128,128,0), @"olive",
     RGBCOLOR(107,142,35), @"olivedrab",
     RGBCOLOR(255,165,0), @"orange",
     RGBCOLOR(255,69,0), @"orangered",
     RGBCOLOR(218,112,214), @"orchid",
     RGBCOLOR(238,232,170), @"palegoldenrod",
     RGBCOLOR(152,251,152), @"palegreen",
     RGBCOLOR(175,238,238), @"paleturquoise",
     RGBCOLOR(219,112,147), @"palevioletred",
     RGBCOLOR(255,239,213), @"papayawhip",
     RGBCOLOR(255,218,185), @"peachpuff",
     RGBCOLOR(205,133,63), @"peru",
     RGBCOLOR(255,192,203), @"pink",
     RGBCOLOR(221,160,221), @"plum",
     RGBCOLOR(176,224,230), @"powderblue",
     RGBCOLOR(128,0,128), @"purple",
     RGBCOLOR(255,0,0), @"red",
     RGBCOLOR(188,143,143), @"rosybrown",
     RGBCOLOR(65,105,225), @"royalblue",
     RGBCOLOR(139,69,19), @"saddlebrown",
     RGBCOLOR(250,128,114), @"salmon",
     RGBCOLOR(244,164,96), @"sandybrown",
     RGBCOLOR(46,139,87), @"seagreen",
     RGBCOLOR(255,245,238), @"seashell",
     RGBCOLOR(160,82,45), @"sienna",
     RGBCOLOR(192,192,192), @"silver",
     RGBCOLOR(135,206,235), @"skyblue",
     RGBCOLOR(106,90,205), @"slateblue",
     RGBCOLOR(112,128,144), @"slategray",
     RGBCOLOR(112,128,144), @"slategrey",
     RGBCOLOR(255,250,250), @"snow",
     RGBCOLOR(0,255,127), @"springgreen",
     RGBCOLOR(70,130,180), @"steelblue",
     RGBCOLOR(210,180,140), @"tan",
     RGBCOLOR(0,128,128), @"teal",
     RGBCOLOR(216,191,216), @"thistle",
     RGBCOLOR(255,99,71), @"tomato",
     RGBCOLOR(64,224,208), @"turquoise",
     RGBCOLOR(238,130,238), @"violet",
     RGBCOLOR(245,222,179), @"wheat",
     RGBCOLOR(255,255,255), @"white",
     RGBCOLOR(245,245,245), @"whitesmoke",
     RGBCOLOR(255,255,0), @"yellow",
     RGBCOLOR(154,205,50), @"yellowgreen",

     // System colors
     [UIColor lightTextColor],                @"lightTextColor",
     [UIColor darkTextColor],                 @"darkTextColor",
     [UIColor groupTableViewBackgroundColor], @"groupTableViewBackgroundColor",
     [UIColor viewFlipsideBackgroundColor],   @"viewFlipsideBackgroundColor",
     nil];

    if ([UIColor respondsToSelector:@selector(scrollViewTexturedBackgroundColor)]) {
      // 3.2 and up
      [colorTable setObject:[UIColor scrollViewTexturedBackgroundColor]
                     forKey:@"scrollViewTexturedBackgroundColor"];
    }

    if ([UIColor respondsToSelector:@selector(underPageBackgroundColor)]) {
      // 5.0 and up
      [colorTable setObject:[UIColor underPageBackgroundColor]
                     forKey:@"underPageBackgroundColor"];
    }

    sColorTable = [colorTable copy];
    NI_RELEASE_SAFELY(colorTable);
  }
  return sColorTable;
}

@end
