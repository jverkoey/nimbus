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

#import "NIOverviewerGraphView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerGraphView

@synthesize dataSource = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawGraphWithContext:(CGContextRef)context {
  CGSize contentSize = self.bounds.size;

  CGFloat xRange = [self.dataSource graphViewXRange:self];
  CGFloat yRange = [self.dataSource graphViewYRange:self];
  
  [self.dataSource resetPointIterator];

  CGContextSetLineWidth(context, 1);
  CGContextSetShouldAntialias(context, YES);
  
  BOOL isFirstPoint = YES;
  CGPoint point = CGPointZero;
  while ([self.dataSource nextPointInGraphView:self
                                         point:&point]) {
    CGPoint scaledPoint = CGPointMake(point.x / xRange, point.y / yRange);
    CGPoint plotPoint = CGPointMake(floorf(scaledPoint.x * contentSize.width) - 0.5f,
                                    contentSize.height
                                    - floorf(scaledPoint.y * contentSize.height) - 0.5f);
    if (!isFirstPoint) {
      CGContextAddLineToPoint(context, plotPoint.x, plotPoint.y);
    }
    CGContextMoveToPoint(context, plotPoint.x, plotPoint.y);
    isFirstPoint = NO;
  }

	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextStrokePath(context);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
  
  UIGraphicsPushContext(context);

	CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
	CGContextFillRect(context, self.bounds);
	
  [self drawGraphWithContext:context];
  
  UIGraphicsPopContext();
}


@end
