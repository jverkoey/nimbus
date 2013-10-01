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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static const CGFloat kVMargin = 5.0f;
static const NSTimeInterval kLongPressTimeInterval = 0.5;
static const CGFloat kLongPressGutter = 22;
NSString * const kNILinkAttributeName = @"NIAttributedLabel:Link";

CGFloat ImageDelegateGetAscentCallback(void* refCon);
CGFloat ImageDelegateGetDescentCallback(void* refCon);
CGFloat ImageDelegateGetWidthCallback(void* refCon);

// \u2026 is the Unicode horizontal ellipsis character code
static NSString* const kEllipsesCharacter = @"\u2026";

// The touch gutter is the amount of space around a link that will still register as tapping
// "within" the link.
static const CGFloat kTouchGutter = 22;

CGSize NISizeOfAttributedStringConstrainedToSize(NSAttributedString *attributedString, CGSize size, NSInteger numberOfLines) {
  if (nil == attributedString) {
    return CGSizeZero;
  }

  CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)attributedString;
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
  CFRange range = CFRangeMake(0, 0);

  // This logic adapted from @mattt's TTTAttributedLabel
  // https://github.com/mattt/TTTAttributedLabel

  if (numberOfLines > 0 && nil != framesetter) {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);

    if (nil != lines && CFArrayGetCount(lines) > 0) {
      NSInteger lastVisibleLineIndex = MIN(numberOfLines, CFArrayGetCount(lines)) - 1;
      CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);

      CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
      range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
    }

    CFRelease(frame);
    CFRelease(path);
  }

  CFRange fitCFRange = CFRangeMake(0, 0);
  CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);

  if (nil != framesetter) {
    CFRelease(framesetter);
    framesetter = nil;
  }

  return CGSizeMake(ceilf(newSize.width), ceilf(newSize.height));
}

@interface NIAttributedLabelImage : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, NI_STRONG) UIImage* image;
@property (nonatomic, assign) UIEdgeInsets margins;
@property (nonatomic, assign, readonly) CGSize boxSize; // imageSize + margins
@property (nonatomic, assign) NIVerticalTextAlignment verticalTextAlignment;
@property (nonatomic, assign) CGFloat fontAscent;
@property (nonatomic, assign) CGFloat fontDescent;
@end

@implementation NIAttributedLabelImage
@synthesize index;
@synthesize image;
@synthesize margins;
@synthesize verticalTextAlignment;
@synthesize fontAscent;
@synthesize fontDescent;

- (CGSize)boxSize
{
  return CGSizeMake(self.image.size.width + self.margins.left + self.margins.right,
                    self.image.size.height + self.margins.top + self.margins.bottom);
}

@end


@interface NIAttributedLabel() <UIActionSheetDelegate>
@property (nonatomic, NI_STRONG) NSMutableAttributedString* mutableAttributedString;
@property (nonatomic, assign) CTFrameRef textFrame; // CFType, manually managed lifetime, see setter.
@property (assign) BOOL detectingLinks; // Atomic.
@property (nonatomic, assign) BOOL linksHaveBeenDetected;
@property (nonatomic, copy) NSArray* detectedlinkLocations;
@property (nonatomic, NI_STRONG) NSMutableArray* explicitLinkLocations;
@property (nonatomic, NI_STRONG) NSTextCheckingResult* originalLink;
@property (nonatomic, NI_STRONG) NSTextCheckingResult* touchedLink;
@property (nonatomic, NI_STRONG) NSTimer* longPressTimer;
@property (nonatomic, assign) CGPoint touchPoint;
@property (nonatomic, NI_STRONG) NSTextCheckingResult* actionSheetLink;
@property (nonatomic, NI_STRONG) NSArray *accessibleElements;
@property (nonatomic, NI_STRONG) NSMutableArray *images;
@end


@interface NIAttributedLabel(ConversionUtilities)
// Only use UITextAlignment if deployment target is less than 6.0 and
// not on iOS 7 SDK.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_7_0 && __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment;
#else
+ (CTTextAlignment)alignmentFromUITextAlignment:(NSTextAlignment)alignment;
#endif
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(NSLineBreakMode)lineBreakMode;
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
@synthesize accessibleElements = _accessibleElements;
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
@synthesize attributesForHighlightedLink = _attributesForHighlightedLink;
@synthesize lineHeight = _lineHeight;
@synthesize images;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_longPressTimer invalidate];

  // The property is marked 'assign', but retain count for this CFType is managed here and via
  // the setter.
  if (NULL != _textFrame) {
    CFRelease(_textFrame);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextFrame:(CTFrameRef)textFrame {
  // The property is marked 'assign', but retain count for this CFType is managed via this setter
  // and -dealloc.
  if (textFrame != _textFrame) {
    if (NULL != _textFrame) {
      CFRelease(_textFrame);
    }
    if (NULL != textFrame) {
      CFRetain(textFrame);
    }
    _textFrame = textFrame;
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
  self.textFrame = NULL;
  self.accessibleElements = nil;
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
- (CGSize)sizeThatFits:(CGSize)size {
  if (nil == self.mutableAttributedString) {
    return CGSizeZero;
  }

  return NISizeOfAttributedStringConstrainedToSize([self mutableAttributedStringWithAdditions], size, self.numberOfLines);
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

    // Remove all images.
    self.images = nil;

    // Pull any explicit links from the attributed string itself
    [self _processLinksInAttributedString:self.mutableAttributedString];

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

    // Remove all images.
    self.images = nil;

    // Pull any explicit links from the attributed string itself
    [self _processLinksInAttributedString:self.mutableAttributedString];

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

// Only use UITextAlignment if deployment target is less than 6.0 and
// not on iOS 7 SDK.
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_7_0 && __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
- (void)setTextAlignment:(UITextAlignment)textAlignment {
  // UILabel doesn't implement UITextAlignmentJustify, so we can't call super when this is the case
  // or the app will crash.
  if (textAlignment != UITextAlignmentJustify) {
    // We assume that the UILabel implementation will call setNeedsDisplay. Where we don't call super
    // we call setNeedsDisplay ourselves.
    [super setTextAlignment:textAlignment];
  }

  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:self.lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak lineHeight:self.lineHeight];
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
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak lineHeight:self.lineHeight];
  }
}
#endif


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
  [super setLineBreakMode:lineBreakMode];

  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak lineHeight:self.lineHeight];
  }
}


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
- (void)setLineHeight:(CGFloat)lineHeight {
  _lineHeight = lineHeight;

  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:self.lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak lineHeight:self.lineHeight];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedLinkBackgroundColor:(UIColor *)highlightedLinkBackgroundColor {
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
- (void)setAttributesForHighlightedLink:(NSDictionary *)attributesForHighlightedLink {
  if (_attributesForHighlightedLink != attributesForHighlightedLink) {
    _attributesForHighlightedLink = attributesForHighlightedLink;

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setExplicitLinkLocations:(NSMutableArray *)explicitLinkLocations {
  if (_explicitLinkLocations != explicitLinkLocations) {
    _explicitLinkLocations = explicitLinkLocations;
    self.accessibleElements = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDetectedlinkLocations:(NSArray *)detectedlinkLocations{
  if (_detectedlinkLocations != detectedlinkLocations) {
    _detectedlinkLocations = detectedlinkLocations;
    self.accessibleElements = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
  BOOL didChange = self.highlighted != highlighted;
  [super setHighlighted:highlighted];

  if (didChange) {
    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor {
  BOOL didChange = self.highlightedTextColor != highlightedTextColor;
  [super setHighlightedTextColor:highlightedTextColor];

  if (didChange) {
    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)_matchesFromAttributedString:(NSString *)string {
  NSError* error = nil;
  NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)self.dataDetectorTypes
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
- (void)_processLinksInAttributedString:(NSAttributedString *)attributedString {
  // Pull any attributes matching the link attribute from the attributed string and store them as
  // the current set of explicit links. This properly handles the value of the attribute being
  // either an NSURL or an NSString.
  __block NSMutableArray *links = [NSMutableArray array];
  [attributedString enumerateAttribute:kNILinkAttributeName
                               inRange:NSMakeRange(0, attributedString.length)
                               options:0
                            usingBlock:^(id value, NSRange range, BOOL *stop) {
                                if (value != nil)
                                {
                                  if ([value isKindOfClass:[NSURL class]])
                                  {
                                    [links addObject:[NSTextCheckingResult linkCheckingResultWithRange:range URL:value]];
                                  }
                                  else if ([value isKindOfClass:[NSString class]])
                                  {
                                    NSURL *url = [NSURL URLWithString:value];
                                    [links addObject:[NSTextCheckingResult linkCheckingResultWithRange:range URL:url]];
                                  }
                                }
                            }];
  self.explicitLinkLocations = links;
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

      NSUInteger offset = 0;
      for (NIAttributedLabelImage *labelImage in self.images) {
        if (labelImage.index < idx) {
          offset++;
        }

      }

      foundLink = [self linkAtIndex:idx - offset];;
      if (foundLink) {
        NSTextCheckingResult *result = [NSTextCheckingResult linkCheckingResultWithRange:NSMakeRange(foundLink.range.location + offset, foundLink.range.length) URL:foundLink.URL];

        return result;
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

    // Use of 'leading' doesn't properly highlight Japanese-character link.
    CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                       CFRangeMake(0, 0),
                                                       &ascent,
                                                       &descent,
                                                       NULL); //&leading);
    CGFloat height = ascent + descent;

    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);

    CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);

    linkRect.origin.y = roundf(linkRect.origin.y);
    linkRect.origin.x = roundf(linkRect.origin.x);
    linkRect.size.width = roundf(linkRect.size.width);
    linkRect.size.height = roundf(linkRect.size.height);

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
  if (nil == lines) {
    return NO;
  }
  CFIndex count = CFArrayGetCount(lines);
  CGPoint lineOrigins[count];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);

  CGAffineTransform transform = [self _transformForCoreText];
  CGFloat verticalOffset = [self _verticalOffsetForBounds:self.bounds];

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
- (NSArray *)_rectsForLink:(NSTextCheckingResult *)link {
  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  if (nil == lines) {
    return nil;
  }
  CFIndex count = CFArrayGetCount(lines);
  CGPoint lineOrigins[count];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);

  CGAffineTransform transform = [self _transformForCoreText];
  CGFloat verticalOffset = [self _verticalOffsetForBounds:self.bounds];

  NSRange linkRange = link.range;

  NSMutableArray* rects = [NSMutableArray array];
  for (int i = 0; i < count; i++) {
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);

    CGRect linkRect = [self _rectForRange:linkRange inLine:line lineOrigin:lineOrigins[i]];

    if (!CGRectIsEmpty(linkRect)) {
      linkRect = CGRectApplyAffineTransform(linkRect, transform);
      linkRect = CGRectOffset(linkRect, 0, verticalOffset);
      [rects addObject:[NSValue valueWithCGRect:linkRect]];
    }
  }

  return [rects copy];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTouchedLink:(NSTextCheckingResult *)touchedLink {
  if (_touchedLink != touchedLink) {
    _touchedLink = touchedLink;

    if (self.attributesForHighlightedLink.count > 0) {
      [self attributedTextDidChange];
    }
  }
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
    if ([self isPoint:point nearLink:self.originalLink]
        && [self.delegate respondsToSelector:@selector(attributedLabel:didSelectTextCheckingResult:atPoint:)]) {
      [self.delegate attributedLabel:self didSelectTextCheckingResult:self.originalLink atPoint:point];
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
    if (self.linkColor) {
      [attributedString setTextColor:self.linkColor range:result.range];
    }

    // We add a no-op attribute in order to force a run to exist for each link. Otherwise the
    // runCount will be one in this line, causing the entire line to be highlighted rather than
    // just the link when when no special attributes are set.
    [attributedString removeAttribute:kNILinkAttributeName range:result.range];
    [attributedString addAttribute:kNILinkAttributeName
                             value:result.URL
                             range:result.range];

    if (self.linksHaveUnderlines) {
      [attributedString setUnderlineStyle:kCTUnderlineStyleSingle
                                 modifier:kCTUnderlinePatternSolid
                                    range:result.range];
    }

    if (self.attributesForLinks.count > 0) {
      [attributedString addAttributes:self.attributesForLinks range:result.range];
    }
    if (self.attributesForHighlightedLink.count > 0 && NSEqualRanges(result.range, self.touchedLink.range)) {
      [attributedString addAttributes:self.attributesForHighlightedLink range:result.range];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// We apply the additional styles immediately before we render the attributed string. This
// composites the styles with the existing styles without losing any information. This
// makes it possible to turn off links or remove them altogether without losing the existing
// style information.
- (NSMutableAttributedString *)mutableAttributedStringWithAdditions {
  NSMutableAttributedString* attributedString = [self.mutableAttributedString mutableCopy];
  if (self.autoDetectLinks) {
    [self _applyLinkStyleWithResults:self.detectedlinkLocations
                  toAttributedString:attributedString];
  }

  [self _applyLinkStyleWithResults:self.explicitLinkLocations
                toAttributedString:attributedString];

  if (self.images.count > 0) {
    // Sort the label images in reverse order by index so that when we add them the string's indices
    // remain relatively accurate to the original string. This is necessary because we're inserting
    // spaces into the string.
    [self.images sortUsingComparator:^NSComparisonResult(NIAttributedLabelImage* obj1, NIAttributedLabelImage*  obj2) {
      if (obj1.index < obj2.index) {
        return NSOrderedDescending;
      } else if (obj1.index > obj2.index) {
        return NSOrderedAscending;
      } else {
        return NSOrderedSame;
      }
    }];

    for (NIAttributedLabelImage *labelImage in self.images) {
      CTRunDelegateCallbacks callbacks;
      memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
      callbacks.version = kCTRunDelegateVersion1;
      callbacks.getAscent = ImageDelegateGetAscentCallback;
      callbacks.getDescent = ImageDelegateGetDescentCallback;
      callbacks.getWidth = ImageDelegateGetWidthCallback;

      NSUInteger index = labelImage.index;
      if (index >= attributedString.length) {
        index = attributedString.length - 1;
      }

      NSDictionary *attributes = [attributedString attributesAtIndex:index effectiveRange:NULL];
      CTFontRef font = (__bridge CTFontRef)[attributes valueForKey:(__bridge id)kCTFontAttributeName];

      if (font != NULL) {
        labelImage.fontAscent = CTFontGetAscent(font);
        labelImage.fontDescent = CTFontGetDescent(font);
      }

      CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)labelImage);

      // Character to use as recommended by kCTRunDelegateAttributeName documentation.
      unichar objectReplacementChar = 0xFFFC;
      NSString *objectReplacementString = [NSString stringWithCharacters:&objectReplacementChar length:1];
      NSMutableAttributedString* space = [[NSMutableAttributedString alloc] initWithString:objectReplacementString];
      CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
      CFRelease(delegate);
      [attributedString insertAttributedString:space atIndex:labelImage.index];
    }
  }

  if (self.isHighlighted) {
    [attributedString setTextColor:self.highlightedTextColor];
  }

  return attributedString;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfDisplayedLines {
  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  return self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawImages {
  if (0 == self.images.count) {
    return;
  }

  CGContextRef ctx = UIGraphicsGetCurrentContext();

  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  CFIndex lineCount = CFArrayGetCount(lines);
  CGPoint lineOrigins[lineCount];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);
  NSInteger numberOfLines = [self numberOfDisplayedLines];

  for (CFIndex i = 0; i < numberOfLines; i++) {
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    CGPoint lineOrigin = lineOrigins[i];
    CGFloat lineAscent;
    CGFloat lineDescent;
    CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
    CGFloat lineHeight = lineAscent + lineDescent;
    CGFloat lineBottomY = lineOrigin.y - lineDescent;

    // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
    // intersect with the range.
    for (CFIndex k = 0; k < runCount; k++) {
      CTRunRef run = CFArrayGetValueAtIndex(runs, k);
      NSDictionary *runAttributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
      CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(__bridge id)kCTRunDelegateAttributeName];
      if (nil == delegate) {
        continue;
      }
      NIAttributedLabelImage* labelImage = (__bridge NIAttributedLabelImage *)CTRunDelegateGetRefCon(delegate);

      CGFloat ascent = 0.0f;
      CGFloat descent = 0.0f;
      CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                         CFRangeMake(0, 0),
                                                         &ascent,
                                                         &descent,
                                                         NULL);

      CGFloat imageBoxHeight = labelImage.boxSize.height;

      CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);

      CGFloat imageBoxOriginY = 0.0f;
      switch (labelImage.verticalTextAlignment) {
        case NIVerticalTextAlignmentTop:
          imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
          break;
        case NIVerticalTextAlignmentMiddle:
          imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.f;
          break;
        case NIVerticalTextAlignmentBottom:
          imageBoxOriginY = lineBottomY;
          break;
      }

      CGRect rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
      UIEdgeInsets flippedMargins = labelImage.margins;
      CGFloat top = flippedMargins.top;
      flippedMargins.top = flippedMargins.bottom;
      flippedMargins.bottom = top;

      CGRect imageRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
      CGContextDrawImage(ctx, imageRect, labelImage.image.CGImage);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawHighlightWithRect:(CGRect)rect {
  if ((nil == self.touchedLink && nil == self.actionSheetLink) || nil == self.highlightedLinkBackgroundColor) {
    return;
  }
  [self.highlightedLinkBackgroundColor setFill];

  NSRange linkRange = nil != self.touchedLink ? self.touchedLink.range : self.actionSheetLink.range;

  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  CFIndex count = CFArrayGetCount(lines);
  CGPoint lineOrigins[count];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);
  NSInteger numberOfLines = [self numberOfDisplayedLines];

  CGContextRef ctx = UIGraphicsGetCurrentContext();

  for (CFIndex i = 0; i < numberOfLines; i++) {
    CTLineRef line = CFArrayGetValueAtIndex(lines, i);

    CFRange stringRange = CTLineGetStringRange(line);
    NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
    NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
    if (intersectedRange.length == 0) {
      continue;
    }

    CGRect highlightRect = [self _rectForRange:linkRange inLine:line lineOrigin:lineOrigins[i]];
    highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);

    if (!CGRectIsEmpty(highlightRect)) {
      CGFloat pi = (CGFloat)M_PI;

      CGFloat radius = 1.0f;
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawAttributedString:(NSAttributedString *)attributedString rect:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  // This logic adapted from @mattt's TTTAttributedLabel
  // https://github.com/mattt/TTTAttributedLabel

  CFArrayRef lines = CTFrameGetLines(self.textFrame);
  NSInteger numberOfLines = [self numberOfDisplayedLines];

  BOOL truncatesLastLine = (self.lineBreakMode == NSLineBreakByTruncatingTail);
  CGPoint lineOrigins[numberOfLines];
  CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, numberOfLines), lineOrigins);

  for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
    CGPoint lineOrigin = lineOrigins[lineIndex];
    lineOrigin.y -= rect.origin.y; // adjust for verticalTextAlignment
    CGContextSetTextPosition(ctx, lineOrigin.x, lineOrigin.y);
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);

    BOOL shouldDrawLine = YES;

    if (truncatesLastLine && lineIndex == numberOfLines - 1) {
      // Does the last line need truncation?
      CFRange lastLineRange = CTLineGetStringRange(line);
      if (lastLineRange.location + lastLineRange.length < (CFIndex)attributedString.length) {
        CTLineTruncationType truncationType = kCTLineTruncationEnd;
        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;

        NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                             effectiveRange:NULL];
        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter
                                                                          attributes:tokenAttributes];
        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);

        NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
        if (lastLineRange.length > 0) {
          // Remove any whitespace at the end of the line.
          unichar lastCharacter = [[truncationString string] characterAtIndex:lastLineRange.length - 1];
          if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:lastCharacter]) {
            [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
          }
        }
        [truncationString appendAttributedString:tokenString];

        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
        if (!truncatedLine) {
          // If the line is not as wide as the truncationToken, truncatedLine is NULL
          truncatedLine = CFRetain(truncationToken);
        }
        CFRelease(truncationLine);
        CFRelease(truncationToken);

        CTLineDraw(truncatedLine, ctx);
        CFRelease(truncatedLine);

        shouldDrawLine = NO;
      }
    }

    if (shouldDrawLine) {
      CTLineDraw(line, ctx);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawTextInRect:(CGRect)rect {
  if (NIVerticalTextAlignmentTop != self.verticalTextAlignment) {
    rect.origin.y = [self _verticalOffsetForBounds:rect];
  }

  if (self.autoDetectLinks) {
    [self detectLinks];
  }

  NSMutableAttributedString* attributedStringWithLinks = [self mutableAttributedStringWithAdditions];
  if (self.detectedlinkLocations.count > 0 || self.explicitLinkLocations.count > 0) {
    self.userInteractionEnabled = YES;
  }

  if (nil != attributedStringWithLinks) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGAffineTransform transform = [self _transformForCoreText];
    CGContextConcatCTM(ctx, transform);

    if (NULL == self.textFrame) {
      CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)attributedStringWithLinks;
      CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);

      CGMutablePathRef path = CGPathCreateMutable();
      CGPathAddRect(path, NULL, rect);
      CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
      self.textFrame = textFrame;
      if (textFrame) {
        CFRelease(textFrame);
      }
      CGPathRelease(path);
      CFRelease(framesetter);
    }

    [self drawImages];
    [self drawHighlightWithRect:rect];

    if (nil != self.shadowColor) {
      CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    }

    [self drawAttributedString:attributedStringWithLinks rect:rect];

    CGContextRestoreGState(ctx);

  } else {
    [super drawTextInRect:rect];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Accessibility


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)accessibleElements {
  if (nil != _accessibleElements) {
    return _accessibleElements;
  }

  NSMutableArray* accessibleElements = [NSMutableArray array];

  NSArray* allLinks = [[NSArray arrayWithArray:self.detectedlinkLocations]
                       arrayByAddingObjectsFromArray:self.explicitLinkLocations];

  for (NSTextCheckingResult* result in allLinks) {
    NSArray* rectsForLink = [self _rectsForLink:result];
    if (!NIIsArrayWithObjects(rectsForLink)) {
      continue;
    }

    NSString* label = [self.mutableAttributedString.string substringWithRange:result.range];
    for (NSValue* rectValue in rectsForLink) {
      UIAccessibilityElement* element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
      element.accessibilityLabel = label;
      element.accessibilityFrame = [self convertRect:rectValue.CGRectValue toView:self.window];
      element.accessibilityTraits = UIAccessibilityTraitLink;
      [accessibleElements addObject:element];
    }
  }

  _accessibleElements = [accessibleElements copy];
  return _accessibleElements;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAccessibilityElement {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)accessibilityElementCount  {
  return self.accessibleElements.count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)accessibilityElementAtIndex:(NSInteger)index {
  return [self.accessibleElements objectAtIndex:index];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [self.accessibleElements indexOfObject:element];
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


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat ImageDelegateGetAscentCallback(void* refCon) {
  NIAttributedLabelImage *labelImage = (__bridge NIAttributedLabelImage *)refCon;

  switch (labelImage.verticalTextAlignment) {
    case NIVerticalTextAlignmentMiddle:
    {
      CGFloat ascent = labelImage.fontAscent;
      CGFloat descent = labelImage.fontDescent;
      CGFloat baselineFromMid = (ascent + descent) / 2 - descent;

      return labelImage.boxSize.height / 2 + baselineFromMid;
    }
    case NIVerticalTextAlignmentTop:
      return labelImage.fontAscent;
    case NIVerticalTextAlignmentBottom:
    default:
      return labelImage.boxSize.height - labelImage.fontDescent;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat ImageDelegateGetDescentCallback(void* refCon) {
  NIAttributedLabelImage *labelImage = (__bridge NIAttributedLabelImage *)refCon;

  switch (labelImage.verticalTextAlignment) {
    case NIVerticalTextAlignmentMiddle:
    {
      CGFloat ascent = labelImage.fontAscent;
      CGFloat descent = labelImage.fontDescent;
      CGFloat baselineFromMid = (ascent + descent) / 2 - descent;

      return labelImage.boxSize.height / 2 - baselineFromMid;
    }
    case NIVerticalTextAlignmentTop:
      return labelImage.boxSize.height - labelImage.fontAscent;
    case NIVerticalTextAlignmentBottom:
    default:
      return labelImage.fontDescent;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat ImageDelegateGetWidthCallback(void* refCon) {
  NIAttributedLabelImage *labelImage = (__bridge NIAttributedLabelImage *)refCon;
  return labelImage.image.size.width + labelImage.margins.left + labelImage.margins.right;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertImage:(UIImage *)image atIndex:(NSInteger)index {
  [self insertImage:image atIndex:index margins:UIEdgeInsetsZero verticalTextAlignment:NIVerticalTextAlignmentBottom];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertImage:(UIImage *)image atIndex:(NSInteger)index margins:(UIEdgeInsets)margins {
  [self insertImage:image atIndex:index margins:margins verticalTextAlignment:NIVerticalTextAlignmentBottom];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertImage:(UIImage *)image atIndex:(NSInteger)index margins:(UIEdgeInsets)margins verticalTextAlignment:(NIVerticalTextAlignment)verticalTextAlignment {
  NIAttributedLabelImage* labelImage = [[NIAttributedLabelImage alloc] init];
  labelImage.index = index;
  labelImage.image = image;
  labelImage.margins = margins;
  labelImage.verticalTextAlignment = verticalTextAlignment;
  if (nil == self.images) {
    self.images = [NSMutableArray array];
  }
  [self.images addObject:labelImage];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel (ConversionUtilities)


///////////////////////////////////////////////////////////////////////////////////////////////////
#if __IPHONE_OS_VERSION_MAX_ALLOWED < NIIOS_7_0 && __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment {
  // UITextAlignmentJustify is not part of the UITextAlignment enumeration, so we cast to NSInteger
  // to tell Xcode not to coerce us into only using real UITextAlignment valus.
  switch ((NSInteger)alignment) {
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
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(NSLineBreakMode)lineBreakMode {
  switch (lineBreakMode) {
    case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
    case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
    case NSLineBreakByClipping: return kCTLineBreakByClipping;
    case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
    case NSLineBreakByTruncatingTail: return kCTLineBreakByWordWrapping; // We handle truncation ourself.
    case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
    default: return 0;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSMutableAttributedString *)mutableAttributedStringFromLabel:(UILabel *)label {
  NSMutableAttributedString* attributedString = nil;

  if (NIIsStringWithAnyText(label.text)) {
    attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];

    [attributedString setFont:label.font];
    [attributedString setTextColor:label.textColor];

    CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:label.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:label.lineBreakMode];

    CGFloat lineHeight = 0;
    if ([label isKindOfClass:[NIAttributedLabel class]]) {
      lineHeight = [(NIAttributedLabel *)label lineHeight];
    }
    [attributedString setTextAlignment:textAlignment lineBreakMode:lineBreak lineHeight:lineHeight];
  }

  return attributedString;
}

@end
