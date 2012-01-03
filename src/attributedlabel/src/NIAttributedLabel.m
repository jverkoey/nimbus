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
#import "NSAttributedString+NimbusAttributedLabel.h"

@interface NIAttributedLabel (ConversionUtilities)
+ (CTTextAlignment)alignmentFromUITextAlignment:(UITextAlignment)alignment;
+ (CTLineBreakMode)lineBreakModeFromUILineBreakMode:(UILineBreakMode)lineBreakMode;
+ (NSMutableAttributedString *)mutableAttributedStringFromLabel:(UILabel *)label;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel

@synthesize autoDetectLinks = _autoDetectLinks;
@synthesize underlineStyle = _underlineStyle;
@synthesize underlineStyleModifier = _underlineStyleModifier;
@synthesize strokeWidth = _strokeWidth;
@synthesize strokeColor = _strokeColor;
@synthesize textKern = _textKern;
@synthesize linkColor = _linkColor;
@synthesize linkHighlightColor = _linkHighlightColor;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_attributedString);

  if (nil != _textFrame) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}

  NI_RELEASE_SAFELY(_detectedlinkLocations);
  NI_RELEASE_SAFELY(_explicitLinkLocations);
  NI_RELEASE_SAFELY(_touchedLink);

  NI_RELEASE_SAFELY(_linkColor);
  NI_RELEASE_SAFELY(_linkHighlightColor);
  NI_RELEASE_SAFELY(_strokeColor);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib {
  [super awakeFromNib];

  self.attributedString = [[self class] mutableAttributedStringFromLabel:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetTextFrame {
	if (nil != _textFrame) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attributedTextDidChange {
  [self resetTextFrame];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
	if (nil == _attributedString) {
    return CGSizeZero;
  }

  CFAttributedStringRef attributedStringRef = (CFAttributedStringRef)_attributedString;
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
	CFRange fitCFRange = CFRangeMake(0,0);
	CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0),
                                                                NULL, size, &fitCFRange);

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

  self.attributedString = [[self class] mutableAttributedStringFromLabel:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSAttributedString *)attributedString {
  if (nil == _attributedString) {
    self.attributedString = [[self class] mutableAttributedStringFromLabel:self];
  }
  return [[_attributedString copy] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setAttributedString:(NSAttributedString *)attributedText {
  if (_attributedString != attributedText) {
    [_attributedString release];
    _attributedString = [attributedText mutableCopy];

    // Clear the link caches.
    NI_RELEASE_SAFELY(_detectedlinkLocations);
    _linksHaveBeenDetected = NO;
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
  if (nil == _explicitLinkLocations) {
    _explicitLinkLocations = [[NSMutableArray alloc] init];
  }

  NSTextCheckingResult* result = [NSTextCheckingResult linkCheckingResultWithRange:range
                                                                               URL:urlLink];
  [_explicitLinkLocations addObject:result];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllExplicitLinks {
  NI_RELEASE_SAFELY(_explicitLinkLocations);

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextAlignment:(UITextAlignment)textAlignment {
  // We assume that the UILabel implementation will call setNeedsDisplay. Where we don't call super
  // we call setNeedsDisplay ourselves.
  [super setTextAlignment:textAlignment];

  if (nil != _attributedString) {
    CTTextAlignment alignment = [[self class] alignmentFromUITextAlignment:textAlignment];
    CTLineBreakMode lineBreak = [[self class] lineBreakModeFromUILineBreakMode:self.lineBreakMode];
    [_attributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
  [super setLineBreakMode:lineBreakMode];

  if (nil != _attributedString) {
    CTTextAlignment alignment = [[self class] alignmentFromUITextAlignment:self.textAlignment];
    CTLineBreakMode lineBreak = [[self class] lineBreakModeFromUILineBreakMode:lineBreakMode];
    [_attributedString setTextAlignment:alignment lineBreakMode:lineBreak];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)textColor {
  [super setTextColor:textColor];

  [_attributedString setTextColor:textColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor *)textColor range:(NSRange)range {
  [_attributedString setTextColor:textColor range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont *)font {
	[super setFont:font];

  [_attributedString setFont:font];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont *)font range:(NSRange)range {
  [_attributedString setFont:font range:range];

  [self attributedTextDidChange];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style {
  if (style != _underlineStyle) {
    _underlineStyle = style;
    [_attributedString setUnderlineStyle:style modifier:self.underlineStyleModifier];

    [self attributedTextDidChange];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyleModifier:(CTUnderlineStyleModifiers)modifier {
  if (modifier != _underlineStyleModifier) {
    _underlineStyleModifier = modifier;
    [_attributedString setUnderlineStyle:self.underlineStyle  modifier:modifier];

    [self attributedTextDidChange];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUnderlineStyle:(CTUnderlineStyle)style modifier:(CTUnderlineStyleModifiers)modifier range:(NSRange)range {
  [_attributedString setUnderlineStyle:style modifier:modifier range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)strokeWidth {
  if (_strokeWidth != strokeWidth) {
    _strokeWidth = strokeWidth;
    [_attributedString setStrokeWidth:strokeWidth];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeWidth:(CGFloat)width range:(NSRange)range {
  [_attributedString setStrokeWidth:width range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor *)strokeColor {
  if (_strokeColor != strokeColor) {
    [_strokeColor release];
    _strokeColor = [strokeColor retain];
    [_attributedString setStrokeColor:_strokeColor];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStrokeColor:(UIColor*)color range:(NSRange)range {
  [_attributedString setStrokeColor:color range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextKern:(CGFloat)textKern {
  if (_textKern != textKern) {
    _textKern = textKern;
    [_attributedString setKern:_textKern];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextKern:(CGFloat)kern range:(NSRange)range {
  [_attributedString setKern:kern range:range];

  [self attributedTextDidChange];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)linkColor {
  if (nil == _linkColor) {
    _linkColor = [[UIColor blueColor] retain];
  }
  return _linkColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinkColor:(UIColor *)linkColor {
  if (_linkColor != linkColor) {
    [_linkColor release];
    _linkColor = [linkColor retain];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)linkHighlightColor {
  if (!_linkHighlightColor) {
    _linkHighlightColor = [[UIColor colorWithWhite:0.5f alpha:0.5f] retain];
  }
  return _linkHighlightColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLinkHighlightColor:(UIColor *)linkHighlightColor {
  if (_linkHighlightColor != linkHighlightColor) {
    [_linkHighlightColor release];
    _linkHighlightColor = [linkHighlightColor retain];

    [self attributedTextDidChange];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Use an NSDataDetector to find any implicit links in the text. The results are cached until
// the text changes.
- (void)detectLinks {
  if (self.autoDetectLinks && !_linksHaveBeenDetected) {
    NSError* error = nil;
    NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
    NSString* string = _attributedString.string;
    NSRange range = NSMakeRange(0, string.length);

    [_detectedlinkLocations release];
    _detectedlinkLocations = [[linkDetector matchesInString:string options:0 range:range] retain];

    _linksHaveBeenDetected = YES;
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

    for (NSTextCheckingResult* result in _detectedlinkLocations) {
      if (NSLocationInRange(i, result.range)) {
        foundResult = [[result retain] autorelease];
        break;
      }
    }
  }

  if (nil == foundResult) {
    for (NSTextCheckingResult* result in _explicitLinkLocations) {
      if (NSLocationInRange(i, result.range)) {
        foundResult = [[result retain] autorelease];
        break;
      }
    }
  }
  
	return foundResult;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSTextCheckingResult *)linkAtPoint:(CGPoint)point {
  static const CGFloat kVMargin = 5.0f;
	if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), point)) {
    return nil;
  }

  CFArrayRef lines = CTFrameGetLines(_textFrame);
	if (!lines) return nil;
	CFIndex count = CFArrayGetCount(lines);

  NSTextCheckingResult* foundLink = nil;

	CGPoint origins[count];
	CTFrameGetLineOrigins(_textFrame, CFRangeMake(0,0), origins);

  for (int i = 0; i < count; i++) {
		CGPoint linePoint = origins[i];

		CTLineRef line = CFArrayGetValueAtIndex(lines, i);
		CGRect flippedRect = [self getLineBounds:line point:linePoint];
    CGRect bounds = CGRectMake(CGRectGetMinX(self.bounds),
                               CGRectGetMaxY(self.bounds)-CGRectGetMaxY(self.bounds),
                               CGRectGetWidth(self.bounds),
                               CGRectGetHeight(self.bounds));
    CGRect rect = CGRectMake(CGRectGetMinX(flippedRect),
                             CGRectGetMaxY(bounds)-CGRectGetMaxY(flippedRect),
                             CGRectGetWidth(flippedRect),
                             CGRectGetHeight(flippedRect));                      

		rect = CGRectInset(rect, 0, -kVMargin);
		if (CGRectContainsPoint(rect, point)) {
			CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                          point.y-CGRectGetMinY(rect));
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			foundLink = ([self linkAtIndex:idx]);
			if (foundLink) return foundLink;
		}
	}
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView* view = [super hitTest:point withEvent:event];
  if (view != self) {
		return view;
	}
  if ([self linkAtPoint:point] == nil) {
    return nil;
  }
  return view;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

  [_touchedLink release];
  _touchedLink = [[self linkAtPoint:point] retain];

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];

  NSTextCheckingResult* linkTouched = [self linkAtPoint:point];

  if (_touchedLink.URL && [_touchedLink.URL isEqual:linkTouched.URL]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(attributedLabel:didSelectLink:atPoint:)]) {
      [self.delegate attributedLabel:self didSelectLink:linkTouched.URL atPoint:point];
    }
  }

  NI_RELEASE_SAFELY(_touchedLink);

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  NI_RELEASE_SAFELY(_touchedLink);

  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// We apply the link styles immediately before we render the attributed string. This
// composites the link styles with the existing styles without losing any information. This
// makes it possible to turn off links or remove them altogether without losing the existing
// style information.
- (NSMutableAttributedString *)mutableAttributedStringWithLinkStylesApplied {
  NSMutableAttributedString* attributedString = [[self.attributedString mutableCopy] autorelease];
  if (self.autoDetectLinks) {
    for (NSTextCheckingResult* result in _detectedlinkLocations) {
      [attributedString setTextColor:self.linkColor
                               range:result.range];
    }
  }

  for (NSTextCheckingResult* result in _explicitLinkLocations) {
    [attributedString setTextColor:self.linkColor
                             range:result.range];
  }

  return attributedString;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawTextInRect:(CGRect)rect {
  if (self.autoDetectLinks) {
    [self detectLinks];
  }

  NSMutableAttributedString* attributedStringWithLinks =
    [self mutableAttributedStringWithLinkStylesApplied];
  self.userInteractionEnabled = (_detectedlinkLocations.count > 0
                                 || _explicitLinkLocations.count > 0);

  if (nil != attributedStringWithLinks) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);

    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height),
                                                   1.f, -1.f));

    if (nil == _textFrame) {
      CFAttributedStringRef attributedString = (CFAttributedStringRef)attributedStringWithLinks;
      CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);

      CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, self.bounds);
      _textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
			CGPathRelease(path);
			CFRelease(framesetter);
    }

    if (nil != _touchedLink) {
      // Draw the link's background first.
      [self.linkHighlightColor setFill];

      NSRange linkRange = _touchedLink.range;

      CFArrayRef lines = CTFrameGetLines(_textFrame);
      CFIndex count = CFArrayGetCount(lines);
      CGPoint lineOrigins[count];
      CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);

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

    CTFrameDraw(_textFrame, ctx);
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
    attributedString = [[[NSMutableAttributedString alloc] initWithString:label.text] autorelease];
    
    [attributedString setFont:label.font];
    [attributedString setTextColor:label.textColor];
    
    CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:label.textAlignment];
    CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:label.lineBreakMode];
    
    [attributedString setTextAlignment:textAlignment lineBreakMode:lineBreak]; 
  }
  
  return attributedString;
}

@end
