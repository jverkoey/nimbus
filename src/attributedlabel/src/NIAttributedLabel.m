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

@interface NIAttributedLabel()
@property (nonatomic, readwrite, retain) NSMutableAttributedString* mutableAttributedString;
@property (nonatomic, readwrite, assign) CTFrameRef textFrame;
@property (readwrite, assign) BOOL detectingLinks; // Atomic.
@property (nonatomic, readwrite, assign) BOOL linksHaveBeenDetected;
@property (nonatomic, readwrite, copy) NSArray* detectedlinkLocations;
@property (nonatomic, readwrite, retain) NSMutableArray* explicitLinkLocations;
@property (nonatomic, readwrite, retain) NSTextCheckingResult* touchedLink;
@end


@interface NIAttributedLabel(ConversionUtilities)
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment;
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(UILineBreakMode)lineBreakMode;
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
@synthesize touchedLink = _touchedLink;
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

  self.attributedString = [self.class mutableAttributedStringFromLabel:self];
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

  self.attributedString = [self.class mutableAttributedStringFromLabel:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSAttributedString *)attributedString {
  if (nil == self.mutableAttributedString) {
    self.attributedString = [self.class mutableAttributedStringFromLabel:self];
  }
  return [self.mutableAttributedString copy];
}


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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
  [super setLineBreakMode:lineBreakMode];

  if (nil != self.mutableAttributedString) {
    CTTextAlignment alignment = [self.class alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [self.class lineBreakModeFromUILineBreakMode:lineBreakMode];
    [self.mutableAttributedString setTextAlignment:alignment lineBreakMode:lineBreak];
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
  static const CGFloat kVMargin = 5.0f;
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
			foundLink = [self linkAtIndex:idx];
			if (foundLink) {
        return foundLink;
      }
		}
	}
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];

  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

  self.touchedLink = [self linkAtPoint:point];

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];

  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

  NSTextCheckingResult* linkTouched = [self linkAtPoint:point];

  if ([self.touchedLink isEqual:linkTouched]) {
    // This old-style method is deprecated, please update to the newer delegate method that supports
    // more data types.
    NIDASSERT(![self.delegate respondsToSelector:@selector(attributedLabel:didSelectLink:atPoint:)]);
    if ([self.delegate respondsToSelector:@selector(attributedLabel:didSelectTextCheckingResult:atPoint:)]) {
      [self.delegate attributedLabel:self didSelectTextCheckingResult:linkTouched atPoint:point];
    }
  }

  self.touchedLink = nil;

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];

  self.touchedLink = nil;

  [self setNeedsDisplay];
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
  NSMutableAttributedString* attributedString = [self.attributedString mutableCopy];
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
    if (nil != self.touchedLink && nil != self.highlightedLinkBackgroundColor) {
      [self.highlightedLinkBackgroundColor setFill];

      NSRange linkRange = self.touchedLink.range;

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

        // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
        // intersect with the link's range. For each of these runs, draw the highlight frame
        // around the part of the run that intersects with the link.
        CGRect highlightRect = CGRectZero;
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        for (CFIndex k = 0; k < runCount; k++) {
          CTRunRef run = CFArrayGetValueAtIndex(runs, k);

          CFRange stringRunRange = CTRunGetStringRange(run);
          NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
          NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, linkRange);
          if (intersectedRunRange.length == 0) {
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

          CGFloat xOffset = CTLineGetOffsetForStringIndex(line, 
                                                          CTRunGetStringRange(run).location, 
                                                          nil);

          CGRect linkRect = CGRectMake(lineOrigins[i].x + xOffset - leading,
                                       lineOrigins[i].y - descent,
                                       width + leading,
                                       height);

          linkRect = CGRectIntegral(linkRect);
          linkRect = CGRectInset(linkRect, -2, -1);

          if (CGRectIsEmpty(highlightRect)) {
            highlightRect = linkRect;

          } else {
            highlightRect = CGRectUnion(highlightRect, linkRect);
          }
        }

        if (!CGRectIsEmpty(highlightRect)) {
          highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);

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


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel (ConversionUtilities)


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment {
  switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		case UITextAlignmentJustify: return kCTJustifiedTextAlignment; 		
    default: return kCTNaturalTextAlignment;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
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
