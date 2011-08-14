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

@implementation NIBadgeView

@synthesize text      = _text;
@synthesize tintColor = _tintColor;
@synthesize font      = _font;
@synthesize textColor = _textColor;

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentScaleFactor = NIScreenScale();
		self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor redColor];
    self.font = [UIFont boldSystemFontOfSize:14];
    self.textColor = [UIColor whiteColor];
  }
  return self;
}

-(CGSize)sizeThatFits:(CGSize)size {

	CGFloat rectWidth, rectHeight;
	CGSize stringSize = [self.text sizeWithFont:_font];
  
  CGFloat scaleFactor = _font.pointSize / 14;
  
	if ([self.text length]>=2) {
		rectWidth = 10 + (stringSize.width + [self.text length]); 
    rectHeight = 25;
		
    return CGSizeMake(rectWidth, rectHeight * scaleFactor);
	}
  return CGSizeMake(25 * scaleFactor, 25 * scaleFactor);
}

-(void)setText:(NSString *)text {
  _text = text;
  [self setNeedsDisplay];
}

-(void)setFont:(UIFont *)font {
  _font = font;
  [self setNeedsDisplay];
}

-(void)setTintColor:(UIColor *)tintColor {
  _tintColor = tintColor;
  [self setNeedsDisplay];
}

-(void)setTextColor:(UIColor *)textColor {
  _textColor = textColor;
  [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  
  CGFloat radius = CGRectGetMaxY(rect)*kBadgeRadius;
  CGFloat buffer = CGRectGetMaxY(rect)*0.015;
	CGFloat maxX = CGRectGetMaxX(rect) - buffer - 2;
	CGFloat maxY = CGRectGetMaxY(rect) - buffer - 4;
	CGFloat minX = CGRectGetMinX(rect) + buffer + 2;
	CGFloat minY = CGRectGetMinY(rect) + buffer + 1;
  
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
  
  //Add the gloss effect
  CGContextSaveGState(context);
  
  CGContextBeginPath(context);
  CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
  // Gloss should have a bottom curve. Math anyone?
	CGContextClip(context);
	
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.3 };
	CGFloat components[8] = {  0.92, 1.0, 1.0, 1.0, 0.82, 0.82, 0.82, 0.3 };
  
	CGColorSpaceRef cspace;
	CGGradientRef gradient;
	cspace = CGColorSpaceCreateDeviceRGB();
	gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
	
	CGPoint sPoint, ePoint;
	sPoint.x = 0;
	sPoint.y = 1;
	ePoint.x = 0;
	ePoint.y = maxY;
	CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
	
	CGColorSpaceRelease(cspace);
	CGGradientRelease(gradient);
  
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
  
  // Draw text
  [self.textColor set];
  CGSize textSize = [self.text sizeWithFont:self.font];
  
  // We remove 1 point from the y-axis to account for the drop shadow.
  [self.text drawAtPoint:
   CGPointMake(floorf(rect.size.width/2-textSize.width/2), 
               floorf(rect.size.height/2-textSize.height/2-2)) 
                withFont:self.font];
  
  }


@end
