//
// Copyright 2012 Jeff Verkoeyen
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

#import "NICellBackgrounds.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static const CGFloat kBorderSize = 1;
static const CGSize kCellImageSize = {44, 44};

@interface NIGroupedCellBackground()
@property (nonatomic, NI_STRONG) NSMutableDictionary* cachedImages;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIGroupedCellBackground

@synthesize innerBackgroundColor = _innerBackgroundColor;
@synthesize highlightedInnerGradientColors = _highlightedInnerGradientColors;
@synthesize shadowWidth = _shadowWidth;
@synthesize shadowColor = _shadowColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize borderColor = _borderColor;
@synthesize dividerColor = _dividerColor;
@synthesize borderRadius = _borderRadius;
@synthesize cachedImages = _cachedImages;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _innerBackgroundColor = [UIColor whiteColor];
    _highlightedInnerGradientColors = [NSMutableArray arrayWithObjects:
                                       (id)RGBCOLOR(53, 141, 245).CGColor,
                                       (id)RGBCOLOR(16, 93, 230).CGColor,
                                       nil];
    _shadowWidth = 4;
    _shadowOffset = CGSizeMake(0, 1);
    _shadowColor = RGBACOLOR(0, 0, 0, 0.3f);
    _borderColor = RGBACOLOR(0, 0, 0, 0.07f);
    _dividerColor = RGBCOLOR(230, 230, 230);
    _borderRadius = 5;
    _cachedImages = [NSMutableDictionary dictionary];
  }
  return self;
}

// We want to draw the borders and shadows on single retina-pixel boundaries if possible, but
// we need to avoid doing this on non-retina devices because it'll look blurry.
+ (CGFloat)minPixelOffset {
  if (NIIsRetina()) {
    return 0.5f;
  } else {
    return 1.f;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applySinglePathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat midx = CGRectGetMidX(rect) + minPixelOffset;
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat midy = CGRectGetMidY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, minx, midy);
  CGContextAddArcToPoint(c, minx, miny + 1, midx, miny + 1, self.borderRadius);
  CGContextAddArcToPoint(c, maxx, miny + 1, maxx, midy, self.borderRadius);
  CGContextAddLineToPoint(c, maxx, midy);
  CGContextAddArcToPoint(c, maxx, maxy - 1, midx, maxy - 1, self.borderRadius);
  CGContextAddArcToPoint(c, minx, maxy - 1, minx, midy, self.borderRadius);
  CGContextAddLineToPoint(c, minx, midy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyTopPathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat midx = CGRectGetMidX(rect) + minPixelOffset;
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat midy = CGRectGetMidY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, minx, maxy);
  CGContextAddLineToPoint(c, minx, midy);
  CGContextAddArcToPoint(c, minx, miny + 1, midx, miny + 1, self.borderRadius);
  CGContextAddArcToPoint(c, maxx, miny + 1, maxx, midy, self.borderRadius);
  CGContextAddLineToPoint(c, maxx, maxy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyBottomPathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat midx = CGRectGetMidX(rect) + minPixelOffset;
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat midy = CGRectGetMidY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, maxx, miny);
  CGContextAddLineToPoint(c, maxx, midy);
  CGContextAddArcToPoint(c, maxx, maxy - 1, midx, maxy - 1, self.borderRadius);
  CGContextAddArcToPoint(c, minx, maxy - 1, minx, midy, self.borderRadius);
  CGContextAddLineToPoint(c, minx, miny);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyDividerPathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, minx, maxy);
  CGContextAddLineToPoint(c, maxx, maxy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyLeftPathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, minx, miny);
  CGContextAddLineToPoint(c, minx, maxy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyRightPathToContext:(CGContextRef)c rect:(CGRect)rect {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  CGContextMoveToPoint(c, maxx, miny);
  CGContextAddLineToPoint(c, maxx, maxy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_applyPathToContext:(CGContextRef)c rect:(CGRect)rect isFirst:(BOOL)isFirst isLast:(BOOL)isLast {
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGFloat minx = CGRectGetMinX(rect) + minPixelOffset;
  CGFloat midx = CGRectGetMidX(rect) + minPixelOffset;
  CGFloat maxx = CGRectGetMaxX(rect) - minPixelOffset;
  CGFloat miny = CGRectGetMinY(rect) - minPixelOffset;
  CGFloat midy = CGRectGetMidY(rect) - minPixelOffset;
  CGFloat maxy = CGRectGetMaxY(rect) + minPixelOffset;

  CGContextBeginPath(c);

  //
  // x-> |
  //
  CGContextMoveToPoint(c, minx, midy);

  if (isFirst) {
    // arc
    //    >/
    //     |
    //
    CGContextAddArcToPoint(c, minx, miny + 1, midx, miny + 1, self.borderRadius);

    //      ______   line and then arc
    //     /      \ <
    //     |
    //
    CGContextAddArcToPoint(c, maxx, miny + 1, maxx, midy, self.borderRadius);

  } else {
    // line
    //    >|
    //     |
    //
    CGContextAddLineToPoint(c, minx, miny);

    //      ______ <- line to here
    //     |
    //     |
    //
    CGContextAddLineToPoint(c, maxx, miny);
  }

  //     isSolid?
  //        vv
  //      ______
  //     |      | -
  //     |      | -\< right edge line
  //
  CGContextAddLineToPoint(c, maxx, midy);

  if (isLast) {
    CGContextAddArcToPoint(c, maxx, maxy - 1, midx, maxy - 1, self.borderRadius);
    CGContextAddArcToPoint(c, minx, maxy - 1, minx, midy, self.borderRadius);

  } else {
    //     |      |
    //     |      |
    //     -------- <- line to here
    //
    CGContextAddLineToPoint(c, maxx, maxy);

    //     |      |
    //     |      |
    //     --------
    //     ^ then to here
    CGContextAddLineToPoint(c, minx, maxy);
  }

  // x-> |      |
  //     |      |
  //     --------
  CGContextAddLineToPoint(c, minx, midy);

  CGContextClosePath(c);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)_imageForHighlight {
  CGRect imageRect = CGRectMake(0, 0, 1, kCellImageSize.height);
  UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);

  CGContextRef cx = UIGraphicsGetCurrentContext();

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)self.highlightedInnerGradientColors, nil);
  CGColorSpaceRelease(colorSpace);
  colorSpace = nil;

  CGContextDrawLinearGradient(cx, gradient, CGPointZero, CGPointMake(imageRect.size.width, imageRect.size.height), 0);
  CGGradientRelease(gradient);
  gradient = nil;

  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)_imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider {
  CGRect imageRect = CGRectMake(0, 0, kCellImageSize.width, kCellImageSize.height);
  UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);

  CGContextRef cx = UIGraphicsGetCurrentContext();

  // Create a transparent background.
  CGContextClearRect(cx, imageRect);

  if (highlighted) {
    CGContextSetFillColorWithColor(cx, [UIColor colorWithPatternImage:self._imageForHighlight].CGColor);

  } else {
    CGContextSetFillColorWithColor(cx, self.innerBackgroundColor.CGColor);
  }

  CGRect contentFrame = CGRectInset(imageRect, self.shadowWidth, 0);
  if (first) {
    contentFrame = NIRectShift(contentFrame, 0, self.shadowWidth);
  }
  if (last) {
    contentFrame = NIRectContract(contentFrame, 0, self.shadowWidth);
  }
  if (self.shadowWidth > 0 && !highlighted) {
    // Draw the shadow
    CGContextSaveGState(cx);
    CGRect shadowFrame = contentFrame;

    // We want the shadow to clip to the top and bottom edges of the image so that when two cells
    // are next to each other their shadows line up perfectly.
    if (!first) {
      shadowFrame = NIRectShift(shadowFrame, 0, -self.borderRadius);
    }
    if (!last) {
      shadowFrame = NIRectContract(shadowFrame, 0, -self.borderRadius);
    }

    [self _applyPathToContext:cx rect:shadowFrame isFirst:first isLast:last];

    CGContextSetShadowWithColor(cx, self.shadowOffset, self.shadowWidth, self.shadowColor.CGColor);
    CGContextDrawPath(cx, kCGPathFill);
    CGContextRestoreGState(cx);
  }

  CGContextSaveGState(cx);
  [self _applyPathToContext:cx rect:contentFrame isFirst:first isLast:last];
  CGContextFillPath(cx);
  CGContextRestoreGState(cx);

  // We want the cell border to overlap the shadow and the content.
  CGFloat minPixelOffset = [[self class] minPixelOffset];
  CGRect borderFrame = CGRectInset(contentFrame, -minPixelOffset, -minPixelOffset);
  if (!highlighted) {
    // Draw the cell border.
    CGContextSaveGState(cx);
    CGContextSetLineWidth(cx, kBorderSize);
    CGContextSetStrokeColorWithColor(cx, self.borderColor.CGColor);
    if (first && last) {
      [self _applySinglePathToContext:cx rect:borderFrame];
      CGContextStrokePath(cx);

    } else if (first) {
      [self _applyTopPathToContext:cx rect:borderFrame];
      CGContextStrokePath(cx);

    } else if (last) {
      [self _applyBottomPathToContext:cx rect:borderFrame];
      CGContextStrokePath(cx);

    } else {
      [self _applyLeftPathToContext:cx rect:borderFrame];
      CGContextStrokePath(cx);

      [self _applyRightPathToContext:cx rect:borderFrame];
      CGContextStrokePath(cx);
    }
    CGContextRestoreGState(cx);
  }

  // Draw the cell divider.
  if (!last && drawDivider) {
    CGContextSaveGState(cx);
    CGContextSetLineWidth(cx, kBorderSize);
    CGContextSetStrokeColorWithColor(cx, self.dividerColor.CGColor);
    [self _applyDividerPathToContext:cx rect:NIRectContract(contentFrame, 0, 1)];
    CGContextStrokePath(cx);
    CGContextRestoreGState(cx);
  }

  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  CGFloat capWidth = floorf(image.size.width / 2);
  CGFloat capHeight = floorf(image.size.height / 2);
  return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, capWidth, capHeight, capWidth)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)_cacheKeyForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider {
  NSInteger flags = ((first ? 0x01 : 0)
                     | (last ? 0x02 : 0)
                     | (highlighted ? 0x04 : 0)
                     | (drawDivider ? 0x08 : 0));
  return [NSNumber numberWithInt:flags];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)_invalidateCache {
  [self.cachedImages removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger numberOfRowsInSection = [tableView.dataSource tableView:tableView numberOfRowsInSection:indexPath.section];
  BOOL isFirst = (0 == indexPath.row);
  BOOL isLast = (indexPath.row == numberOfRowsInSection - 1);
  BOOL drawDivider = YES;
  if ([cell conformsToProtocol:@protocol(NIGroupedCellAppearance)]
      && [cell respondsToSelector:@selector(drawsCellDivider)]) {
    id<NIGroupedCellAppearance> groupedCell = (id<NIGroupedCellAppearance>)cell;
    drawDivider = [groupedCell drawsCellDivider];
  }
  NSInteger backgroundTag = ((isFirst ? NIGroupedCellBackgroundFlagIsFirst : 0)
                             | (isLast ? NIGroupedCellBackgroundFlagIsLast : 0)
                             | NIGroupedCellBackgroundFlagInitialized
                             | (drawDivider ? 0 : NIGroupedCellBackgroundFlagNoDivider));
  if (cell.backgroundView.tag != backgroundTag) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[self imageForFirst:isFirst
                                                                            last:isLast
                                                                     highlighted:NO
                                                                     drawDivider:drawDivider]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[self imageForFirst:isFirst
                                                                                    last:isLast
                                                                             highlighted:YES
                                                                             drawDivider:drawDivider]];
    cell.backgroundView.tag = backgroundTag;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted {
  return [self imageForFirst:first last:last highlighted:highlighted drawDivider:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider {
  id cacheKey = [self _cacheKeyForFirst:first last:last highlighted:highlighted drawDivider:drawDivider];
  UIImage* image = [self.cachedImages objectForKey:cacheKey];
  if (nil == image) {
    image = [self _imageForFirst:first last:last highlighted:highlighted drawDivider:drawDivider];
    [self.cachedImages setObject:image forKey:cacheKey];
  }
  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setInnerBackgroundColor:(UIColor *)innerBackgroundColor {
  if (_innerBackgroundColor != innerBackgroundColor) {
    _innerBackgroundColor = innerBackgroundColor;
    [self _invalidateCache];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedInnerGradientColors:(NSMutableArray *)highlightedInnerGradientColors {
  if (_highlightedInnerGradientColors != highlightedInnerGradientColors) {
    _highlightedInnerGradientColors = highlightedInnerGradientColors;
    [self _invalidateCache];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShadowWidth:(CGFloat)shadowWidth {
  if (_shadowWidth != shadowWidth) {
    _shadowWidth = shadowWidth;
    [self _invalidateCache];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setShadowColor:(UIColor *)shadowColor {
  if (_shadowColor != shadowColor) {
    _shadowColor = shadowColor;
    [self _invalidateCache];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBorderColor:(UIColor *)borderColor {
  if (_borderColor != borderColor) {
    _borderColor = borderColor;
    [self _invalidateCache];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDividerColor:(UIColor *)dividerColor {
  if (_dividerColor != dividerColor) {
    _dividerColor = dividerColor;
    [self _invalidateCache];
  }
}

@end
