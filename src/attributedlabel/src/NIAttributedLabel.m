//
// Copyright 2011 Roger Chapman
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

#import "NIAttributedLabel.h"

#import "NimbusCore.h"
#import "NSMutableAttributedString+NimbusAttributedLabel.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kVMargin = 5.0f;
static const NSTimeInterval kLongPressTimeInterval = 0.5;
static const CGFloat kLongPressGutter = 22;

// The touch gutter is the amount of space around a link that will still register as tapping
// "within" the link.
static const CGFloat kTouchGutter = 22;

static UIEdgeInsets kBoundsInsets = {-5, -5, -5, -5};

@interface NIAttributedLabel() <UIActionSheetDelegate>
@property (nonatomic, readwrite, retain) NSMutableAttributedString* mutableAttributedString;
@property (nonatomic, readwrite, assign) CTFrameRef textFrame;
@property (readwrite, assign) BOOL detectingLinks; // Atomic.
@property (nonatomic, readwrite, assign) BOOL linksHaveBeenDetected;
@property (nonatomic, readwrite, copy) NSArray* detectedlinkLocations;
@property (nonatomic, readwrite, retain) NSMutableArray* explicitLinkLocations;
@property (nonatomic, readwrite, retain) NSTextCheckingResult* originalLink;
@property (nonatomic, readwrite, retain) NSTextCheckingResult* touchedLink;
@property (nonatomic, readwrite, retain) NSTimer* longPressTimer;
@property (nonatomic, readwrite, assign) CGPoint touchPoint;
@property (nonatomic, readwrite, retain) NSTextCheckingResult* actionSheetLink;
@end


@interface NIAttributedLabel(ConversionUtilities)
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment;
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(UILineBreakMode)lineBreakMode;
#else
+ (CTTextAlignment)alignmentFromUITextAlignment:(NSTextAlignment)alignment;
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(NSLineBreakMode)lineBreakMode;
#endif
+ (NSMutableAttributedString *)mutableAttributedStringFromLabel:(UILabel *)label;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel

@synthesize mutableAttributedString = _mutableAttributedString;
@synthesize textFrame = _textFrame;
@synthesize detectingLinks = _detectingLinks;
@synthesize linksHaveBeenDetected = _linksHaveBeenDetected;
@synthesize detectedlinkLocations = _detectedlinkLocations;
@synthesize explicitLinkLocations = _explicitLinkLocations;
@synthesize originalLink = _originalLink;
@synthesize touchedLink = _touchedLink;
@synthesize longPressTimer = _longPressTimer;
@synthesize touchPoint = _touchPoint;
@synthesize actionSheetLink = _actionSheetLink;
@synthesize autoDetectLinks = _autoDetectLinks;
@synthesize deferLinkDetection = _deferLinkDetection;
@synthesize dataDetectorTypes = _dataDetectorTypes;
@synthesize verticalTextAlignment = _verticalTextAlignment;
@synthesize underlineStyle = _underlineStyle;
@synthesize underlineStyleModifier = _underlineStyleModifier;
@synthesize shadowBlur;
@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;
@synthesize textKern = _textKern;
@synthesize linkColor = _linkColor;
@synthesize highlightedLinkBackgroundColor = _highlightedLinkBackgroundColor;
@synthesize linksHaveUnderlines = _linksHaveUnderlines;
@synthesize attributesForLinks = _attributesForLinks;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_longPressTimer invalidate];

  if (nil != _textFrame) {
    CFRelease(_textFrame);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_configureDefaults {
  self.verticalTextAlignment = NIVerticalTextAlignmentTop;
  self.linkColor = [UIColor blueColor];
  self.dataDetectorTypes = NSTextCheckingTypeLink;
  self.highlightedLinkBackgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self _configureDefaults];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib {
  [super awakeFromNib];
  
  [self _configureDefaults];

  NSMutableAttributedString* attributedText = [[self class] mutableAttributedStringFromLabel:self];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  self.attributedString = attributedText;
#else
  self.attributedText = attributedText;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetTextFrame {
  if (nil != self.textFrame) {
    CFRelease(self.textFrame);
    self.textFrame = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attributedTextDidChange {
  [self resetTextFrame];

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)frame {
  BOOL frameDidChange = !CGRectEqualToRect(self.frame, frame);

  [super setFrame:frame];

  if (frameDidChange) {
    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBounds:(CGRect)bounds {
  bounds = UIEdgeInsetsInsetRect(bounds, kBoundsInsets);

  BOOL boundsDidChange = !CGRectEqualToRect(self.bounds, bounds);
  
  [super setBounds:bounds];

  if (boundsDidChange) {
    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  if (nil == self.mutableAttributedString) {
    return CGSizeZero;
  }

  CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)self.mutableAttributedString;
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
  CFRange fitCFRange = CFRangeMake(0,0);
  CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, size, &fitCFRange);

  if (nil != framesetter) {
    CFRelease(framesetter);
    framesetter = nil;
  }

  return CGSizeMake(ceilf(newSize.width), ceilf(newSize.height));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString *)text {
  [super setText:text];

  NSMutableAttributedString* attributedText = [[self class] mutableAttributedStringFromLabel:self];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
  self.attributedString = attributedText;
#else
  self.attributedText = attributedText;
#endif
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Deprecated method.
- (NSAttributedString *)attributedString {
  return [self.mutableAttributedString copy];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= NIIOS_6_0
- (NSAttributedString *)attributedText {
  return [self.mutableAttributedString copy];
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAttributedString:(NSAttributedString *)attributedText {
  if (self.mutableAttributedString != attributedText) {
    self.mutableAttributedString = [attributedText mutableCopy];
    
    // Clear the link caches.
    self.detectedlinkLocations = nil;
    self.linksHaveBeenDetected = NO;
    [self removeAllExplicitLinks];
    
    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= NIIOS_6_0
- (void)setAttributedText:(NSAttributedString *)attributedText {
  if (self.mutableAttributedString != attributedText) {
    self.mutableAttributedString = [attributedText mutableCopy];
    
    // Clear the link caches.
    self.detectedlinkLocations = nil;
    self.linksHaveBeenDetected = NO;
    [self removeAllExplicitLinks];
    
    [self attributedTextDidChange];
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAutoDetectLinks:(BOOL)autoDetectLinks {
  _autoDetectLinks = autoDetectLinks;

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addLink:(NSURL *)urlLink range:(NSRange)range {
  if (nil == self.explicitLinkLocations) {
    self.explicitLinkLocations = [[NSMutableArray alloc] init];
  }

  NSTextCheckingResult* result = [NSTextCheckingResult linkCheckingResultWithRange:range URL:urlLink];
  [self.explicitLinkLocations addObject:result];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllExplicitLinks {
  self.explicitLinkLocations = nil;

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
- (void)setTextAlignment:(UITextAlignment)textAlignment {
  // We assume that the UILabel implementation will call setNeedsDisplay. Where we don't call super
  // we call setNeedsDisplay ourselves.
  [super setTextAlignment:textAlignment];
  
  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:self.lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}
#else
- (void)setTextAlignment:(NSTextAlignment)textAlignment {
  // We assume that the UILabel implementation will call setNeedsDisplay. Where we don't call super
  // we call setNeedsDisplay ourselves.
  if (NSTextAlignmentJustified == textAlignment) {
    // iOS 6.0 Beta 2 crashes when using justified text alignments for some reason.
    [super setTextAlignment:NSTextAlignmentLeft];
  } else {
    [super setTextAlignment:textAlignment];
  }
  
  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:self.lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
  [super setLineBreakMode:lineBreakMode];

  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}
#else
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
  [super setLineBreakMode:lineBreakMode];
  
  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)textColor {
  [super setTextColor:textColor];

  [self.mutableAttributedString setTextColor:textColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
  [self.mutableAttributedString setTextColor:textColor range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont *)font {
  [super setFont:font];

  [self.mutableAttributedString setFont:font];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont *)font range:(NSRange)range {
  [self.mutableAttributedString setFont:font range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style {
  if (style != _underlineStyle) {
    _underlineStyle = style;
    [self.mutableAttributedString setUnderlineStyle:style modifier:self.underlineStyleModifier];

    [self attributedTextDidChange];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyleModifier:(CTUnderlineStyleModifiers)modifier {
  if (modifier != _underlineStyleModifier) {
    _underlineStyleModifier = modifier;
    [self.mutableAttributedString setUnderlineStyle:self.underlineStyle  modifier:modifier];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range {
  [self.mutableAttributedString setUnderlineStyle:style modifier:modifier range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)strokeWidth {
  if (_strokeWidth != strokeWidth) {
    _strokeWidth = strokeWidth;
    [self.mutableAttributedString setStrokeWidth:strokeWidth];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range {
  [self.mutableAttributedString setStrokeWidth:width range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)strokeColor {
  if (_strokeColor != strokeColor) {
    _strokeColor = strokeColor;
    [self.mutableAttributedString setStrokeColor:_strokeColor];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor*)color range:(NSRange)range {
  [self.mutableAttributedString setStrokeColor:color range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextKern:(CGFloat)textKern {
  if (_textKern != textKern) {
    _textKern = textKern;
    [self.mutableAttributedString setKern:_textKern];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextKern:(CGFloat)kern range:(NSRange)range {
  [self.mutableAttributedString setKern:kern range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinkColor:(UIColor *)linkColor {
  if (_linkColor != linkColor) {
    _linkColor = linkColor;

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sethighlightedLinkBackgroundColor:(UIColor *)highlightedLinkBackgroundColor {
  if (_highlightedLinkBackgroundColor != highlightedLinkBackgroundColor) {
    _highlightedLinkBackgroundColor = highlightedLinkBackgroundColor;

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinksHaveUnderlines:(BOOL)linksHaveUnderlines {
  if (_linksHaveUnderlines != linksHaveUnderlines) {
    _linksHaveUnderlines = linksHaveUnderlines;

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAttributesForLinks:(NSDictionary *)attributesForLinks {
  if (_attributesForLinks != attributesForLinks) {
    _attributesForLinks = attributesForLinks;

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)_matchesFromAttributedString:(NSString *)string {
  NSError* error = nil;
  NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:self.dataDetectorTypes
                                                                 error:&error];
  NSRange range = NSMakeRange(0, string.length);
  
  return [linkDetector matchesInString:string options:0 range:range];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_deferLinkDetection {
  if (!self.detectingLinks) {
    self.detectingLinks = YES;

    NSString* string = [self.mutableAttributedString.string copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSArray* matches = [self _matchesFromAttributedString:string];
      self.detectingLinks = NO;

      dispatch_async(dispatch_get_main_queue(), ^{
        self.detectedlinkLocations = matches;
        self.linksHaveBeenDetected = YES;

        [self attributedTextDidChange];
      });
    });
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Use an NSDataDetector to find any implicit links in the text. The results are cached until
// the text changes.
- (void)detectLinks {
  if (nil == self.mutableAttributedString) {
    return;
  }

  if (self.autoDetectLinks && !self.linksHaveBeenDetected) {
    if (self.deferLinkDetection) {
      [self _deferLinkDetection];

    } else {
      self.detectedlinkLocations = [self _matchesFromAttributedString:self.mutableAttributedString.string];
      self.linksHaveBeenDetected = YES;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
  CGFloat ascent = 0.0f;
  CGFloat descent = 0.0f;
  CGFloat leading = 0.0f;
  CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
  CGFloat height = ascent + descent;
  
  return CGRectMake(point.x, point.y - descent, width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSTextCheckingResult *)linkAtIndex:(CFIndex)i {
  NSTextCheckingResult* foundResult = nil;

  if (self.autoDetectLinks) {
    [self detectLinks];

    for (NSTextCheckingResult* result in self.detectedlinkLocations) {
      if (NSLocationInRange(i, result.range)) {
        foundResult = result;
        break;
      }
    }
  }

  if (nil == foundResult) {
    for (NSTextCheckingResult* result in self.explicitLinkLocations) {
      if (NSLocationInRange(i, result.range)) {
        foundResult = result;
        break;
      }
    }
  }

  return foundResult;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)_verticalOffsetForBounds:(CGRect)bounds {
  CGFloat verticalOffset = 0;
  if (NIVerticalTextAlignmentTop != self.verticalTextAlignment) {
    // When the text is attached to the top we can easily just start drawing and leave the
    // remainder. This is the most performant case.
    // With other alignment modes we must calculate the size of the text first.
    CGSize textSize = [self sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)];

    if (NIVerticalTextAlignmentMiddle == self.verticalTextAlignment) {
      verticalOffset = floorf((bounds.size.height - textSize.height) / 2.f);
      
    } else if (NIVerticalTextAlignmentBottom == self.verticalTextAlignment) {
      verticalOffset = bounds.size.height - textSize.height;
    }
  }
  return verticalOffset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGAffineTransform)_transformForCoreText {
  // CoreText context coordinates are the opposite to UIKit so we flip the bounds
  return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSTextCheckingResult *)linkAtPoint:(CGPoint)point {
  if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), point)) {
    return nil;
  }

  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  if (!lines) return nil;
  CFIndex count = CFArrayGetCount(lines);

  NSTextCheckingResult* foundLink = nil;

  CGPoint origins[count];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0,0), origins);
  
  CGAffineTransform transform = [self _transformForCoreText];
  CGFloat verticalOffset = [self _verticalOffsetForBounds:self.bounds];

  // Our bounds may have a non-zero offset, so we must take this into account when doing hit
  // detection.
  point.x += kBoundsInsets.left;
  point.y -= kBoundsInsets.top;

  for (int i = 0; i < count; i++) {
    CGPoint linePoint = origins[i];

    CTLineRef line = CFArrayGetValueAtIndex(lines, i);
    CGRect flippedRect = [self getLineBounds:line point:linePoint];
    CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);

    rect = CGRectInset(rect, 0, -kVMargin);
    rect = CGRectOffset(rect, 0, verticalOffset);

    if (CGRectContainsPoint(rect, point)) {
      CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                          point.y-CGRectGetMinY(rect));
      CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
      foundLink = [self linkAtIndex:idx];
      if (foundLink) {
        return foundLink;
      }
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)_rectForRange:(NSRange)range inLine:(CTLineRef)line lineOrigin:(CGPoint)lineOrigin {
  CGRect rectForRange = CGRectZero;
  CFArrayRef runs = CTLineGetGlyphRuns(line);
  CFIndex runCount = CFArrayGetCount(runs);

  // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
  // intersect with the range.
  for (CFIndex k = 0; k < runCount; k++) {
    CTRunRef run = CFArrayGetValueAtIndex(runs, k);

    CFRange stringRunRange = CTRunGetStringRange(run);
    NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
    NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);

    if (intersectedRunRange.length == 0) {
      // This run doesn't intersect the range, so skip it.
      continue;
    }

    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                       CFRangeMake(0, 0),
                                                       &ascent,
                                                       &descent,
                                                       &leading);
    CGFloat height = ascent + descent;

    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);

    CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);

    linkRect = CGRectIntegral(linkRect);
    linkRect = CGRectInset(linkRect, -2, 0);

    if (CGRectIsEmpty(rectForRange)) {
      rectForRange = linkRect;

    } else {
      rectForRange = CGRectUnion(rectForRange, linkRect);
    }
  }
  
  return rectForRange;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isPoint:(CGPoint)point nearLink:(NSTextCheckingResult *)link {
  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  if (!lines) return NO;
  CFIndex count = CFArrayGetCount(lines);
  CGPoint lineOrigins[count];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);

  CGAffineTransform transform = [self _transformForCoreText];
  CGFloat verticalOffset = [self _verticalOffsetForBounds:self.bounds];

  // Our bounds may have a non-zero offset, so we must take this into account when doing hit
  // detection.
  point.x += kBoundsInsets.left;
  point.y -= kBoundsInsets.top;

  NSRange linkRange = link.range;

  BOOL isNearLink = NO;
  for (int i = 0; i < count; i++) {
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);

    CGRect linkRect = [self _rectForRange:linkRange inLine:line lineOrigin:lineOrigins[i]];

    if (!CGRectIsEmpty(linkRect)) {
      linkRect = CGRectApplyAffineTransform(linkRect, transform);
      linkRect = CGRectOffset(linkRect, 0, verticalOffset);
      linkRect = CGRectInset(linkRect, -kTouchGutter, -kTouchGutter);
      if (CGRectContainsPoint(linkRect, point)) {
        isNearLink = YES;
        break;
      }
    }
  }

  return isNearLink;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];

  self.touchedLink = [self linkAtPoint:point];
  self.touchPoint = point;
  self.originalLink = self.touchedLink;

  [self.longPressTimer invalidate];
  if (nil != self.touchedLink) {
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressTimeInterval target:self selector:@selector(_longPressTimerDidFire:) userInfo:nil repeats:NO];
  }

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];

  // If the user moves their finger away from the original link, deselect it.
  // If the user moves their finger back to the original link, reselect it.
  // Don't allow other links to be selected other than the original link.

  if (nil != self.originalLink) {
    NSTextCheckingResult* oldTouchedLink = self.touchedLink;

    if ([self isPoint:point nearLink:self.originalLink]) {
      self.touchedLink = self.originalLink;

    } else {
      self.touchedLink = nil;
    }

    if (oldTouchedLink != self.touchedLink) {
      [self.longPressTimer invalidate];
      self.longPressTimer = nil;
      [self setNeedsDisplay];
    }
  }

  // If the user moves their finger within the link beyond a certain gutter amount, reset the
  // hold timer. The user must hold their finger still for the long press interval in order for
  // the long press action to fire.
  if (fabsf(self.touchPoint.x - point.x) >= kLongPressGutter
      || fabsf(self.touchPoint.y - point.y) >= kLongPressGutter) {
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    if (nil != self.touchedLink) {
      self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressTimeInterval target:self selector:@selector(_longPressTimerDidFire:) userInfo:nil repeats:NO];
      self.touchPoint = point;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  [self.longPressTimer invalidate];
  self.longPressTimer = nil;

  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];

  if (nil != self.originalLink) {
    if ([self isPoint:point nearLink:self.originalLink]) {
      // This old-style method is deprecated, please update to the newer delegate method that supports
      // more data types.
      NIDASSERT(![self.delegate respondsToSelector:@selector(attributedLabel:didSelectLink:atPoint:)]);

      if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectTextCheckingResult:atPoint:)]) {
        [self.delegate attributedLabel:self didSelectTextCheckingResult:self.originalLink atPoint:point];
      }
    }
  }

  self.touchedLink = nil;
  self.originalLink = nil;

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  
  [self.longPressTimer invalidate];
  self.longPressTimer = nil;

  self.touchedLink = nil;
  self.originalLink = nil;

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIActionSheet *)actionSheetForResult:(NSTextCheckingResult *)result {
  UIActionSheet* actionSheet =
  [[UIActionSheet alloc] initWithTitle:nil
                              delegate:self
                     cancelButtonTitle:nil
                destructiveButtonTitle:nil
                     otherButtonTitles:nil];

  NSString* title = nil;
  if (NSTextCheckingTypeLink == result.resultType) {
    if ([result.URL.scheme isEqualToString:@"mailto"]) {
      title = result.URL.resourceSpecifier;
      [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Mail", @"")];
      [actionSheet addButtonWithTitle:NSLocalizedString(@"Copy Email Address", @"")];

    } else {
      title = result.URL.absoluteString;
      [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
      [actionSheet addButtonWithTitle:NSLocalizedString(@"Copy URL", @"")];
    }

  } else if (NSTextCheckingTypePhoneNumber == result.resultType) {
    title = result.phoneNumber;
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Call", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Copy Phone Number", @"")];

  } else if (NSTextCheckingTypeAddress == result.resultType) {
    title = [self.mutableAttributedString.string substringWithRange:self.actionSheetLink.range];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Maps", @"")];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Copy Address", @"")];

  } else {
    // This type has not been implemented yet.
    NIDASSERT(NO);
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Copy", @"")];
  }
  actionSheet.title = title;

  if (!NIIsPad()) {
    [actionSheet setCancelButtonIndex:[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")]];
  }

  return actionSheet;
}

  
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_longPressTimerDidFire:(NSTimer *)timer {
  self.longPressTimer = nil;

  if (nil != self.touchedLink) {
    self.actionSheetLink = self.touchedLink;

    UIActionSheet* actionSheet = [self actionSheetForResult:self.actionSheetLink];

    BOOL shouldPresent = YES;
    if ([self.delegate respondsToSelector:@selector(attributedLabel:shouldPresentActionSheet:withTextCheckingResult:atPoint:)]) {
      // Give the delegate the opportunity to not show the action sheet or to present their own.
      shouldPresent = [self.delegate attributedLabel:self shouldPresentActionSheet:actionSheet withTextCheckingResult:self.touchedLink atPoint:self.touchPoint];
    }

    if (shouldPresent) {
      if (NIIsPad()) {
        [actionSheet showFromRect:CGRectMake(self.touchPoint.x - 22, self.touchPoint.y - 22, 44, 44) inView:self animated:YES];
      } else {
        [actionSheet showInView:self];
      }

    } else {
      self.actionSheetLink = nil;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyLinkStyleWithResults:(NSArray *)results toAttributedString:(NSMutableAttributedString *)attributedString {
  for (NSTextCheckingResult* result in results) {
    [attributedString setTextColor:self.linkColor range:result.range];
    if (self.linksHaveUnderlines) {
      [attributedString setUnderlineStyle:kCTUnderlineStyleSingle
                                 modifier:kCTUnderlinePatternSolid
                                    range:result.range];
    }

    if (self.attributesForLinks.count > 0) {
      [attributedString addAttributes:self.attributesForLinks range:result.range];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// We apply the link styles immediately before we render the attributed string. This
// composites the link styles with the existing styles without losing any information. This
// makes it possible to turn off links or remove them altogether without losing the existing
// style information.
- (NSMutableAttributedString *)mutableAttributedStringWithLinkStylesApplied {
  NSMutableAttributedString* attributedString = [self.mutableAttributedString mutableCopy];
  if (self.autoDetectLinks) {
    [self _applyLinkStyleWithResults:self.detectedlinkLocations
                  toAttributedString:attributedString];
  }

  [self _applyLinkStyleWithResults:self.explicitLinkLocations
                toAttributedString:attributedString];

  return attributedString;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawTextInRect:(CGRect)rect {
  rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(-kBoundsInsets.top, -kBoundsInsets.left, -kBoundsInsets.bottom, -kBoundsInsets.right));

  if (NIVerticalTextAlignmentTop != self.verticalTextAlignment) {
    rect.origin.y = [self _verticalOffsetForBounds:rect];
  }

  if (self.autoDetectLinks) {
    [self detectLinks];
  }

  NSMutableAttributedString* attributedStringWithLinks = [self mutableAttributedStringWithLinkStylesApplied];
  if (self.detectedlinkLocations.count > 0 || self.explicitLinkLocations.count > 0) {
    self.userInteractionEnabled = YES;
  }

  if (nil != attributedStringWithLinks) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGAffineTransform transform = [self _transformForCoreText];
    CGContextConcatCTM(ctx, transform);

    if (nil == self.textFrame) {
      CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStringWithLinks;
      CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);

      CGMutablePathRef path = CGPathCreateMutable();
      // We must tranform the path rectangle in order to draw the text correctly for bottom/middle
      // vertical alignment modes.
      CGPathAddRect(path, &transform, rect);
      if (nil != self.shadowColor) {
        CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
      }
      self.textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
      CGPathRelease(path);
      CFRelease(framesetter);
    }

    // Draw the tapped link's highlight.
    if ((nil != self.touchedLink || nil != self.actionSheetLink) && nil != self.highlightedLinkBackgroundColor) {
      [self.highlightedLinkBackgroundColor setFill];

      NSRange linkRange = nil != self.touchedLink ? self.touchedLink.range : self.actionSheetLink.range;

      CFArrayRef lines = CTFrameGetLines(self.textFrame);
      CFIndex count = CFArrayGetCount(lines);
      CGPoint lineOrigins[count];
      CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);

      for (CFIndex i = 0; i < count; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);

        CFRange stringRange = CTLineGetStringRange(line);
        NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
        NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
        if (intersectedRange.length == 0) {
          continue;
        }

        CGRect highlightRect = [self _rectForRange:linkRange inLine:line lineOrigin:lineOrigins[i]];

        if (!CGRectIsEmpty(highlightRect)) {
          highlightRect = CGRectOffset(highlightRect, -kBoundsInsets.left, -rect.origin.y - kBoundsInsets.top - kBoundsInsets.bottom);

          CGFloat pi = (CGFloat)M_PI;

          CGFloat radius = 5.0f;
          CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
          CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
          CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius, 
                          radius, pi, pi / 2.0f, 1.0f);
          CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius, 
                                  highlightRect.origin.y + highlightRect.size.height);
          CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, 
                          highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
          CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
          CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius, 
                          radius, 0.0f, -pi / 2.0f, 1.0f);
          CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
          CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius, 
                          -pi / 2, pi, 1);
          CGContextFillPath(ctx);
        }
      }
    }

    CTFrameDraw(self.textFrame, ctx);
    CGContextRestoreGState(ctx);

  } else {
    [super drawTextInRect:rect];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (NSTextCheckingTypeLink == self.actionSheetLink.resultType) {
    if (buttonIndex == 0) {
      [[UIApplication sharedApplication] openURL:self.actionSheetLink.URL];

    } else if (buttonIndex == 1) {
      if ([self.actionSheetLink.URL.scheme isEqualToString:@"mailto"]) {
        [[UIPasteboard generalPasteboard] setString:self.actionSheetLink.URL.resourceSpecifier];

      } else {
        [[UIPasteboard generalPasteboard] setURL:self.actionSheetLink.URL];
      }
    }

  } else if (NSTextCheckingTypePhoneNumber == self.actionSheetLink.resultType) {
    if (buttonIndex == 0) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:self.actionSheetLink.phoneNumber]]];

    } else if (buttonIndex == 1) {
      [[UIPasteboard generalPasteboard] setString:self.actionSheetLink.phoneNumber];
    }

  } else if (NSTextCheckingTypeAddress == self.actionSheetLink.resultType) {
    NSString* address = [self.mutableAttributedString.string substringWithRange:self.actionSheetLink.range];
    if (buttonIndex == 0) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[@"http://maps.google.com/maps?q=" stringByAppendingString:address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
      
    } else if (buttonIndex == 1) {
      [[UIPasteboard generalPasteboard] setString:address];
    }

  } else {
    // Unsupported data type only allows the user to copy.
    if (buttonIndex == 0) {
      NSString* text = [self.mutableAttributedString.string substringWithRange:self.actionSheetLink.range];
      [[UIPasteboard generalPasteboard] setString:text];
    }
  }

  self.actionSheetLink = nil;
  [self setNeedsDisplay];
}

  
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
  self.actionSheetLink = nil;
  [self setNeedsDisplay];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel (ConversionUtilities)


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment {
  switch (alignment) {
    case UITextAlignmentLeft: return kCTLeftTextAlignment;
    case UITextAlignmentCenter: return kCTCenterTextAlignment;
    case UITextAlignmentRight: return kCTRightTextAlignment;
    case UITextAlignmentJustify: return kCTJustifiedTextAlignment;
    default: return kCTNaturalTextAlignment;
  }
}
#else
+ (CTTextAlignment)alignmentFromUITextAlignment:(NSTextAlignment)alignment {
  switch (alignment) {
    case NSTextAlignmentLeft: return kCTLeftTextAlignment;
    case NSTextAlignmentCenter: return kCTCenterTextAlignment;
    case NSTextAlignmentRight: return kCTRightTextAlignment;
    case NSTextAlignmentJustified: return kCTJustifiedTextAlignment;
    default: return kCTNaturalTextAlignment;
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(UILineBreakMode)lineBreakMode {
  switch (lineBreakMode) {
    case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
    case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
    case UILineBreakModeClip: return kCTLineBreakByClipping;
    case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
    case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
    case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
    default: return 0;
  }
}
#else
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(NSLineBreakMode)lineBreakMode {
  switch (lineBreakMode) {
    case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
    case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
    case NSLineBreakByClipping: return kCTLineBreakByClipping;
    case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
    case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
    case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
    default: return 0;
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSMutableAttributedString *)mutableAttributedStringFromLabel:(UILabel *)label {
  NSMutableAttributedString* attributedString = nil;

  if (NIIsStringWithAnyText(label.text)) {
    attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];

    [attributedString setFont:label.font];
    [attributedString setTextColor:label.textColor];

    CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:label.textAlignment];
    CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:label.lineBreakMode];

    [attributedString setTextAlignment:textAlignment lineBreakMode:lineBreak]; 
  }

  return attributedString;
}

@end
