//
// Copyright 2011 Jeff Verkoeyen
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

#import "NIOverviewGraphView.h"

#import <QuartzCore/QuartzCore.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewGraphView

@synthesize dataSource = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2f].CGColor;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawGraphWithContext:(CGContextRef)context {
  CGSize contentSize = self.bounds.size;

  CGFloat xRange = [self.dataSource graphViewXRange:self];
  CGFloat yRange = [self.dataSource graphViewYRange:self];
  if (xRange == 0 || yRange == 0) {
    return;
  }

  [self.dataSource resetPointIterator];

  CGContextSetLineWidth(context, 1);
  CGContextSetShouldAntialias(context, YES);

  BOOL isFirstPoint = YES;
  CGPoint point = CGPointZero;
  while ([self.dataSource nextPointInGraphView:self point:&point]) {
    CGPoint scaledPoint = CGPointMake(point.x / xRange, point.y / yRange);
    CGPoint plotPoint = CGPointMake(floorf(scaledPoint.x * contentSize.width) - 0.5f,
                                    contentSize.height
                                    - floorf((scaledPoint.y * 0.8f + 0.1f)
                                             * contentSize.height) - 0.5f);
    if (!isFirstPoint) {
      CGContextAddLineToPoint(context, plotPoint.x, plotPoint.y);
    }
    CGContextMoveToPoint(context, plotPoint.x, plotPoint.y);
    isFirstPoint = NO;
  }

	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.6f].CGColor);
	CGContextStrokePath(context);
  
  [self.dataSource resetEventIterator];

  CGFloat xValue = 0;
  UIColor* color = nil;
  while ([self.dataSource nextEventInGraphView:self xValue:&xValue color:&color]) {
    CGFloat scaledXValue = xValue / xRange;
    CGFloat plotXValue = floorf(scaledXValue * contentSize.width) - 0.5f;
    CGContextMoveToPoint(context, plotXValue, 0);
    CGContextAddLineToPoint(context, plotXValue, contentSize.height);

    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();

  CGRect bounds = self.bounds;
  
  UIGraphicsPushContext(context);

  [self drawGraphWithContext:context];
  
	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.2f].CGColor);
	CGContextFillRect(context, bounds);

  CGGradientRef glossGradient = nil;
  CGColorSpaceRef colorspace = nil;
  size_t numberOfLocations = 2;
  CGFloat locations[2] = { 0.0f, 1.0f };
  CGFloat components[8] = {
    1.0f, 1.0f, 1.0f, 0.35f,
    1.0f, 1.0f, 1.0f, 0.06f
  };

  colorspace = CGColorSpaceCreateDeviceRGB();
  glossGradient = CGGradientCreateWithColorComponents(colorspace,
                                                      components, locations, numberOfLocations);

  CGPoint topCenter = CGPointMake(CGRectGetMidX(bounds), 0.0f);
  CGPoint midCenter = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);

  CGGradientRelease(glossGradient);
  glossGradient = nil;
  CGColorSpaceRelease(colorspace);
  colorspace = nil;

  UIGraphicsPopContext();
}


@end
