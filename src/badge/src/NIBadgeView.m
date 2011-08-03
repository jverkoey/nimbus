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

#import "NIBadgeView.h"

static const CGFloat kBadgeRadius = 0.4;
static const CGFloat kBadgeLineSize = 2.0;
static const CGFloat kTextHPadding = 2.5;
static const CGFloat kTextVPadding = 1.2;

@implementation NIBadgeView

@synthesize text      = _text;
@synthesize tintColor = _tintColor;
@synthesize font      = _font;

- (id) init {
  self = [super init];
  if (self) {
    self.contentScaleFactor = NIScreenScale();
		self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor redColor];
    self.font = [UIFont boldSystemFontOfSize:13];
  }
  return self;
}

- (id)initWithText:(NSString*)t {
    self = [self init];
    if (self) {
      self.text = t;
    }
    return self;
}

- (id)initWithText:(NSString*)t font:(UIFont*)f {
  self = [self initWithText:t];
  if (self) {
    self.font = f;
  }
  return self;
}

- (id)initWithText:(NSString*)t tintColor:(UIColor*)c {
  self = [self initWithText:t];
  if (self) {
    self.tintColor = c;
  }
  return self;
}

- (id)initWithText:(NSString*)t font:(UIFont*)f tintColor:(UIColor*)c {
  self = [self initWithText:t font:f];
  if (self) {
    self.tintColor = c;
  }
  return self;
}

-(void) autoFit {
  
  CGSize retValue;
	CGFloat rectWidth, rectHeight;
	CGSize stringSize = [self.text sizeWithFont:_font];
  
  CGFloat scaleFactor = _font.pointSize / 13;
  
	if ([self.text length]>=2) {
		rectWidth = 10 + (stringSize.width + [self.text length]); 
    rectHeight = 20;
		retValue = CGSizeMake(rectWidth, rectHeight * scaleFactor);
	} else {
		retValue = CGSizeMake(20 * scaleFactor, 20 * scaleFactor);
	}
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, retValue.width, retValue.height);
	[self setNeedsDisplay];
}

-(void)setText:(NSString *)text {
  _text = text;
  [self autoFit];
}

-(void)setFont:(UIFont *)font {
  _font = font;
  [self autoFit];
}

-(void)setTintColor:(UIColor *)tintColor {
  _tintColor = tintColor;
  [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGFloat radius = CGRectGetMaxY(rect)*kBadgeRadius;
  CGFloat buffer = CGRectGetMaxY(rect)*0.10;
	CGFloat maxX = CGRectGetMaxX(rect) - buffer;
	CGFloat maxY = CGRectGetMaxY(rect) - buffer;
	CGFloat minX = CGRectGetMinX(rect) + buffer;
	CGFloat minY = CGRectGetMinY(rect) + buffer;
  
  // Draw the main rounded rectangle
  CGContextBeginPath(context);
  CGContextSetFillColorWithColor(context, [_tintColor CGColor]);
  CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
  CGContextSetShadowWithColor(context, CGSizeMake(0.0,2.0), 3.0, [[UIColor blackColor] CGColor]);
  CGContextFillPath(context);
  
  CGContextRestoreGState(context);
  
  // Draw the border
  CGContextBeginPath(context);
  CGContextSetLineWidth(context, kBadgeLineSize);
  // Should this be customizable?
  CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
  CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
	CGContextClosePath(context);
	CGContextStrokePath(context);
  
  //TODO: Add the gloss effect
  
  // Draw text
  // Should this be customizable?
  [[UIColor whiteColor] set];
  CGSize textSize = [self.text sizeWithFont:self.font];
  [self.text drawAtPoint:
   CGPointMake((rect.size.width/2-textSize.width/2), 
               (rect.size.height/2-textSize.height/2)-1) 
                withFont:self.font];
  
  }


@end
