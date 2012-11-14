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

#import "NICSSRuleset.h"

#import "NICSSParser.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static NSString* const kTextColorKey = @"color";
static NSString* const kHighlightedTextColorKey = @"-ios-highlighted-color";
static NSString* const kTextAlignmentKey = @"text-align";
static NSString* const kFontKey = @"font";
static NSString* const kFontSizeKey = @"font-size";
static NSString* const kFontStyleKey = @"font-style";
static NSString* const kFontWeightKey = @"font-weight";
static NSString* const kFontFamilyKey = @"font-family";
static NSString* const kTextShadowKey = @"text-shadow";
static NSString* const kLineBreakModeKey = @"-ios-line-break-mode";
static NSString* const kNumberOfLinesKey = @"-ios-number-of-lines";
static NSString* const kMinimumFontSizeKey = @"-ios-minimum-font-size";
static NSString* const kAdjustsFontSizeKey = @"-ios-adjusts-font-size";
static NSString* const kBaselineAdjustmentKey = @"-ios-baseline-adjustment";
static NSString* const kOpacityKey = @"opacity";
static NSString* const kBackgroundColorKey = @"background-color";
static NSString* const kBorderRadiusKey = @"border-radius";
static NSString* const kBorderKey = @"border";
static NSString* const kBorderColorKey = @"border-color";
static NSString* const kBorderWidthKey = @"border-width";
static NSString* const kTintColorKey = @"-ios-tint-color";
static NSString* const kActivityIndicatorStyleKey = @"-ios-activity-indicator-style";
static NSString* const kAutoresizingKey = @"-ios-autoresizing";
static NSString* const kTableViewCellSeparatorStyleKey = @"-ios-table-view-cell-separator-style";
static NSString* const kScrollViewIndicatorStyleKey = @"-ios-scroll-view-indicator-style";

// This color table is generated on-demand and is released when a memory warning is encountered.
static NSDictionary* sColorTable = nil;

@interface NICSSRuleset()
// Instantiates the color table if it does not already exist.
+ (NSDictionary *)colorTable;
+ (UIColor *)colorFromCssValues:(NSArray *)cssValues numberOfConsumedTokens:(NSInteger *)pNumberOfConsumedTokens;
+ (UITextAlignment)textAlignmentFromCssValues:(NSArray *)cssValues;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICSSRuleset


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _ruleset = [[NSMutableDictionary alloc] init];

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
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary {
  NSMutableArray* order = [_ruleset objectForKey:kPropertyOrderKey];
  [_ruleset addEntriesFromDictionary:dictionary];

  if (nil != order) {
    [order addObjectsFromArray:[dictionary objectForKey:kPropertyOrderKey]];
    [_ruleset setObject:order forKey:kPropertyOrderKey];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTextColor {
  return nil != [_ruleset objectForKey:kTextColorKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)textColor {
  NIDASSERT([self hasTextColor]);
  if (!_is.cached.TextColor) {
    _textColor = [[self class] colorFromCssValues:[_ruleset objectForKey:kTextColorKey]
                           numberOfConsumedTokens:nil];
    _is.cached.TextColor = YES;
  }
  return _textColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasHighlightedTextColor {
    return nil != [_ruleset objectForKey:kHighlightedTextColorKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)highlightedTextColor {
  NIDASSERT([self hasHighlightedTextColor]);
  if (!_is.cached.HighlightedTextColor) {
    _highlightedTextColor = [[self class] colorFromCssValues:[_ruleset objectForKey:kHighlightedTextColorKey]
                                      numberOfConsumedTokens:nil];
    _is.cached.HighlightedTextColor = YES;
  }
  return _highlightedTextColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTextAlignment {
  return nil != [_ruleset objectForKey:kTextAlignmentKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextAlignment)textAlignment {
  NIDASSERT([self hasTextAlignment]);
  if (!_is.cached.TextAlignment) {
    _textAlignment = [[self class] textAlignmentFromCssValues:[_ruleset objectForKey:kTextAlignmentKey]];
    _is.cached.TextAlignment = YES;
  }
  return _textAlignment;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasFont {
  return (nil != [_ruleset objectForKey:kFontKey]
          || nil != [_ruleset objectForKey:kFontSizeKey]
          || nil != [_ruleset objectForKey:kFontWeightKey]
          || nil != [_ruleset objectForKey:kFontStyleKey]
          || nil != [_ruleset objectForKey:kFontFamilyKey]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont *)font {
  NIDASSERT([self hasFont]);
  
  if (_is.cached.Font) {
    return _font;
  }

  NSString* fontName = nil;
  CGFloat fontSize = [UIFont systemFontSize];
  BOOL fontIsBold = NO;
  BOOL fontIsItalic = NO;
  
  NSArray* values = [_ruleset objectForKey:kFontWeightKey];
  if (nil != values) {
    NIDASSERT([values count] == 1);
    fontIsBold = [[values objectAtIndex:0] isEqualToString:@"bold"];
  }
  
  values = [_ruleset objectForKey:kFontStyleKey];
  if (nil != values) {
    NIDASSERT([values count] == 1);
    fontIsItalic = [[values objectAtIndex:0] isEqualToString:@"italic"];
  }

  // There are two ways to set font size and family: font and font-size/font-family.
  // Newer definitions of these values should overwrite previous definitions so we must
  // respect ordering here.
  BOOL hasSetFontName = NO;
  BOOL hasSetFontSize = NO;

  NSArray* order = [_ruleset objectForKey:kPropertyOrderKey];
  for (NSString* name in [order reverseObjectEnumerator]) {
    if (!hasSetFontName && [name isEqualToString:kFontFamilyKey]) {
      values = [_ruleset objectForKey:name];
      NIDASSERT([values count] == 1); if ([values count] < 1) { continue; }
      fontName = [[values objectAtIndex:0] stringByTrimmingCharactersInSet:
                  [NSCharacterSet characterSetWithCharactersInString:@"\""]];
      hasSetFontName = YES;

    } else if (!hasSetFontSize && [name isEqualToString:kFontSizeKey]) {
      values = [_ruleset objectForKey:name];
      NIDASSERT([values count] == 1); if ([values count] < 1) { continue; }
      NSString* value = [values objectAtIndex:0];
      if ([value isEqualToString:@"default"]) {
        fontSize = [UIFont systemFontSize];

      } else {
        fontSize = [value floatValue];
      }
      hasSetFontSize = YES;

    } else if (!hasSetFontSize && !hasSetFontName && [name isEqualToString:kFontKey]) {
      values = [_ruleset objectForKey:name];
      NIDASSERT([values count] <= 2); if ([values count] < 1) { continue; }

      if ([values count] >= 1) {
        // Font size
        fontSize = [[values objectAtIndex:0] floatValue];
        hasSetFontSize = YES;
      }
      if ([values count] >= 2) {
        // Font name
        fontName = [[values objectAtIndex:1] stringByTrimmingCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"\""]];
        hasSetFontName = YES;
      }
    }

    if (hasSetFontName && hasSetFontSize) {
      // Once we've set all values then we can ignore any previous values.
      break;
    }
  }
  
  UIFont* font = nil;
  if (hasSetFontName) {
    // If you wish to set the weight and style for a non-standard font family then you will need
    // to set the font family to the given style manually.
    NIDASSERT(!fontIsItalic && !fontIsBold);
    font = [UIFont fontWithName:fontName size:fontSize];

  } else if (fontIsItalic && fontIsBold) {
    // There is no easy way to create a bold italic font using the exposed UIFont methods.
    // Please consider using the exact font name instead. E.g. font-name: Helvetica-BoldObliquei
    NIDASSERT(NO);
    font = [UIFont systemFontOfSize:fontSize];

  } else if (fontIsItalic) {
    font = [UIFont italicSystemFontOfSize:fontSize];

  } else if (fontIsBold) {
    font = [UIFont boldSystemFontOfSize:fontSize];

  } else {
    font = [UIFont systemFontOfSize:fontSize];
  }

  _font = font;
  _is.cached.Font = YES;

  return font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTextShadowColor {
  return nil != [_ruleset objectForKey:kTextShadowKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)textShadowColor {
  NIDASSERT([self hasTextShadowColor]);
  if (!_is.cached.TextShadowColor) {
    NSArray* values = [_ruleset objectForKey:kTextShadowKey];
    _textShadowColor = [[self class] colorFromCssValues:values numberOfConsumedTokens:nil];
    _is.cached.TextShadowColor = YES;
  }
  return _textShadowColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTextShadowOffset {
  return nil != [_ruleset objectForKey:kTextShadowKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)textShadowOffset {
  NIDASSERT([self hasTextShadowOffset]);
  if (!_is.cached.TextShadowOffset) {
    NSArray* values = [_ruleset objectForKey:kTextShadowKey];
    NSInteger skipTokens = 0;
    [[self class] colorFromCssValues:values numberOfConsumedTokens:&skipTokens];

    _textShadowOffset = CGSizeZero;
    if ([values count] - skipTokens >= 1) {
      _textShadowOffset.width = [[values objectAtIndex:skipTokens] floatValue];
    }
    if ([values count] - skipTokens >= 2) {
      _textShadowOffset.height = [[values objectAtIndex:skipTokens + 1] floatValue];
    }
    _is.cached.TextShadowOffset = YES;
  }
  return _textShadowOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasLineBreakMode {
  return nil != [_ruleset objectForKey:kLineBreakModeKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILineBreakMode)lineBreakMode {
  NIDASSERT([self hasLineBreakMode]);
  if (!_is.cached.LineBreakMode) {
    NSArray* values = [_ruleset objectForKey:kLineBreakModeKey];
    NIDASSERT([values count] == 1);
    NSString* value = [values objectAtIndex:0];
    if ([value isEqualToString:@"wrap"]) {
      _lineBreakMode = UILineBreakModeWordWrap;
    } else if ([value isEqualToString:@"character-wrap"]) {
      _lineBreakMode = UILineBreakModeCharacterWrap;
    } else if ([value isEqualToString:@"clip"]) {
      _lineBreakMode = UILineBreakModeClip;
    } else if ([value isEqualToString:@"head-truncate"]) {
      _lineBreakMode = UILineBreakModeHeadTruncation;
    } else if ([value isEqualToString:@"tail-truncate"]) {
      _lineBreakMode = UILineBreakModeTailTruncation;
    } else if ([value isEqualToString:@"middle-truncate"]) {
      _lineBreakMode = UILineBreakModeMiddleTruncation;
    } else {
      _lineBreakMode = UILineBreakModeWordWrap;
    }
    _is.cached.LineBreakMode = YES;
  }
  return _lineBreakMode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasNumberOfLines {
  return nil != [_ruleset objectForKey:kNumberOfLinesKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfLines {
  NIDASSERT([self hasNumberOfLines]);
  if (!_is.cached.NumberOfLines) {
    NSArray* values = [_ruleset objectForKey:kNumberOfLinesKey];
    NIDASSERT([values count] == 1);
    _numberOfLines = [[values objectAtIndex:0] intValue];
    _is.cached.NumberOfLines = YES;
  }
  return _numberOfLines;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasMinimumFontSize {
  return nil != [_ruleset objectForKey:kMinimumFontSizeKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)minimumFontSize {
  NIDASSERT([self hasMinimumFontSize]);
  if (!_is.cached.MinimumFontSize) {
    NSArray* values = [_ruleset objectForKey:kMinimumFontSizeKey];
    NIDASSERT([values count] == 1);
    _minimumFontSize = [[values objectAtIndex:0] floatValue];
    _is.cached.MinimumFontSize = YES;
  }
  return _minimumFontSize;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasAdjustsFontSize {
  return nil != [_ruleset objectForKey:kAdjustsFontSizeKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)adjustsFontSize {
  NIDASSERT([self hasAdjustsFontSize]);
  if (!_is.cached.AdjustsFontSize) {
    NSArray* values = [_ruleset objectForKey:kAdjustsFontSizeKey];
    NIDASSERT([values count] == 1);
    _adjustsFontSize = [[values objectAtIndex:0] boolValue];
    _is.cached.AdjustsFontSize = YES;
  }
  return _adjustsFontSize;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasBaselineAdjustment {
  return nil != [_ruleset objectForKey:kBaselineAdjustmentKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIBaselineAdjustment)baselineAdjustment {
  NIDASSERT([self hasBaselineAdjustment]);
  if (!_is.cached.BaselineAdjustment) {
    NSArray* values = [_ruleset objectForKey:kBaselineAdjustmentKey];
    NIDASSERT([values count] == 1);
    NSString* value = [values objectAtIndex:0];
    if ([value isEqualToString:@"align-baselines"]) {
      _baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    } else if ([value isEqualToString:@"align-centers"]) {
      _baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    } else {
      _baselineAdjustment = UIBaselineAdjustmentNone;
    }
    _is.cached.BaselineAdjustment = YES;
  }
  return _baselineAdjustment;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasOpacity {
  return nil != [_ruleset objectForKey:kOpacityKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)opacity {
  NIDASSERT([self hasOpacity]);
  if (!_is.cached.Opacity) {
    NSArray* values = [_ruleset objectForKey:kOpacityKey];
    NIDASSERT([values count] == 1);
    _opacity = [[values objectAtIndex:0] floatValue];
    _is.cached.Opacity = YES;
  }
  return _opacity;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasBackgroundColor {
  return nil != [_ruleset objectForKey:kBackgroundColorKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)backgroundColor {
  NIDASSERT([self hasBackgroundColor]);
  if (!_is.cached.BackgroundColor) {
    _backgroundColor = [[self class] colorFromCssValues:[_ruleset objectForKey:kBackgroundColorKey]
                                 numberOfConsumedTokens:nil];
    _is.cached.BackgroundColor = YES;
  }
  return _backgroundColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasBorderRadius {
  return nil != [_ruleset objectForKey:kBorderRadiusKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)borderRadius {
  NIDASSERT([self hasBorderRadius]);
  if (!_is.cached.BorderRadius) {
    NSArray* values = [_ruleset objectForKey:kBorderRadiusKey];
    NIDASSERT([values count] == 1);
    _borderRadius = [[values objectAtIndex:0] floatValue];
    _is.cached.BorderRadius = YES;
  }
  return _borderRadius;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasBorderColor {
  return (nil != [_ruleset objectForKey:kBorderColorKey]
          || nil != [_ruleset objectForKey:kBorderKey]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cacheBorderValues {
  _borderWidth = 0;
  _borderColor = nil;

  NSArray* values = nil;

  // There are two ways to set border color and width: border and border-color/border-width.
  // Newer definitions of these values should overwrite previous definitions so we must
  // respect ordering here.
  BOOL hasSetBorderColor = NO;
  BOOL hasSetBorderWidth = NO;

  NSArray* order = [_ruleset objectForKey:kPropertyOrderKey];
  for (NSString* name in [order reverseObjectEnumerator]) {
    if (!hasSetBorderColor && [name isEqualToString:kBorderColorKey]) {
      values = [_ruleset objectForKey:name];
      _borderColor = [[self class] colorFromCssValues:values
                               numberOfConsumedTokens:nil];
      hasSetBorderColor = YES;

    } else if (!hasSetBorderWidth && [name isEqualToString:kBorderWidthKey]) {
      values = [_ruleset objectForKey:name];
      NIDASSERT([values count] == 1); if ([values count] < 1) { continue; }
      _borderWidth = [[values objectAtIndex:0] floatValue];
      hasSetBorderWidth = YES;

    } else if (!hasSetBorderColor && !hasSetBorderWidth && [name isEqualToString:kBorderKey]) {
      values = [_ruleset objectForKey:name];

      if ([values count] >= 1) {
        // Border width
        _borderWidth = [[values objectAtIndex:0] floatValue];
        hasSetBorderWidth = YES;
      }
      if ([values count] >= 3) {
        // Border color
        _borderColor = [[self class] colorFromCssValues:[values subarrayWithRange:NSMakeRange(2, [values count] - 2)]
                                 numberOfConsumedTokens:nil];
        hasSetBorderColor = YES;
      }
    }
    
    if (hasSetBorderColor && hasSetBorderWidth) {
      // Once we've set all values then we can ignore any previous values.
      break;
    }
  }
  
  _is.cached.BorderColor = hasSetBorderColor;
  _is.cached.BorderWidth = hasSetBorderWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)borderColor {
  NIDASSERT([self hasBorderColor]);

  [self cacheBorderValues];
  return _borderColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasBorderWidth {
  return (nil != [_ruleset objectForKey:kBorderWidthKey]
          || nil != [_ruleset objectForKey:kBorderKey]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)borderWidth {
  NIDASSERT([self hasBorderWidth]);

  [self cacheBorderValues];
  return _borderWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTintColor {
  return nil != [_ruleset objectForKey:kTintColorKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)tintColor {
  NIDASSERT([self hasTintColor]);
  if (!_is.cached.TintColor) {
    _tintColor = [[self class] colorFromCssValues:[_ruleset objectForKey:kTintColorKey]
                           numberOfConsumedTokens:nil];
    _is.cached.TintColor = YES;
  }
  return _tintColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasActivityIndicatorStyle {
  return nil != [_ruleset objectForKey:kActivityIndicatorStyleKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIActivityIndicatorViewStyle)activityIndicatorStyle {
  NIDASSERT([self hasActivityIndicatorStyle]);
  if (!_is.cached.ActivityIndicatorStyle) {
    NSArray* values = [_ruleset objectForKey:kActivityIndicatorStyleKey];
    NIDASSERT([values count] == 1);
    NSString* value = [values objectAtIndex:0];
    if ([value isEqualToString:@"white"]) {
      _activityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    } else if ([value isEqualToString:@"gray"]) {
      _activityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    } else {
      _activityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    _is.cached.ActivityIndicatorStyle = YES;
  }
  return _activityIndicatorStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasAutoresizing {
  return nil != [_ruleset objectForKey:kAutoresizingKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewAutoresizing)autoresizing {
  NIDASSERT([self hasAutoresizing]);
  if (!_is.cached.Autoresizing) {
    NSArray* values = [_ruleset objectForKey:kAutoresizingKey];
    UIViewAutoresizing autoresizing = UIViewAutoresizingNone;
    for (NSString* value in values) {
      if ([value isEqualToString:@"left"]) {
        autoresizing |= UIViewAutoresizingFlexibleLeftMargin;
      } else if ([value isEqualToString:@"top"]) {
        autoresizing |= UIViewAutoresizingFlexibleTopMargin;
      } else if ([value isEqualToString:@"right"]) {
        autoresizing |= UIViewAutoresizingFlexibleRightMargin;
      } else if ([value isEqualToString:@"bottom"]) {
        autoresizing |= UIViewAutoresizingFlexibleBottomMargin;
      } else if ([value isEqualToString:@"width"]) {
        autoresizing |= UIViewAutoresizingFlexibleWidth;
      } else if ([value isEqualToString:@"height"]) {
        autoresizing |= UIViewAutoresizingFlexibleHeight;
      } else if ([value isEqualToString:@"all"]) {
        autoresizing |= UIViewAutoresizingFlexibleDimensions | UIViewAutoresizingFlexibleMargins;
      } else if ([value isEqualToString:@"margins"]) {
        autoresizing |= UIViewAutoresizingFlexibleMargins;
      } else if ([value isEqualToString:@"dimensions"]) {
        autoresizing |= UIViewAutoresizingFlexibleDimensions;
      }
    }
    _autoresizing = autoresizing;
    _is.cached.Autoresizing = YES;
  }
  return _autoresizing;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasTableViewCellSeparatorStyle {
  return nil != [_ruleset objectForKey:kTableViewCellSeparatorStyleKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellSeparatorStyle)tableViewCellSeparatorStyle {
  NIDASSERT([self hasTableViewCellSeparatorStyle]);
  if (!_is.cached.TableViewCellSeparatorStyle) {
    NSArray* values = [_ruleset objectForKey:kActivityIndicatorStyleKey];
    NIDASSERT([values count] == 1);
    NSString* value = [values objectAtIndex:0];
    UITableViewCellSeparatorStyle style = UITableViewCellSeparatorStyleSingleLine;
    if ([value isEqualToString:@"none"]) {
      style = UITableViewCellSeparatorStyleNone;
    } else if ([value isEqualToString:@"single-line-etched"]) {
      style = UITableViewCellSeparatorStyleSingleLineEtched;
    }
    _tableViewCellSeparatorStyle = style;
    _is.cached.TableViewCellSeparatorStyle = YES;
  }
  return _tableViewCellSeparatorStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasScrollViewIndicatorStyle {
  return nil != [_ruleset objectForKey:kScrollViewIndicatorStyleKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle {
  NIDASSERT([self hasScrollViewIndicatorStyle]);
  if (!_is.cached.ScrollViewIndicatorStyle) {
    NSArray* values = [_ruleset objectForKey:kScrollViewIndicatorStyleKey];
    NIDASSERT([values count] == 1);
    NSString* value = [values objectAtIndex:0];
    UIScrollViewIndicatorStyle style = UIScrollViewIndicatorStyleDefault;
    if ([value isEqualToString:@"black"]) {
      style = UIScrollViewIndicatorStyleBlack;
    } else if ([value isEqualToString:@"white"]) {
      style = UIScrollViewIndicatorStyleWhite;
    }
    _scrollViewIndicatorStyle = style;
    _is.cached.ScrollViewIndicatorStyle = YES;
  }
  return _scrollViewIndicatorStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSNotifications



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reduceMemory {
  sColorTable = nil;

  _textColor = nil;
  _font = nil;
  _textShadowColor = nil;
  _backgroundColor = nil;
  _borderColor = nil;
  _tintColor = nil;

  memset(&_is, 0, sizeof(_is));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning:(void*)object {
  [self reduceMemory];
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
      UIColor* color = [UIColor scrollViewTexturedBackgroundColor];
      if (nil != color) {
        [colorTable setObject:color
                       forKey:@"scrollViewTexturedBackgroundColor"];
      }
    }
    
    if ([UIColor respondsToSelector:@selector(underPageBackgroundColor)]) {
      // 5.0 and up
      UIColor* color = [UIColor underPageBackgroundColor];
      if (nil != color) {
        [colorTable setObject:color
                       forKey:@"underPageBackgroundColor"];
      }
    }

    // Replace the web colors with their system color equivalents.
    [colorTable setObject:[UIColor blackColor] forKey:@"black"];
    [colorTable setObject:[UIColor darkGrayColor] forKey:@"darkGray"];
    [colorTable setObject:[UIColor lightGrayColor] forKey:@"lightGray"];
    [colorTable setObject:[UIColor whiteColor] forKey:@"white"];
    [colorTable setObject:[UIColor grayColor] forKey:@"gray"];
    [colorTable setObject:[UIColor redColor] forKey:@"red"];
    [colorTable setObject:[UIColor greenColor] forKey:@"green"];
    [colorTable setObject:[UIColor blueColor] forKey:@"blue"];
    [colorTable setObject:[UIColor cyanColor] forKey:@"cyan"];
    [colorTable setObject:[UIColor yellowColor] forKey:@"yellow"];
    [colorTable setObject:[UIColor magentaColor] forKey:@"magenta"];
    [colorTable setObject:[UIColor orangeColor] forKey:@"orange"];
    [colorTable setObject:[UIColor purpleColor] forKey:@"purple"];
    [colorTable setObject:[UIColor brownColor] forKey:@"brown"];
    [colorTable setObject:[UIColor clearColor] forKey:@"clear"];

    sColorTable = [colorTable copy];
  }
  return sColorTable;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIColor *)colorFromCssValues:(NSArray *)cssValues numberOfConsumedTokens:(NSInteger *)pNumberOfConsumedTokens {
  NSInteger bogus = 0;
  if (nil == pNumberOfConsumedTokens) {
    pNumberOfConsumedTokens = &bogus;
  }
  UIColor* color = nil;

  if ([cssValues count] >= 6 && [[cssValues objectAtIndex:0] isEqualToString:@"rgba("]) {
    // rgba( x x x x )
    color = RGBACOLOR([[cssValues objectAtIndex:1] floatValue],
                      [[cssValues objectAtIndex:2] floatValue],
                      [[cssValues objectAtIndex:3] floatValue],
                      [[cssValues objectAtIndex:4] floatValue]);
    *pNumberOfConsumedTokens = 6;

  } else if ([cssValues count] >= 5 && [[cssValues objectAtIndex:0] isEqualToString:@"rgb("]) {
    // rgb( x x x )
    color = RGBCOLOR([[cssValues objectAtIndex:1] floatValue],
                     [[cssValues objectAtIndex:2] floatValue],
                     [[cssValues objectAtIndex:3] floatValue]);
    *pNumberOfConsumedTokens = 5;
    
  } else if ([cssValues count] >= 1) {
    NSString* cssString = [cssValues objectAtIndex:0];

    if ([cssString characterAtIndex:0] == '#') {
      unsigned long colorValue = 0;

      // #FFF
      if ([cssString length] == 4) {
        colorValue = strtol([cssString UTF8String] + 1, nil, 16);
        colorValue = ((colorValue & 0xF00) << 12) | ((colorValue & 0xF00) << 8)
        | ((colorValue & 0xF0) << 8) | ((colorValue & 0xF0) << 4)
        | ((colorValue & 0xF) << 4) | (colorValue & 0xF);

      // #FFFFFF
      } else if ([cssString length] == 7) {
        colorValue = strtol([cssString UTF8String] + 1, nil, 16);
      }

      color = RGBCOLOR(((colorValue & 0xFF0000) >> 16),
                       ((colorValue & 0xFF00) >> 8),
                       (colorValue & 0xFF));

    } else {
      color = [[self colorTable] objectForKey:cssString];
    }

    *pNumberOfConsumedTokens = 1;
  }
  return color;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UITextAlignment)textAlignmentFromCssValues:(NSArray *)cssValues {
  NIDASSERT([cssValues count] == 1);
  if ([cssValues count] < 1) {
    return UITextAlignmentLeft;
  }

  NSString* value = [cssValues objectAtIndex:0];

  UITextAlignment textAlignment = UITextAlignmentLeft;
  
  if ([value isEqualToString:@"center"]) {
    textAlignment = UITextAlignmentCenter;

  } else if ([value isEqualToString:@"right"]) {
    textAlignment = UITextAlignmentRight;
  }

  return textAlignment;
}

@end
