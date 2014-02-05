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

#import "UIView+NIStyleable.h"

#import "NIDOM.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import "NIUserInterfaceString.h"
#import "NIInvocationMethods.h"
#import "NIStyleable.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NSString* const NICSSViewKey = @"view";
NSString* const NICSSViewIdKey = @"id";
NSString* const NICSSViewCssClassKey = @"cssClass";
NSString* const NICSSViewTextKey = @"text";
NSString* const NICSSViewTagKey = @"tag";
NSString* const NICSSViewTargetSelectorKey = @"selector";
NSString* const NICSSViewSubviewsKey = @"subviews";
NSString* const NICSSViewAccessibilityLabelKey = @"label";
NSString* const NICSSViewBackgroundColorKey = @"bg";
NSString* const NICSSViewHiddenKey = @"hidden";

/**
 * Private class for storing info during view creation
 */
@interface NIPrivateViewInfo : NSObject
@property (nonatomic,strong) NSMutableArray *cssClasses;
@property (nonatomic,strong) NSString *viewId;
@property (nonatomic,strong) UIView *view;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
// We split this up because we want to add all the subviews to the DOM in the order they were created
@interface UIView (NIStyleablePrivate)
-(void)_buildSubviews:(NSArray *)viewSpecs inDOM:(NIDOM *)dom withViewArray: (NSMutableArray*) subviews;
@end

NI_FIX_CATEGORY_BUG(UIView_NIStyleable)
NI_FIX_CATEGORY_BUG(UIView_NIStyleablePrivate)

CGFloat NICSSUnitToPixels(NICSSUnit unit, CGFloat container);

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIView (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyViewStyleWithRuleSet:ruleSet inDOM:nil];
}

-(NSString *)descriptionWithRuleSetForView:(NICSSRuleset *)ruleSet forPseudoClass:(NSString *)pseudo inDOM:(NIDOM *)dom withViewName:(NSString *)name
{
  return [self applyOrDescribe:NO ruleSet:ruleSet inDOM:dom withViewName:name];
}

-(NSString *)descriptionWithRuleSet:(NICSSRuleset *)ruleSet forPseudoClass:(NSString *)pseudo inDOM:(NIDOM *)dom withViewName:(NSString *)name
{
  return [self descriptionWithRuleSetForView:ruleSet forPseudoClass:pseudo inDOM:dom withViewName:name];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyOrDescribe:YES ruleSet:ruleSet inDOM:dom withViewName:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)applyOrDescribe: (BOOL) apply ruleSet: (NICSSRuleset*) ruleSet inDOM: (NIDOM*)dom withViewName: (NSString*) name {
  NSMutableString *desc = apply ? nil : [[NSMutableString alloc] init];
  //      [desc appendFormat:@"%@. = %f;\n"];
  if ([ruleSet hasBackgroundColor]) {
    if (apply) {
      self.backgroundColor = ruleSet.backgroundColor;
    } else {
      CGFloat r,g,b,a;
      [ruleSet.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
      [desc appendFormat:@"%@.backgroundColor = [UIColor colorWithRed: %f green: %f blue: %f alpha: %f];\n", name, r, g, b, a];
    }
  }
  if ([ruleSet hasAccessibilityTraits]) {
    if (apply) {
      self.accessibilityTraits = ruleSet.accessibilityTraits;
    } else {
      [desc appendFormat:@"%@.accessibilityTraits = (UIAccessibilityTraits) %@;", name, [NSNumber numberWithLongLong: ruleSet.accessibilityTraits]];
    }
  }
  if ([ruleSet hasClipsToBounds]) {
    if (apply) {
      self.clipsToBounds = ruleSet.clipsToBounds;
    } else {
      [desc appendFormat:@"%@.clipsToBounds = %@;", name, ruleSet.clipsToBounds ? @"YES":@"NO"];
    }
  }
  if ([ruleSet hasOpacity]) {
    if (apply) {
      self.alpha = ruleSet.opacity;
    } else {
      [desc appendFormat:@"%@.alpha = %f;", name, ruleSet.opacity];
    }
  }
  if ([ruleSet hasBorderRadius]) {
    if (apply) {
      self.layer.cornerRadius = ruleSet.borderRadius;
    } else {
      [desc appendFormat:@"%@.layer.cornerRadius = %f;\n", name, ruleSet.borderRadius];
    }
  }
  if ([ruleSet hasBorderWidth]) {
    if (apply) {
      self.layer.borderWidth = ruleSet.borderWidth;
    } else {
      [desc appendFormat:@"%@.layer.borderWidth = %f;\n", name, ruleSet.borderWidth];
    }
  }
  if ([ruleSet hasBorderColor]) {
    if (apply) {
      self.layer.borderColor = ruleSet.borderColor.CGColor;
    } else {
      CGFloat r,g,b,a;
      [ruleSet.borderColor getRed:&r green:&g blue:&b alpha:&a];
      [desc appendFormat:@"%@.layer.borderColor = [UIColor colorWithRed: %f green: %f blue: %f alpha: %f].CGColor;\n", name, r, g, b, a];
    }
  }
  if ([ruleSet hasAutoresizing]) {
    if (apply) {
      self.autoresizingMask = ruleSet.autoresizing;
    } else {
      [desc appendFormat:@"%@.autoresizingMask = (UIViewAutoresizing) %d;\n", name, ruleSet.autoresizing];
    }
  }
  if ([ruleSet hasVisible]) {
    if (apply) {
      self.hidden = !ruleSet.visible;
    } else {
      [desc appendFormat:@"%@.hidden = %@;\n", name, ruleSet.visible ? @"NO" : @"YES"];
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // View sizing
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Special case auto/auto height and width
  if ([ruleSet hasWidth] && [ruleSet hasHeight] &&
      ruleSet.width.type == CSS_AUTO_UNIT && ruleSet.height.type == CSS_AUTO_UNIT) {
    if (apply) {
      if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
        [((id<NIStyleable>)self) autoSize: ruleSet inDOM: dom];
      } else {
        [self sizeToFit];
      }
    } else {
      // We can't actually describe the autoSize bit because the point is to work w/o a ruleset/dom, so just say it...
      if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
        [desc appendString:@"// autoSize would have been called instead of sizeToFit\n"];
      }
      [desc appendFormat:@"[%@ sizeToFit];\n", name];
    }
    if (ruleSet.hasVerticalPadding) {
      NICSSUnit vPadding = ruleSet.verticalPadding;
      switch (vPadding.type) {
        case CSS_AUTO_UNIT:
          break;
        case CSS_PERCENTAGE_UNIT:
          if (apply) {
            self.frameHeight += roundf(self.frameHeight * vPadding.value);
          } else {
            [desc appendFormat:@"%@.frameHeight += roundf(%@.frameHeight * %f);", name, name, vPadding.value];
          }
          break;
        case CSS_PIXEL_UNIT:
          if (apply) {
            self.frameHeight += vPadding.value;
          } else {
            [desc appendFormat:@"%@.frameHeight += %f;", name, vPadding.value];
          }
          break;
      }
    }
    if (ruleSet.hasHorizontalPadding) {
      NICSSUnit hPadding = ruleSet.horizontalPadding;
      switch (hPadding.type) {
        case CSS_AUTO_UNIT:
          break;
        case CSS_PERCENTAGE_UNIT:
          if (apply) {
            self.frameWidth += roundf(self.frameWidth * hPadding.value);
          } else {
            [desc appendFormat:@"%@.frameWidth += roundf(%@.frameWidth * %f);", name, name, hPadding.value];
          }
          break;
        case CSS_PIXEL_UNIT:
          if (apply) {
            self.frameWidth += hPadding.value;
          } else {
            [desc appendFormat:@"%@.frameWidth += %f;", name, hPadding.value];
          }
          break;
      }
    }

  } else {
    if ([ruleSet hasWidth]) {
      NICSSUnit u = ruleSet.width;
      CGFloat startHeight = self.frameHeight;
      switch (u.type) {
        case CSS_AUTO_UNIT:
          if (apply) {
            if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
              [((id<NIStyleable>)self) autoSize:ruleSet inDOM:dom];
            } else {
              [self sizeToFit]; // sizeToFit the width, but retain height. Behavior somewhat undefined...
              self.frameHeight = startHeight;
            }
          } else {
            // We can't actually describe the autoSize bit because the point is to work w/o a ruleset/dom, so just say it...
            if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
              [desc appendString:@"// autoSize would have been called instead of sizeToFit\n"];
            }
            [desc appendFormat:@"[%@ sizeToFit];\n%@.frameHeight = %f;\n", name, name, startHeight];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
          if (apply) {
            self.frameWidth = roundf(self.superview.bounds.size.width * u.value);
          } else {
            [desc appendFormat:@"%@.frameWidth = %f;\n", name, roundf(self.superview.bounds.size.width * u.value)];
          }
          break;
        case CSS_PIXEL_UNIT:
          // Because padding and margin are (a) complicated to implement and (b) not relevant in a non-flow layout,
          // we use negative width values to mean "the superview dimension - the value." It's a little hokey, but
          // it's very useful. If someone wants to layer on padding primitives to deal with this in a more CSSy way,
          // go for it.
          if (u.value < 0) {
            if (apply) {
              self.frameWidth = self.superview.frameWidth + u.value;
            } else {
              [desc appendFormat:@"%@.frameWidth = %f;\n", name, self.superview.frameWidth + u.value];
            }
          } else {
            if (apply) {
              self.frameWidth = u.value;
            } else {
              [desc appendFormat:@"%@.frameWidth = %f;\n", name, u.value];
            }
          }
          break;
      }
      if (ruleSet.hasHorizontalPadding) {
        NICSSUnit hPadding = ruleSet.horizontalPadding;
        switch (hPadding.type) {
          case CSS_AUTO_UNIT:
            break;
          case CSS_PERCENTAGE_UNIT:
            if (apply) {
              self.frameWidth += roundf(self.frameWidth * hPadding.value);
            } else {
              [desc appendFormat:@"%@.frameWidth += roundf(%@.frameWidth * %f);", name, name, hPadding.value];
            }
            break;
          case CSS_PIXEL_UNIT:
            if (apply) {
              self.frameWidth += hPadding.value;
            } else {
              [desc appendFormat:@"%@.frameWidth += %f;", name, hPadding.value];
            }
            break;
        }
      }
    }
    if ([ruleSet hasHeight]) {
      NICSSUnit u = ruleSet.height;
      CGFloat startWidth = self.frameWidth;
      switch (u.type) {
        case CSS_AUTO_UNIT:
          if (apply) {
            if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
              [((id<NIStyleable>)self) autoSize:ruleSet inDOM:dom];
            } else {
              [self sizeToFit];
              self.frameWidth = startWidth;
            }
          } else {
            // We can't actually describe the autoSize bit because the point is to work w/o a ruleset/dom, so just say it...
            if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
              [desc appendString:@"// autoSize would have been called instead of sizeToFit\n"];
            }
            [desc appendFormat:@"[%@ sizeToFit];\n%@.frameWidth = %f;\n", name, name, startWidth];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
          if (apply) {
            self.frameHeight = roundf(self.superview.bounds.size.height * u.value);
          } else {
            [desc appendFormat:@"%@.frameHeight = %f;\n", name, roundf(self.superview.bounds.size.height * u.value)];
          }
          break;
        case CSS_PIXEL_UNIT:
          // Because padding and margin are (a) complicated to implement and (b) not relevant in a non-flow layout,
          // we use negative width values to mean "the superview dimension - the value." It's a little hokey, but
          // it's very useful. If someone wants to layer on padding primitives to deal with this in a more CSSy way,
          // go for it.
          if (u.value < 0) {
            if (apply) {
              self.frameHeight = self.superview.frameHeight + u.value;
            } else {
              [desc appendFormat:@"%@.frameHeight = %f;\n", name, self.superview.frameHeight + u.value];
            }
          } else {
            if (apply) {
              self.frameHeight = u.value;
            } else {
              [desc appendFormat:@"%@.frameHeight = %f;\n", name, u.value];
            }
          }
          break;
      }
      if (ruleSet.hasVerticalPadding) {
        NICSSUnit vPadding = ruleSet.verticalPadding;
        switch (vPadding.type) {
          case CSS_AUTO_UNIT:
            break;
          case CSS_PERCENTAGE_UNIT:
            if (apply) {
              self.frameHeight += roundf(self.frameHeight * vPadding.value);
            } else {
              [desc appendFormat:@"%@.frameHeight += roundf(%@.frameHeight * %f);", name, name, vPadding.value];
            }
            break;
          case CSS_PIXEL_UNIT:
            if (apply) {
              self.frameHeight += vPadding.value;
            } else {
              [desc appendFormat:@"%@.frameHeight += %f;", name, vPadding.value];
            }
            break;
        }
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Left
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasLeft]) {
    NICSSUnit u = ruleSet.left;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
      case CSS_PIXEL_UNIT:
        if (apply) {
          self.frameMinX = NICSSUnitToPixels(u, self.superview.frameWidth);
        } else {
          [desc appendFormat:@"%@.frameMinX = %f;\n", name, NICSSUnitToPixels(u, self.superview.frameWidth)];
        }
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if (ruleSet.hasRightOf) {
    CGPoint anchor;
    NICSSRelativeSpec *rightOf = ruleSet.rightOf;
    UIView *relative = [self relativeViewFromViewSpec:rightOf.viewSpec inDom:dom];
    if (relative) {
      [dom ensureViewHasBeenRefreshed:relative];
      switch (rightOf.margin.type) {
        case CSS_AUTO_UNIT:
          // Align x center
          anchor = CGPointMake(roundf(relative.frameMidX), 0);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMidX = anchor.x;
          } else {
            [desc appendFormat:@"%@.frameMidX = %f;\n", name, anchor.x];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
        case CSS_PIXEL_UNIT:
          // relative.frameMinX - (relative.frameHeight * unit)
          anchor = CGPointMake(relative.frameMaxX, 0);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMinX = anchor.x + NICSSUnitToPixels(rightOf.margin, relative.frameWidth);
          } else {
            [desc appendFormat:@"%@.frameMinX = %f;\n", name, anchor.x + NICSSUnitToPixels(rightOf.margin, relative.frameWidth)];
            
          }
          break;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Right
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasRight]) {
    NICSSUnit u = ruleSet.right;
    CGFloat newMaxX = self.superview.frameWidth - NICSSUnitToPixels(u, self.superview.frameWidth);
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
      case CSS_PIXEL_UNIT:
        if (ruleSet.hasLeft || ruleSet.hasRightOf) {
          // If this ruleset specifies the left position of this view, then we set the right position
          // while maintaining that left position (by modifying the frame width).
          if (apply) {
            self.frameWidth = newMaxX - self.frameMinX;
            // We just modified the width of the view. The auto-height of the view might depend on its width
            // (i.e. a multi-line label), so we need to recalculate the height if it was auto.
            CGFloat startWidth = self.frameWidth;
            if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
              if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
                [((id<NIStyleable>)self) autoSize:ruleSet inDOM:dom];
              } else {
                [self sizeToFit];
                self.frameWidth = startWidth;
              }
            }
            // ...and now we've just modified the height, so we need to re-set the vertical padding
            if (ruleSet.hasVerticalPadding) {
              NICSSUnit vPadding = ruleSet.verticalPadding;
              switch (vPadding.type) {
                case CSS_AUTO_UNIT:
                  break;
                case CSS_PERCENTAGE_UNIT:
                  if (apply) {
                    self.frameHeight += roundf(self.frameHeight * vPadding.value);
                  } else {
                    [desc appendFormat:@"%@.frameHeight += roundf(%@.frameHeight * %f);", name, name, vPadding.value];
                  }
                  break;
                case CSS_PIXEL_UNIT:
                  if (apply) {
                    self.frameHeight += vPadding.value;
                  } else {
                    [desc appendFormat:@"%@.frameHeight += %f;", name, vPadding.value];
                  }
                  break;
              }
            }
          } else {
            [desc appendFormat:@"%@.frameWidth = %f;\n", name, newMaxX - self.frameMinX];
            if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
              if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
                [desc appendString:@"// autoSize would have been called instead of sizeToFit\n"];
              }
              [desc appendFormat:@"[%@ sizeToFit];\n%@.frameWidth = %f;\n", name, name, newMaxX - self.frameMinX];
            }
          }
        } else {
          // Otherwise, just set the right position normally
          if (apply) {
            self.frameMaxX = newMaxX;
          } else {
            [desc appendFormat:@"%@.frameMaxX = %f;\n", name, newMaxX];
          }
        }
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if (ruleSet.hasLeftOf) {
    CGPoint anchor;
    NICSSRelativeSpec *leftOf = ruleSet.leftOf;
    UIView *relative = [self relativeViewFromViewSpec:leftOf.viewSpec inDom:dom];
    if (relative) {
      [dom ensureViewHasBeenRefreshed:relative];
      switch (leftOf.margin.type) {
        case CSS_AUTO_UNIT:
          // Align x center
          anchor = CGPointMake(roundf(relative.frameMidX), 0);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMidX = anchor.x;
          } else {
            [desc appendFormat:@"%@.frameMidX = %f;\n", name, anchor.x];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
        case CSS_PIXEL_UNIT:
          anchor = CGPointMake(relative.frameMinX, 0);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (ruleSet.hasLeft || ruleSet.hasRightOf) {
            // If this ruleset specifies the left position of this view, then we set the right position
            // while maintaining that left position (by modifying the frame width).
            if (apply) {
              self.frameWidth = anchor.x - NICSSUnitToPixels(leftOf.margin, relative.frameWidth) - self.frameMinX;
              // We just modified the width of the view. The auto-height of the view might depend on its width
              // (i.e. a multi-line label), so we need to recalculate the height if it was auto.
              CGFloat startWidth = self.frameWidth;
              if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
                if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
                  [((id<NIStyleable>)self) autoSize:ruleSet inDOM:dom];
                } else {
                  [self sizeToFit];
                  self.frameWidth = startWidth;
                }
              }
              // ...and now we've just modified the height, so we need to re-set the vertical padding
              if (ruleSet.hasVerticalPadding) {
                NICSSUnit vPadding = ruleSet.verticalPadding;
                switch (vPadding.type) {
                  case CSS_AUTO_UNIT:
                    break;
                  case CSS_PERCENTAGE_UNIT:
                    if (apply) {
                      self.frameHeight += roundf(self.frameHeight * vPadding.value);
                    } else {
                      [desc appendFormat:@"%@.frameHeight += roundf(%@.frameHeight * %f);", name, name, vPadding.value];
                    }
                    break;
                  case CSS_PIXEL_UNIT:
                    if (apply) {
                      self.frameHeight += vPadding.value;
                    } else {
                      [desc appendFormat:@"%@.frameHeight += %f;", name, vPadding.value];
                    }
                    break;
                }
              }
            } else {
              [desc appendFormat:@"%@.frameWidth = %f;\n", name, anchor.x - NICSSUnitToPixels(leftOf.margin, relative.frameWidth) - self.frameMinX];
              if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
                if ([self respondsToSelector:@selector(autoSize:inDOM:)]) {
                  [desc appendString:@"// autoSize would have been called instead of sizeToFit\n"];
                }
                [desc appendFormat:@"[%@ sizeToFit];\n%@.frameWidth = %f;\n", name, name, anchor.x - NICSSUnitToPixels(leftOf.margin, relative.frameWidth) - self.frameMinX];
              }
            }
          } else {
            // Otherwise, just set the right position normally
            if (apply) {
              self.frameMaxX = anchor.x - NICSSUnitToPixels(leftOf.margin, relative.frameWidth);
            } else {
              [desc appendFormat:@"%@.frameMaxX = %f;\n", name, anchor.x - NICSSUnitToPixels(leftOf.margin, relative.frameWidth)];
            }
          }
          break;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Horizontal Align
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasFrameHorizontalAlign]) {
    switch (ruleSet.frameHorizontalAlign) {
      case UITextAlignmentCenter:
        if (apply) {
          self.frameMidX = roundf(self.superview.bounds.size.width / 2.0);
        } else {
          [desc appendFormat:@"%@.frameMidX = %f;\n", name, roundf(self.superview.bounds.size.width / 2.0)];
        }
        break;
      case UITextAlignmentLeft:
        if (apply) {
          self.frameMinX = 0;
        } else {
          [desc appendFormat:@"%@.frameMinX = 0;\n", name];
        }
        break;
      case UITextAlignmentRight:
        self.frameMaxX = self.superview.bounds.size.width;
        break;
      default:
        NIDASSERT(NO);
        break;
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Top
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasTop]) {
    NICSSUnit u = ruleSet.top;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
      case CSS_PIXEL_UNIT:
        if (apply) {
          self.frameMinY = NICSSUnitToPixels(u, self.superview.frameHeight);
        } else {
          [desc appendFormat:@"%@.frameMinY = %f;\n", name, NICSSUnitToPixels(u, self.superview.frameHeight)];
        }
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if (ruleSet.hasBelow) {
    CGPoint anchor;
    NICSSRelativeSpec *below = ruleSet.below;
    UIView *relative = [self relativeViewFromViewSpec:below.viewSpec inDom:dom];
    if (relative) {
      [dom ensureViewHasBeenRefreshed:relative];
      switch (below .margin.type) {
        case CSS_AUTO_UNIT:
          // Align y center
          anchor = CGPointMake(0, roundf(relative.frameMidY));
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMidY = anchor.y;
          } else {
            [desc appendFormat:@"%@.frameMidY = %f;\n", name, anchor.y];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
        case CSS_PIXEL_UNIT:
          anchor = CGPointMake(0, relative.frameMaxY);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMinY = anchor.y + NICSSUnitToPixels(below.margin, relative.frameHeight);
          } else {
            [desc appendFormat:@"%@.frameMinY = %f;\n", name, anchor.y + NICSSUnitToPixels(below.margin, relative.frameWidth)];
            
          }
          break;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Bottom
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasBottom]) {
    NICSSUnit u = ruleSet.bottom;
    CGFloat newBottom = self.superview.frameHeight - NICSSUnitToPixels(u, self.superview.frameHeight);
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
      case CSS_PIXEL_UNIT:
        if (ruleSet.hasTop || ruleSet.hasBelow) {
          // If this ruleset specifies the top position of this view, then we set the bottom position
          // while maintaining that top position (by modifying the frame height).
          if (apply) {
            self.frameHeight = newBottom - self.frameMinY;
          } else {
            [desc appendFormat:@"%@.frameHeight = %f;\n", name, newBottom - self.frameMinY];
          }
        } else {
          // Otherwise, just set the bottom normally
          if (apply) {
            self.frameMaxY = newBottom;
          } else {
            [desc appendFormat:@"%@.frameMaxY = %f;\n", name, newBottom];
          }
        }
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if (ruleSet.hasAbove) {
    CGPoint anchor;
    NICSSRelativeSpec *above = ruleSet.above;
    UIView *relative = [self relativeViewFromViewSpec:above.viewSpec inDom:dom];
    if (relative) {
      [dom ensureViewHasBeenRefreshed:relative];
      switch (above.margin.type) {
        case CSS_AUTO_UNIT:
          // Align x center
          anchor = CGPointMake(roundf(relative.frameMidX), 0);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (apply) {
            self.frameMidX = anchor.x;
          } else {
            [desc appendFormat:@"%@.frameMidX = %f;\n", name, anchor.x];
          }
          break;
        case CSS_PERCENTAGE_UNIT:
        case CSS_PIXEL_UNIT:
          anchor = CGPointMake(0, relative.frameMinY);
          if (self.superview != relative.superview) {
            anchor = [self convertPoint:anchor fromView:relative.superview];
          }
          if (ruleSet.hasTop || ruleSet.hasBelow) {
            // If this ruleset specifies the top position of this view, then we set the bottom position
            // while maintaining that top position (by modifying the frame height).
            if (apply) {
              self.frameHeight = anchor.y - NICSSUnitToPixels(above.margin, relative.frameHeight) - self.frameMinY;
            } else {
              [desc appendFormat:@"%@.frameHeight = %f;\n", name, anchor.y - NICSSUnitToPixels(above.margin, relative.frameHeight) - self.frameMinY];
            }
          } else {
            // Otherwise, just set the bottom position normally
            if (apply) {
              self.frameMaxY = anchor.y - NICSSUnitToPixels(above.margin, relative.frameHeight);
            } else {
              [desc appendFormat:@"%@.frameMaxY = %f;\n", name, anchor.y - NICSSUnitToPixels(above.margin, relative.frameHeight)];
            }
          }
          break;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Vertical Align
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasFrameVerticalAlign]) {
    switch (ruleSet.frameVerticalAlign) {
      case UIViewContentModeCenter:
        if (apply) {
          self.frameMidY = roundf(self.superview.bounds.size.height / 2.0);
        } else {
          [desc appendFormat:@"%@.frameMidY = %f;\n", name, roundf(self.superview.bounds.size.height / 2.0)];
        }
        break;
      case UIViewContentModeTop:
        if (apply) {
          self.frameMinY = 0;
        } else {
          [desc appendFormat:@"%@.frameMinY = 0;\n", name];
        }
        break;
      case UIViewContentModeBottom:
        if (apply) {
          self.frameMaxY = self.superview.bounds.size.height;
        } else {
          [desc appendFormat:@"%@.frameMaxY = %f;\n", name, self.superview.bounds.size.height];
        }
        break;
      default:
        NIDASSERT(NO);
        break;
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Min/Max width/height enforcement
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasMaxWidth]) {
    CGFloat max = NICSSUnitToPixels(ruleSet.maxWidth,self.frameWidth);
    if (self.frameWidth > max) {
      if (apply) {
        self.frameWidth = max;
      } else {
        [desc appendFormat:@"%@.frameWidth = %f;\n", name, max];
      }
    }
  }
  if ([ruleSet hasMaxHeight]) {
    CGFloat max = NICSSUnitToPixels(ruleSet.maxHeight,self.frameHeight);
    if (self.frameHeight > max) {
      if (apply) {
        self.frameHeight = max;
      } else {
        [desc appendFormat:@"%@.frameHeight = %f;\n", name, max];
      }
    }
  }
  if ([ruleSet hasMinWidth]) {
    CGFloat min = NICSSUnitToPixels(ruleSet.minWidth,self.frameWidth);
    if (self.frameWidth < min) {
      if (apply) {
        self.frameWidth = min;
      } else {
        [desc appendFormat:@"%@.frameWidth = %f;\n", name, min];
      }
    }
  }
  if ([ruleSet hasMinHeight]) {
    CGFloat min = NICSSUnitToPixels(ruleSet.minHeight,self.frameHeight);
    if (self.frameHeight < min) {
      if (apply) {
        self.frameHeight = min;
      } else {
        [desc appendFormat:@"%@.frameHeight = %f;\n", name, min];
      }
    }
  }
 
  return desc;
}

- (UIView *)relativeViewFromViewSpec:(NSString *)viewSpec inDom:(NIDOM *)dom
{
    UIView* relative = nil;
    if ([viewSpec characterAtIndex:0] == '\\') {
        if ([viewSpec caseInsensitiveCompare:@"\\next"] == NSOrderedSame) {
            NSInteger ix = [self.superview.subviews indexOfObject:self];
            if (++ix < self.superview.subviews.count) {
                relative = [self.superview.subviews objectAtIndex:ix];
            }
        } else if ([viewSpec caseInsensitiveCompare:@"\\prev"] == NSOrderedSame) {
            NSInteger ix = [self.superview.subviews indexOfObject:self];
            if (ix > 0) {
                relative = [self.superview.subviews objectAtIndex:ix-1];
            }
        } else if ([viewSpec caseInsensitiveCompare:@"\\first"] == NSOrderedSame) {
            relative = [self.superview.subviews objectAtIndex:0];
            if (relative == self) { relative = nil; }
        } else if ([viewSpec caseInsensitiveCompare:@"\\last"] == NSOrderedSame) {
            relative = [self.superview.subviews lastObject];
            if (relative == self) { relative = nil; }
        }
    } else {
        relative = [dom viewById:viewSpec];
    }
    return relative;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray *)buildSubviews:(NSArray *)viewSpecs inDOM:(NIDOM *)dom
{
  NSMutableArray *subviews = [[NSMutableArray alloc] init];
  [self _buildSubviews:viewSpecs inDOM:dom withViewArray:subviews];
  
  for (int ix = 0, ct = subviews.count; ix < ct; ix++) {
    NIPrivateViewInfo *viewInfo = [subviews objectAtIndex:ix];
    NSString *firstClass = [viewInfo.cssClasses count] ? [viewInfo.cssClasses objectAtIndex:0] : nil;
    [dom registerView:viewInfo.view withCSSClass:firstClass andId:viewInfo.viewId];
    if (viewInfo.viewId && dom.target) {
      // This sets the property on a container corresponding to the id of a contained view
      NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[viewInfo.viewId substringWithRange:NSMakeRange(1, 1)] uppercaseString], [viewInfo.viewId substringFromIndex:2]];
      SEL selector = NSSelectorFromString(selectorName);
      if ([dom.target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [dom.target performSelector:selector withObject:viewInfo.view];
#pragma clang diagnostic pop
      }
    }
    if (viewInfo.cssClasses.count > 1) {
      for (int i = 1, cct = viewInfo.cssClasses.count; i < cct; i++) {
        [dom addCssClass:[viewInfo.cssClasses objectAtIndex:i] toView:viewInfo.view];
      }
    }
    [subviews replaceObjectAtIndex:ix withObject:viewInfo.view];
  }
  return subviews;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
}

- (CGFloat)frameWidth
{
	return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)frameWidth
{
	CGRect frame = self.frame;
	frame.size.width = frameWidth;
  
	self.frame = frame;
}

- (CGFloat)frameHeight
{
	return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)frameHeight
{
	CGRect frame = self.frame;
	frame.size.height = frameHeight;
  
	self.frame = frame;
}

- (CGFloat)frameMinX
{
	return CGRectGetMinX(self.frame);
}

- (void)setFrameMinX:(CGFloat)frameMinX
{
	CGRect frame = self.frame;
	frame.origin.x = frameMinX;
  
	self.frame = frame;
}

- (CGFloat)frameMidX
{
	return CGRectGetMidX(self.frame);
}

- (void)setFrameMidX:(CGFloat)frameMidX
{
	self.frameMinX = (frameMidX - (self.frameWidth / 2.0f));
}

- (CGFloat)frameMaxX
{
	return CGRectGetMaxX(self.frame);
}

- (void)setFrameMaxX:(CGFloat)frameMaxX
{
	self.frameMinX = (frameMaxX - self.frameWidth);
}

- (CGFloat)frameMinY
{
	return CGRectGetMinY(self.frame);
}

- (void)setFrameMinY:(CGFloat)frameMinY
{
	CGRect frame = self.frame;
	frame.origin.y = frameMinY;
  
	self.frame = frame;
}

- (CGFloat)frameMidY
{
	return CGRectGetMidY(self.frame);
}

- (void)setFrameMidY:(CGFloat)frameMidY
{
	self.frameMinY = (frameMidY - (self.frameHeight / 2.0f));
}

- (CGFloat)frameMaxY
{
	return CGRectGetMaxY(self.frame);
}

- (void)setFrameMaxY:(CGFloat)frameMaxY
{
	self.frameMinY = (frameMaxY - self.frameHeight);
}

@end

CGFloat NICSSUnitToPixels(NICSSUnit unit, CGFloat container)
{
  if (unit.type == CSS_PERCENTAGE_UNIT) {
    return roundf(unit.value * container);
  }
  return unit.value;
}


@implementation UIView (NIStyleablePrivate)
-(void)_buildSubviews:(NSArray *)viewSpecs inDOM:(NIDOM *)dom withViewArray:(NSMutableArray *)subviews
{
  NIPrivateViewInfo *active = nil;
	for (id directive in viewSpecs) {
    
    if ([directive isKindOfClass:[NSDictionary class]]) {
      // Process the key value pairs rather than trying to determine intent
      // from the type of an array of random objects

      // We need a mutable copy so we can figure out if any custom values are left after we get ours out
      NSMutableDictionary *kv = [(NSDictionary*) directive mutableCopy];
      if (!active) {
        NSAssert([kv objectForKey:NICSSViewKey], @"The first NSDictionary passed to build subviews must contain the NICSSViewKey");
      }
      id directiveValue = [kv objectForKey:NICSSViewKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewKey];
#ifdef NI_DYNAMIC_VIEWS
        // Let's see if this is a UIView subclass. If NOT, let the normal string property handling take over
        if ([directiveValue isKindOfClass:[NSString class]]) {
          id classFromString = [[NSClassFromString(directiveValue) alloc] init];
          if (classFromString) {
            directiveValue = [[NSClassFromString(directiveValue) alloc] init];
          }
        }
        // See if we support this property and if so, pass it the dictionary itself (optionally the DOM). This allows extensions
        // of the parser for things like table rows. It's mainly in concert with the XML parser, otherwise the syntax would just be odd.
        if ([directiveValue isKindOfClass:[NSString class]]) {
          NSString *targetSelectorStr = [NSString stringWithFormat:@"set%@:inDOM:",directiveValue];
          SEL targetSelector = NSSelectorFromString(targetSelectorStr);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          if (targetSelector && [self respondsToSelector:targetSelector])
          {
            [self performSelector:targetSelector withObject:viewSpecs withObject:dom];
            return;
          }
#pragma clang diagnostic pop
          
          targetSelectorStr = [NSString stringWithFormat:@"set%@:",directiveValue];
          targetSelector = NSSelectorFromString(targetSelectorStr);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          if (targetSelector && [self respondsToSelector:targetSelector])
          {
            [self performSelector:targetSelector withObject:viewSpecs];
            return;
          }
#pragma clang diagnostic pop
        }
#endif
        if ([directiveValue isKindOfClass:[UIView class]]) {
          active = [[NIPrivateViewInfo alloc] init];
          active.view = (UIView*) directiveValue;
          if (self != active.view) {
            [self addSubview:active.view];
          }
          [subviews addObject: active];
        } else if (class_isMetaClass(object_getClass(directiveValue))) {
          active = [[NIPrivateViewInfo alloc] init];
          active.view = [[directive alloc] init];
          NSAssert([active.view isKindOfClass:[UIView class]], @"View must inherit from UIView. %@ does not.", NSStringFromClass([active class]));
          [self addSubview:active.view];
          [subviews addObject: active];
        } else {
          NSAssert(NO, @"NICSSViewKey directive does not identify a UIView or UIView class.");
        }
      }
      directiveValue = [kv objectForKey:NICSSViewIdKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewIdKey];
        NSAssert([directiveValue isKindOfClass:[NSString class]], @"The value of NICSSViewIdKey must be an NSString*");
        if (![directiveValue hasPrefix:@"#"]) {
          directiveValue = [@"#" stringByAppendingString:directiveValue];
        }
        active.viewId = directiveValue;
      }
      directiveValue = [kv objectForKey:NICSSViewCssClassKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewCssClassKey];
        NSAssert([directiveValue isKindOfClass:[NSString class]] || [directiveValue isKindOfClass:[NSArray class]], @"The value of NICSSViewCssClassKey must be an NSString* or NSArray*");
        active.cssClasses = active.cssClasses ?: [[NSMutableArray alloc] init];
        if ([directiveValue isKindOfClass:[NSString class]]) {
          if ([directiveValue rangeOfString:@" "].location != NSNotFound) {
            [active.cssClasses addObjectsFromArray:[directiveValue componentsSeparatedByString:@" "]];
          } else {
            [active.cssClasses addObject:directiveValue];
          }
        } else {
          [active.cssClasses addObjectsFromArray:directiveValue];
        }
      }
      directiveValue = [kv objectForKey:NICSSViewTextKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewTextKey];
        NSAssert([directiveValue isKindOfClass:[NSString class]] || [directiveValue isKindOfClass:[NIUserInterfaceString class]], @"The value of NICSSViewCssClassKey must be an NSString* or NIUserInterfaceString*");
        if ([directiveValue isKindOfClass:[NSString class]]) {
          directiveValue = [[NIUserInterfaceString alloc] initWithKey:directiveValue defaultValue:directiveValue];
        }
        if ([directiveValue isKindOfClass:[NIUserInterfaceString class]]) {
          [((NIUserInterfaceString*)directiveValue) attach:active.view];
        }
      }
      directiveValue = [kv objectForKey:NICSSViewBackgroundColorKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewBackgroundColorKey];
        NSAssert([directiveValue isKindOfClass:[UIColor class]] || [directiveValue isKindOfClass:[NSNumber class]] || [directiveValue isKindOfClass:[NSString class]], @"The value of NICSSViewBackgroundColorKey must be NSString*, NSNumber* or UIColor*");
        if ([directiveValue isKindOfClass:[NSNumber class]]) {
          long rgbValue = [directiveValue longValue];
          directiveValue = [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbValue & 0xFF0000) >> 16))/255.0 blue:((float)((rgbValue & 0xFF00) >> 8))/255.0 alpha:((float)(rgbValue & 0xFF))/255.0];
        } else if ([directiveValue isKindOfClass:[NSString class]]) {
          directiveValue = [NICSSRuleset colorFromString:directiveValue];
        }
        active.view.backgroundColor = directiveValue;
      }
      directiveValue = [kv objectForKey:NICSSViewHiddenKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewHiddenKey];
        NSAssert([directiveValue isKindOfClass:[NSNumber class]] || [directiveValue isKindOfClass:[NSString class]], @"The value of NICSSViewHiddenKey must be NSString* or NSNumber*");
        active.view.hidden = [directiveValue boolValue];
      }
      directiveValue = [kv objectForKey:NICSSViewTagKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewTagKey];
        NSAssert([directiveValue isKindOfClass:[NSNumber class]], @"The value of NICSSViewTagKey must be an NSNumber*");
        active.view.tag = [directiveValue integerValue];
      }
      directiveValue = [kv objectForKey:NICSSViewTargetSelectorKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewTargetSelectorKey];
        NSAssert([directiveValue isKindOfClass:[NSInvocation class]] || [directiveValue isKindOfClass:[NSString class]], @"NICSSViewTargetSelectorKey must be an NSInvocation*, or an NSString* if you're adventurous and NI_DYNAMIC_VIEWS is defined.");
        
#ifdef NI_DYNAMIC_VIEWS
        // NSSelectorFromString has Apple rejection written all over it, even though it's documented. Since its intended
        // use is primarily rapid development right now, use the #ifdef to turn it on.
        if ([directiveValue isKindOfClass:[NSString class]]) {
          // Let's make an invocation out of this puppy.
          @try {
            SEL selector = NSSelectorFromString(directiveValue);
            directiveValue = NIInvocationWithInstanceTarget(dom.target, selector);
          }
          @catch (NSException *exception) {
#ifdef DEBUG
            NIDPRINT(@"Unknown selector %@ specified on %@.", directiveValue, dom.target);
#endif
          }
        }
#endif
        
        if ([directiveValue isKindOfClass:[NSInvocation class]]) {
          NSInvocation *n = (NSInvocation*) directiveValue;
          if ([active.view respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
            [((id)active.view) addTarget: n.target action: n.selector forControlEvents: UIControlEventTouchUpInside];
          } else {
            NSString *error = [NSString stringWithFormat:@"Cannot apply NSInvocation to class %@", NSStringFromClass(active.class)];
            NSAssert(NO, error);
          }
        }
      }
      directiveValue = [kv objectForKey:NICSSViewSubviewsKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewSubviewsKey];
        NSAssert([directiveValue isKindOfClass: [NSArray class]], @"NICSSViewSubviewsKey must be an NSArray*");
        [active.view _buildSubviews:directiveValue inDOM:dom withViewArray:subviews];
      }
      
      directiveValue = [kv objectForKey:NICSSViewAccessibilityLabelKey];
      if (directiveValue) {
        [kv removeObjectForKey:NICSSViewAccessibilityLabelKey];
        NSAssert([directiveValue isKindOfClass:[NSString class]], @"NICSSViewAccessibilityLabelKey must be an NSString*");
        active.view.accessibilityLabel = directiveValue;
      }
      
      if (kv.count) {
        // The rest go to kv setters
        NISetValuesForKeys(active.view, kv, nil);
      }
      
      continue;
    }
    
    // This first element in a "segment" of the array must be a view or a class object that we will make into a view
    // You can do things like UIView.alloc.init, UIView.class, [[UIView alloc] init]...
    if ([directive isKindOfClass: [UIView class]]) {
      active = [[NIPrivateViewInfo alloc] init];
      active.view = (UIView*) directive;
      if (self != directive) {
        [self addSubview:active.view];
      }
      [subviews addObject: active];
      continue;
    } else if (class_isMetaClass(object_getClass(directive))) {
      active = [[NIPrivateViewInfo alloc] init];
      active.view = [[directive alloc] init];
      [self addSubview:active.view];
      [subviews addObject: active];
      continue;
    } else if (!active) {
      NSAssert(NO, @"UIView::buildSubviews expected UIView or Class to start a directive.");
      continue;
    }
    
    if ([directive isKindOfClass:[NIUserInterfaceString class]]) {
      [((NIUserInterfaceString*)directive) attach:active.view];
    } else if ([directive isKindOfClass:[NSString class]]) {
      // Strings are either a cssClass or an accessibility label
      NSString *d = (NSString*) directive;
      if ([d hasPrefix:@"."]) {
        active.cssClasses = active.cssClasses ?: [[NSMutableArray alloc] init];
        [active.cssClasses addObject: [d substringFromIndex:1]];
      } else if ([d hasPrefix:@"#"]) {
        active.viewId = d;
      } else {
        active.view.accessibilityLabel = d;
      }
    } else if ([directive isKindOfClass:[NSNumber class]]) {
      // NSNumber means tag
      active.view.tag = [directive integerValue];
    } else if ([directive isKindOfClass:[NSArray class]]) {
      // NSArray means recursive call to build
      [active.view _buildSubviews:directive inDOM:dom withViewArray:subviews];
    } else if ([directive isKindOfClass:[UIColor class]]) {
      active.view.backgroundColor = directive;
    } else if ([directive isKindOfClass:[NSInvocation class]]) {
      NSInvocation *n = (NSInvocation*) directive;
      if ([active.view respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
        [((id)active.view) addTarget: n.target action: n.selector forControlEvents: UIControlEventTouchUpInside];
      } else {
        NSString *error = [NSString stringWithFormat:@"Cannot apply NSInvocation to class %@", NSStringFromClass(active.class)];
        NSAssert(NO, error);
      }
    } else {
      NSAssert(NO, @"Unknown directive in build specifier");
    }
  }
}

@end

@implementation NIPrivateViewInfo
@end


