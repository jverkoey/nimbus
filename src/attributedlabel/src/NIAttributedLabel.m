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

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIAttributedLabel
@synthesize delegate;

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
-(void) attributedString:(NSMutableAttributedString*)attributedString
        setTextAlignment:(CTTextAlignment)textAlignment 
           lineBreakMode:(CTLineBreakMode)lineBreakMode {
  
  NSRange range = NSMakeRange(0,[attributedString length]);
  
  CTParagraphStyleSetting paragraphStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, 
      .valueSize = sizeof(CTTextAlignment), 
      .value = (const void*)&textAlignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, 
      .valueSize = sizeof(CTLineBreakMode), 
      .value = (const void*)&lineBreakMode},
	};
	CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyles, 2);
  [attributedString addAttribute:(NSString*)kCTParagraphStyleAttributeName 
                          value:(id)style 
                          range:range];
  CFRelease(style);

}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) attributedString:(NSMutableAttributedString*)attributedString
            setTextColor:(UIColor*)color range:(NSRange)range{

  [attributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range]; 
	[attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                           value:(id)color.CGColor 
                           range:range];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) attributedString:(NSMutableAttributedString*)attributedString
            setTextColor:(UIColor*)color{
  [self attributedString:attributedString 
            setTextColor:color 
                   range:NSMakeRange(0,[attributedString length])];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) attributedString:(NSMutableAttributedString*)attributedString
            setFont:(UIFont*)font{
  
  NSRange range = NSMakeRange(0,[attributedString length]);
  CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, nil);
  [attributedString removeAttribute:(NSString*)kCTFontAttributeName range:range]; 
	[attributedString addAttribute:(NSString*)kCTFontAttributeName value:(id)fontRef range:range];
	CFRelease(font);
  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) resetFromLabel {
  NSMutableAttributedString* attributedString = self.text ? 
  [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease] : nil;
  
  [self attributedString:attributedString setFont:self.font];
  [self attributedString:attributedString setTextColor:self.textColor];
  
  CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:self.textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:self.lineBreakMode];
  [self attributedString:attributedString setTextAlignment:textAlignment lineBreakMode:lineBreak]; 
  
  self.attributedText = attributedString;
}

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
  NI_RELEASE_SAFELY(_attributedText);
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
  [self attributedString:_attributedText setTextAlignment:alignment lineBreakMode:lineBreak]; 
  [super setTextAlignment:textAlignment];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
  CTTextAlignment alignment = [self alignmentFromUITextAlignment:self.textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:lineBreakMode];
  [self attributedString:_attributedText setTextAlignment:alignment lineBreakMode:lineBreak]; 
  [super setLineBreakMode:lineBreakMode];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setTextColor:(UIColor *)textColor{
  [self attributedString:_attributedText setTextColor:textColor];
  [super setTextColor:textColor];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFont:(UIFont *)font {
  [self attributedString:_attributedText setFont:font];
	[super setFont:font];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)resetTextFrame {
	if (_textFrame) {
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
	if (!_attributedText) return CGSizeZero;
  
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
	if (!attributedString) return nil;
  
  NSError* error = nil;
  NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
  [linkDetector enumerateMatchesInString:[attributedString string] 
                                 options:0 
                                   range:NSMakeRange(0,[[attributedString string] length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
                              {
                                // TODO: Need to customize link text color
                                [self attributedString:attributedString 
                                          setTextColor:[UIColor blueColor] 
                                                 range:[result range]];
                              }];
  return attributedString;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point {
  CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	return CGRectMake(point.x, point.y - descent, width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSTextCheckingResult*)linkAtIndex:(CFIndex)index {
	
  __block NSTextCheckingResult* foundResult = nil;
  
  NSError* error = nil;
  NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
  [linkDetector enumerateMatchesInString:[_attributedText string] options:0 range:NSMakeRange(0,[[_attributedText string] length])
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
                              {
                                NSRange range = [result range];
                                if (NSLocationInRange(index, range)) {
                                  foundResult = [[result retain] autorelease];
                                  *stop = YES;
                                }
                              }];
	return foundResult;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)point {
  static const CGFloat kVMargin = 5.0f;
	if (!CGRectContainsPoint(CGRectInset(_drawingRect, 0, -kVMargin), point)) return nil;
  
  CFArrayRef lines = CTFrameGetLines(_textFrame);
	if (!lines) return nil;
	CFIndex count = CFArrayGetCount(lines);
	
  NSTextCheckingResult* link = nil;
	
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
			CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
			link = ([self linkAtIndex:index]);
			if (link) return link;
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
    if (delegate && [delegate respondsToSelector:@selector(attributedLabel:didSelectLink:)]) {
      [delegate attributedLabel:self didSelectLink:linkTouched.URL];
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
    
    NSMutableAttributedString* attributedString = [self linksDetectedAttributedString];
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGContextConcatCTM(ctx,
                       CGAffineTransformScale(
                          CGAffineTransformMakeTranslation(0, self.bounds.size.height),
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
      // TODO: Need to customize highlight color
      UIColor* highlightColor = [UIColor colorWithWhite:0.5 alpha:0.2];
      [highlightColor setFill];
      
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
        
        CGRect rect = CGRectZero;
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        for (CFIndex k = 0; k < runCount; k++) {
          CTRunRef run = CFArrayGetValueAtIndex(runs, k);
          
          CFRange stringRange = CTRunGetStringRange(run);
          NSRange lineRange = NSMakeRange(stringRange.location, stringRange.length);
          NSRange intersectedRange = NSIntersectionRange(lineRange, linkRange);
          if (intersectedRange.length == 0) {
            continue;
          }

          
          CGFloat ascent = 0;
          CGFloat descent = 0;
          CGFloat leading = 0;
          CGFloat width = CTRunGetTypographicBounds(run, 
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
          if (CGRectIsEmpty(rect)) {
            rect = linkRect;
          } else {
            rect = CGRectUnion(rect, linkRect);
          }
          
        }
        
        if (!CGRectIsEmpty(rect)) {
          
          CGFloat radius = 5.0f;
          CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y + radius);
          CGContextAddLineToPoint(ctx, rect.origin.x, rect.origin.y + rect.size.height - radius);
          CGContextAddArc(ctx, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
                          radius, M_PI, M_PI / 2, 1);
          CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width - radius, 
                                  rect.origin.y + rect.size.height);
          CGContextAddArc(ctx, rect.origin.x + rect.size.width - radius, 
                          rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
          CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y + radius);
          CGContextAddArc(ctx, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
                          radius, 0.0f, -M_PI / 2, 1);
          CGContextAddLineToPoint(ctx, rect.origin.x + radius, rect.origin.y);
          CGContextAddArc(ctx, rect.origin.x + radius, rect.origin.y + radius, radius, 
                          -M_PI / 2, M_PI, 1);
          
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
