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
  NSMutableAttributedString* attibutedString = self.text ? 
  [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease] : nil;
  
  NSRange range = NSMakeRange(0,[attibutedString length]);
  
  CTFontRef font = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, nil);
  // Fix for Apple leak
  [attibutedString removeAttribute:(NSString * )kCTFontAttributeName range:range]; 
	[attibutedString addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:range];
	CFRelease(font);
  
  // Fix for Apple leak
  [attibutedString removeAttribute:(NSString * )kCTForegroundColorAttributeName range:range]; 
	[attibutedString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                          value:(id)self.textColor.CGColor 
                          range:range];
  
  CTTextAlignment textAlignment = [self alignmentFromUITextAlignment:self.textAlignment];
  CTLineBreakMode lineBreak = [self lineBreakModeFromUILineBreakMode:self.lineBreakMode];
  
  CTParagraphStyleSetting paragraphStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, 
      .valueSize = sizeof(CTTextAlignment), 
      .value = (const void*)&textAlignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, 
      .valueSize = sizeof(CTLineBreakMode), 
      .value = (const void*)&lineBreak},
	};
	CTParagraphStyleRef style = CTParagraphStyleCreate(paragraphStyles, 2);
  [attibutedString addAttribute:(NSString*)kCTParagraphStyleAttributeName 
                          value:(id)style 
                          range:range];
  CFRelease(style);
  
  self.attributedText = attibutedString;
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
-(void)setTextAlignment:(UITextAlignment)textAlignment{
  [super setTextAlignment:textAlignment];
  [self resetFromLabel];
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
-(void)drawTextInRect:(CGRect)rect {
  if (_attributedText) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
    
    // CoreText context coordinates are the opposite to UIKit so we flip the bounds
    CGContextConcatCTM(ctx,
                       CGAffineTransformScale(
                          CGAffineTransformMakeTranslation(0, self.bounds.size.height),
                                              1.f, -1.f));
    
    if (_textFrame == nil) {
      CTFramesetterRef framesetter =
        CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attributedText);
      _drawingRect = self.bounds;
      CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, _drawingRect);
      _textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
			CGPathRelease(path);
			CFRelease(framesetter);
    }
    
    CTFrameDraw(_textFrame, ctx);
		CGContextRestoreGState(ctx);
    
  } else {
    [super drawTextInRect:rect];
  }
}


@end
