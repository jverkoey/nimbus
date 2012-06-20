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

#import "NimbusCore.h" // For NIScreenScale

static const CGFloat kMinimumWidth = 30.f;
static const CGFloat kHorizontalMargins = 20.f;
static const CGFloat kVerticalMargins = 10.f;
static const CGFloat kBadgeLineSize = 2.0f;

@implementation NIBadgeView

@synthesize text = _text;
@synthesize tintColor = _tintColor;
@synthesize font = _font;
@synthesize textColor = _textColor;

- (void)_configureDefaults {
  self.contentScaleFactor = NIScreenScale();
  self.tintColor = [UIColor redColor];
  self.font = [UIFont boldSystemFontOfSize:17];
  self.textColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self _configureDefaults];
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];

  [self _configureDefaults];
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize stringSize = [self.text sizeWithFont:self.font];

  return CGSizeMake(MAX(kMinimumWidth, stringSize.width + kHorizontalMargins),
                    stringSize.height + kVerticalMargins);
}

- (void)setText:(NSString *)text {
  _text = text;

  [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
  _font = font;

  [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tintColor {
  _tintColor = tintColor;

  [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor {
  _textColor = textColor;

  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);

  // The following constant offsets are chosen to make the badge match the system badge dimensions
  // pixel-for-pixel.
  CGFloat minX = CGRectGetMinX(rect) + 4.f;
  CGFloat maxX = CGRectGetMaxX(rect) - 5.f;
  CGFloat minY = CGRectGetMinY(rect) + 3.5f;
  CGFloat maxY = CGRectGetMaxY(rect) - 6.5f;

  // Used to suppress warning: Implicit conversion shortens 64-bit value into 32-bit value
  const CGFloat pi = (CGFloat)M_PI;
  const CGFloat kRadius = 10.5f;

  // Draw the main rounded rectangle
  CGContextBeginPath(context);
  CGContextSetFillColorWithColor(context, [_tintColor CGColor]);
  CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
  CGContextAddArc(context, maxX-kRadius, maxY-kRadius, kRadius, 0, pi/2, 0);
  CGContextAddArc(context, minX+kRadius, maxY-kRadius, kRadius, pi/2, pi, 0);
  CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
  CGContextSetShadowWithColor(context, CGSizeMake(0.0f,3.0f), 3.0f, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
  CGContextFillPath(context);

  CGContextRestoreGState(context);

  // Add the gloss effect
  CGContextSaveGState(context);

  CGContextBeginPath(context);
  CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
  CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
  CGContextAddRect(context, CGRectMake(minX, minY + kRadius,
                                       rect.size.width - kRadius + 1, CGRectGetMidY(rect) - kRadius));
  CGContextClip(context);
  
  size_t num_locations = 2;
  CGFloat locations[] = { 0.0f, 1.f };
  CGFloat components[] = {
    1.f, 1.f, 1.f, 0.8f,
    1.f, 1.f, 1.f, 0.0f };

  CGColorSpaceRef cspace;
  CGGradientRef gradient;
  cspace = CGColorSpaceCreateDeviceRGB();
  gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
  
  CGPoint sPoint, ePoint;
  sPoint.x = 0;
  sPoint.y = 4;
  ePoint.x = 0;
  ePoint.y = CGRectGetMidY(rect) - 2;
  CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
  
  CGColorSpaceRelease(cspace);
  CGGradientRelease(gradient);

  CGContextRestoreGState(context);

  // Draw the border
  CGContextBeginPath(context);
  CGContextSetLineWidth(context, kBadgeLineSize);
  // Should this be customizable?
  CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
  CGContextAddArc(context, maxX-kRadius, minY+kRadius, kRadius, pi+(pi/2), 0, 0);
  CGContextAddArc(context, maxX-kRadius, maxY-kRadius, kRadius, 0, pi/2, 0);
  CGContextAddArc(context, minX+kRadius, maxY-kRadius, kRadius, pi/2, pi, 0);
  CGContextAddArc(context, minX+kRadius, minY+kRadius, kRadius, pi, pi+pi/2, 0);
  CGContextClosePath(context);
  CGContextStrokePath(context);

  // Draw text
  [self.textColor set];
  CGSize textSize = [self.text sizeWithFont:self.font];

  [self.text drawAtPoint:CGPointMake(floorf((rect.size.width - textSize.width) / 2.f) - 0.f,
                                     floorf((rect.size.height - textSize.height) / 2.f) - 2.f)
                withFont:self.font];
}


@end
