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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel
@synthesize autoDetectLinks         = _autoDetectLinks;
@synthesize underlineStyle          = _underlineStyle;
@synthesize underlineStyleModifier  = _underlineStyleModifier;
@synthesize strokeWidth             = _strokeWidth;
@synthesize strokeColor             = _strokeColor;
@synthesize textKern                = _textKern;
@synthesize linkColor               = _linkColor;
@synthesize linkHighlightColor      = _linkHighlightColor;
@synthesize delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
  if (nil != _textFrame) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}

  NI_RELEASE_SAFELY(_attributedText);
  NI_RELEASE_SAFELY(_linkColor);
  NI_RELEASE_SAFELY(_linkHighlightColor);
  NI_RELEASE_SAFELY(_currentLink);
  NI_RELEASE_SAFELY(_strokeColor);
  NI_RELEASE_SAFELY(_customLinks);

  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CTTextAlignment) alignmentFromUITextAlignment:(UITextAlignment)alignment {

  switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		case UITextAlignmentJustify: return kCTJustifiedTextAlignment; 		
    default: return kCTNaturalTextAlignment;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CTLineBreakMode) lineBreakModeFromUILineBreakMode:(UILineBreakMode) lineBreakMode {
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
-(void) resetFromLabel {
  NSMutableAttributedString* attributedString =
  ((nil != self.text)
   ? [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease]
   : nil);

  [attributedString setFont:self.font];
  [attributedString setTextColor:self.textColor];

  CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:self.textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:self.lineBreakMode];

  [attributedString setTextAlignment:textAlignment lineBreakMode:lineBreak]; 

  self.attributedText = attributedString;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)awakeFromNib {
  [super awakeFromNib];
  [self resetFromLabel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSAttributedString*) attributedText {
  
  if (!_attributedText) {
    [self resetFromLabel];
  }
  return [[_attributedText copy] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAttributedText:(NSAttributedString *)attributedText {
  [_attributedText release];
  _attributedText = [attributedText mutableCopy];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setText:(NSString *)text {
  [super setText:text];
	[self resetFromLabel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTextAlignment:(UITextAlignment)textAlignment {
  CTTextAlignment alignment = [self alignmentFromUITextAlignment:textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:self.lineBreakMode];
  [_attributedText setTextAlignment:alignment lineBreakMode:lineBreak]; 
  [super setTextAlignment:textAlignment];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
  CTTextAlignment alignment = [self alignmentFromUITextAlignment:self.textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:lineBreakMode];
  [_attributedText setTextAlignment:alignment lineBreakMode:lineBreak]; 
  [super setLineBreakMode:lineBreakMode];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTextColor:(UIColor *)textColor{
  [_attributedText setTextColor:textColor];
  [super setTextColor:textColor];
}

-(void)setTextColor:(UIColor *)textColor range:(NSRange)range {
  [_attributedText setTextColor:textColor range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFont:(UIFont *)font {
  [_attributedText setFont:font];
	[super setFont:font];
}

-(void)setFont:(UIFont *)font range:(NSRange)range {
  [_attributedText setFont:font range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setUnderlineStyle:(CTUnderlineStyle)style {
  _underlineStyle = style;
  [_attributedText setUnderlineStyle:style 
                            modifier:self.underlineStyleModifier];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setUnderlineStyleModifier:(CTUnderlineStyleModifiers)modifier {
  _underlineStyleModifier = modifier;
  [_attributedText setUnderlineStyle:self.underlineStyle 
                            modifier:modifier];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setUnderlineStyle:(CTUnderlineStyle)style 
                modifier:(CTUnderlineStyleModifiers)modifier 
                   range:(NSRange)range {
  [_attributedText setUnderlineStyle:style 
                            modifier:modifier
                               range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setStrokeWidth:(CGFloat)strokeWidth {
  _strokeWidth = strokeWidth;
  [_attributedText setStrokeWidth:strokeWidth];
  [self setNeedsDisplay];
}

-(void)setStrokeWidth:(CGFloat)width range:(NSRange)range {
  [_attributedText setStrokeWidth:width range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setStrokeColor:(UIColor *)strokeColor {
  _strokeColor = [strokeColor retain];
  [_attributedText setStrokeColor:_strokeColor];
  [self setNeedsDisplay];
}

-(void)setStrokeColor:(UIColor*)color range:(NSRange)range {
  [_attributedText setStrokeColor:_strokeColor range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTextKern:(CGFloat)textKern {
  _textKern = textKern;
  [_attributedText setKern:_textKern];
  [self setNeedsDisplay];
}

-(void)setTextKern:(CGFloat)kern range:(NSRange)range {
  [_attributedText setKern:kern range:range];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAutoDetectLinks:(BOOL)autoDetectLinks {
  _autoDetectLinks = autoDetectLinks;
  
  // only toggle interation if we don't have custom links
  if ([_customLinks count] == 0) {
    self.userInteractionEnabled = autoDetectLinks;
  }
  
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor *)linkColor {
  if (!_linkColor) {
    _linkColor = [[UIColor blueColor] retain];
  }
  return _linkColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setLinkColor:(UIColor *)linkColor {
  _linkColor = [linkColor retain];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(UIColor *)linkHighlightColor {
  if (!_linkHighlightColor) {
    _linkHighlightColor = [[UIColor colorWithWhite:0.5f alpha:0.2f] retain];
  }
  return _linkHighlightColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setLinkHighlightColor:(UIColor *)linkHighlightColor{
  _linkHighlightColor = [linkHighlightColor retain];
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addLink:(NSURL*)urlLink range:(NSRange)range {
  if (nil == _customLinks) {
    _customLinks = [[NSMutableArray alloc] init];
  }

  [_customLinks addObject:[NSTextCheckingResult 
                           linkCheckingResultWithRange:range URL:urlLink]];

  self.userInteractionEnabled = YES;

  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeAllLinks {
  [_customLinks release];
  _customLinks = nil;
  self.userInteractionEnabled = _autoDetectLinks;
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resetTextFrame {
	if (nil != _textFrame) {
		CFRelease(_textFrame);
		_textFrame = nil;
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setNeedsDisplay {
  [self resetTextFrame];
  [super setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
	if (nil == _attributedText) return CGSizeZero;
  
  CTFramesetterRef framesetter = 
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
	CFRange fitCFRange = CFRangeMake(0,0);
	CGSize newSize = 
    CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,size,&fitCFRange);
	if (framesetter) CFRelease(framesetter);
	return CGSizeMake( floorf(newSize.width+1) , floorf(newSize.height+1) );
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSMutableAttributedString*) linksDetectedAttributedString {
  NSMutableAttributedString* attributedString = [self.attributedText mutableCopy];
	if (nil == attributedString) return nil;

  if (_autoDetectLinks) {
    NSError* error = nil;
    NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
    [linkDetector enumerateMatchesInString:[attributedString string] 
                                   options:0 
                                     range:NSMakeRange(0,[[attributedString string] length])
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  [attributedString setTextColor:self.linkColor
                                                           range:[result range]];
                                }];
  }
  
  
  for (NSTextCheckingResult* customLink in _customLinks) {
    [attributedString setTextColor:self.linkColor
                             range:customLink.range];
  }
  
  return [attributedString autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
  CGFloat ascent = 0.0f;
	CGFloat descent = 0.0f;
	CGFloat leading = 0.0f;
	CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	return CGRectMake(point.x, point.y - descent, width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSTextCheckingResult*)linkAtIndex:(CFIndex)i {

  __block NSTextCheckingResult* foundResult = nil;
  
  if (_autoDetectLinks) {
    NSError* error = nil;
    NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink 
                                                                   error:&error];
    [linkDetector enumerateMatchesInString:[_attributedText string] 
                                   options:0 
                                     range:NSMakeRange(0,[[_attributedText string] length])
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                  NSRange range = [result range];
                                  if (NSLocationInRange(i, range)) {
                                    foundResult = [[result retain] autorelease];
                                    *stop = YES;
                                  }
    }];
      
    if (foundResult) return foundResult;
  }
  
  for (NSTextCheckingResult* customLink in _customLinks) {
    if (NSLocationInRange(i, customLink.range)) {
      return [[customLink retain] autorelease];
    }
  }
  
	return foundResult;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)point {
  static const CGFloat kVMargin = 5.0f;
	if (!CGRectContainsPoint(CGRectInset(_drawingRect, 0, -kVMargin), point)) return nil;

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
    CGRect bounds = CGRectMake(CGRectGetMinX(_drawingRect),
                               CGRectGetMaxY(self.bounds)-CGRectGetMaxY(_drawingRect),
                               CGRectGetWidth(_drawingRect),
                               CGRectGetHeight(_drawingRect));
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
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  UIView *view = [super hitTest:point withEvent:event];
  if (view != self) {
		return view;
	}
  if ([self linkAtPoint:point] == nil) {
      return nil;
  }
  return view;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
  
  NI_RELEASE_SAFELY(_currentLink);
  _currentLink = [[self linkAtPoint:point] retain];
  
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
  
  NSTextCheckingResult *linkTouched = [self linkAtPoint:point];
  
  if (_currentLink.URL && [_currentLink.URL isEqual:linkTouched.URL]) {
    if (delegate && [delegate respondsToSelector:@selector(attributedLabel:didSelectLink:atPoint:)]) {
      [delegate attributedLabel:self didSelectLink:linkTouched.URL atPoint:point];
    }
  }
  
  NI_RELEASE_SAFELY(_currentLink);
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawTextInRect:(CGRect)rect {
  if (_attributedText) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);

    NSMutableAttributedString* attributedString = _autoDetectLinks || [_customLinks count] > 0 ? 
      [self linksDetectedAttributedString] : [[self.attributedText copy] autorelease];

    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGContextConcatCTM(ctx,
                       CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height),
                                              1.f, -1.f));
    
    if (_textFrame == nil) {
      CTFramesetterRef framesetter =
        CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
      _drawingRect = self.bounds;
      CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, _drawingRect);
      _textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
			CGPathRelease(path);
			CFRelease(framesetter);
    }
    
    if (_currentLink) {
      
      [self.linkHighlightColor setFill];
      
      NSRange linkRange = _currentLink.range;
      
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
            highlightRect = CGRectUnion(rect, linkRect);
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
