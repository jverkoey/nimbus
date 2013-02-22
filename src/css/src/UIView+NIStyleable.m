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

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  if ([ruleSet hasBackgroundColor]) { self.backgroundColor = ruleSet.backgroundColor; }
  if ([ruleSet hasOpacity]) { self.alpha = ruleSet.opacity; }
  if ([ruleSet hasBorderRadius]) { self.layer.cornerRadius = ruleSet.borderRadius; }
  if ([ruleSet hasBorderWidth]) { self.layer.borderWidth = ruleSet.borderWidth; }
  if ([ruleSet hasBorderColor]) { self.layer.borderColor = ruleSet.borderColor.CGColor; }
  if ([ruleSet hasAutoresizing]) { self.autoresizingMask = ruleSet.autoresizing; }
  if ([ruleSet hasVisible]) { self.hidden = !ruleSet.visible; }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // View sizing
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Special case auto/auto height and width
  if ([ruleSet hasWidth] && [ruleSet hasHeight] &&
      ruleSet.width.type == CSS_AUTO_UNIT && ruleSet.height.type == CSS_AUTO_UNIT) {
    [self sizeToFit];
  } else {
    if ([ruleSet hasWidth]) {
      NICSSUnit u = ruleSet.width;
      CGFloat startHeight = self.frameHeight;
      switch (u.type) {
        case CSS_AUTO_UNIT:
          [self sizeToFit]; // sizeToFit the width, but retain height. Behavior somewhat undefined...
          self.frameHeight = startHeight;
          break;
        case CSS_PERCENTAGE_UNIT:
          self.frameWidth = self.superview.bounds.size.width * u.value;
          break;
        case CSS_PIXEL_UNIT:
          // Because padding and margin are (a) complicated to implement and (b) not relevant in a non-flow layout,
          // we use negative width values to mean "the superview dimension - the value." It's a little hokey, but
          // it's very useful. If someone wants to layer on padding primitives to deal with this in a more CSSy way,
          // go for it.
          if (u.value < 0) {
            self.frameWidth = self.superview.frameWidth + u.value;
          } else {
            self.frameWidth = u.value;
          }
          break;
      }
    }
    if ([ruleSet hasHeight]) {
      NICSSUnit u = ruleSet.height;
      CGFloat startWidth = self.frameWidth;
      switch (u.type) {
        case CSS_AUTO_UNIT:
          [self sizeToFit];
          self.frameWidth = startWidth;
          break;
        case CSS_PERCENTAGE_UNIT:
          self.frameHeight = self.superview.bounds.size.height * u.value;
          break;
        case CSS_PIXEL_UNIT:
          // Because padding and margin are (a) complicated to implement and (b) not relevant in a non-flow layout,
          // we use negative width values to mean "the superview dimension - the value." It's a little hokey, but
          // it's very useful. If someone wants to layer on padding primitives to deal with this in a more CSSy way,
          // go for it.
          if (u.value < 0) {
            self.frameHeight = self.superview.frameHeight + u.value;
          } else {
            self.frameHeight = u.value;
          }
          break;
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Min/Max width/height enforcement
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasMaxWidth]) {
    CGFloat max = NICSSUnitToPixels(ruleSet.maxWidth,self.frameWidth);
    if (self.frameWidth > max) { self.frameWidth = max; }
  }
  if ([ruleSet hasMaxHeight]) {
    CGFloat max = NICSSUnitToPixels(ruleSet.maxHeight,self.frameHeight);
    if (self.frameHeight > max) { self.frameHeight = max; }
  }
  if ([ruleSet hasMinWidth]) {
    CGFloat min = NICSSUnitToPixels(ruleSet.minWidth,self.frameWidth);
    if (self.frameWidth < min) { self.frameWidth = min; }
  }
  if ([ruleSet hasMinHeight]) {
    CGFloat min = NICSSUnitToPixels(ruleSet.minHeight,self.frameHeight);
    if (self.frameHeight < min) { self.frameHeight = min; }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // "Absolute" position in superview
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if ([ruleSet hasTop]) {
    NICSSUnit u = ruleSet.top;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
        self.frameMinY = self.superview.bounds.size.height * u.value;
        break;
      case CSS_PIXEL_UNIT:
        self.frameMinY = u.value;
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if ([ruleSet hasLeft]) {
    NICSSUnit u = ruleSet.left;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
        self.frameMinX = self.superview.bounds.size.width * u.value;
        break;
      case CSS_PIXEL_UNIT:
        self.frameMinX = u.value;
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  // TODO - should specifying both left/right or top/bottom set the width instead?
  if ([ruleSet hasRight]) {
    NICSSUnit u = ruleSet.right;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
        self.frameMaxX = self.superview.bounds.size.width * u.value;
        break;
      case CSS_PIXEL_UNIT:
        self.frameMaxX = self.superview.bounds.size.width - u.value;
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if ([ruleSet hasBottom]) {
    NICSSUnit u = ruleSet.bottom;
    switch (u.type) {
      case CSS_PERCENTAGE_UNIT:
        self.frameMaxY = self.superview.bounds.size.height * u.value;
        break;
      case CSS_PIXEL_UNIT:
        self.frameMaxY = self.superview.bounds.size.height - u.value;
        break;
      default:
        NIDASSERT(u.type == CSS_PERCENTAGE_UNIT || u.type == CSS_PIXEL_UNIT);
        break;
    }
  }
  if ([ruleSet hasFrameHorizontalAlign]) {
    switch (ruleSet.frameHorizontalAlign) {
      case UITextAlignmentCenter:
        self.frameMidX = self.superview.bounds.size.width / 2.0;
        break;
      case UITextAlignmentLeft:
        self.frameMinX = 0;
      case UITextAlignmentRight:
        self.frameMaxX = self.superview.bounds.size.width;
        break;
      default:
        NIDASSERT(NO);
        break;
    }
  }
  if ([ruleSet hasFrameVerticalAlign]) {
    switch (ruleSet.frameVerticalAlign) {
      case UIViewContentModeCenter:
        self.frameMidY = self.superview.bounds.size.height / 2.0;
        break;
      case UIViewContentModeTop:
        self.frameMinY = 0;
      case UIViewContentModeBottom:
        self.frameMaxY = self.superview.bounds.size.height;
        break;
      default:
        NIDASSERT(NO);
        break;
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  // Relative positioning to other identified views
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  if (ruleSet.hasRelativeToId) {
    NSString *viewSpec = ruleSet.relativeToId;
    UIView* relative = nil;
    if ([viewSpec characterAtIndex:0] == '.') {
      if ([viewSpec caseInsensitiveCompare:@".next"] == NSOrderedSame) {
        NSInteger ix = [self.superview.subviews indexOfObject:self];
        if (++ix < self.superview.subviews.count) {
          relative = [self.superview.subviews objectAtIndex:ix];
        }
      } else if ([viewSpec caseInsensitiveCompare:@".prev"] == NSOrderedSame) {
        NSInteger ix = [self.superview.subviews indexOfObject:self];
        if (ix > 0) {
          relative = [self.superview.subviews objectAtIndex:ix-1];
        }
      } else if ([viewSpec caseInsensitiveCompare:@".first"] == NSOrderedSame) {
        relative = [self.superview.subviews objectAtIndex:0];
        if (relative == self) { relative = nil; }
      } else if ([viewSpec caseInsensitiveCompare:@".last"] == NSOrderedSame) {
        relative = [self.superview.subviews lastObject];
        if (relative == self) { relative = nil; }
      }
    } else {
      // For performance, I'm not going to try and fix up your bad selectors. Start with a # or it will fail.
      relative = [dom viewById:ruleSet.relativeToId];
    }
    if (relative) {
      CGPoint anchor;
      
      if (ruleSet.hasMarginTop) {
        NICSSUnit top = ruleSet.marginTop;
        switch (top.type) {
          case CSS_AUTO_UNIT:
            // Align y center
            anchor = CGPointMake(0, relative.frameMidY);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMidY = anchor.y;
            break;
          case CSS_PERCENTAGE_UNIT:
          case CSS_PIXEL_UNIT:
            // relative.frameMaxY + relative.frameHeight * unit
            anchor = CGPointMake(0, relative.frameMaxY);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMinY = anchor.y + NICSSUnitToPixels(top, relative.frameHeight);
            break;
        }
      } else if (ruleSet.hasMarginBottom) {
        NICSSUnit bottom = ruleSet.marginBottom;
        switch (bottom.type) {
          case CSS_AUTO_UNIT:
            // Align y center
            anchor = CGPointMake(0, relative.frameMidY);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMidY = anchor.y;
            break;
          case CSS_PERCENTAGE_UNIT:
          case CSS_PIXEL_UNIT:
            // relative.frameMinY - (relative.frameHeight * unit)
            anchor = CGPointMake(0, relative.frameMinY);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMaxY = anchor.y - NICSSUnitToPixels(bottom, relative.frameHeight);
            break;
        }
      }
      
      if (ruleSet.hasMarginLeft) {
        NICSSUnit left = ruleSet.marginLeft;
        switch (left.type) {
          case CSS_AUTO_UNIT:
            // Align x center
            anchor = CGPointMake(relative.frameMidX, 0);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMidX = anchor.x;
            break;
          case CSS_PERCENTAGE_UNIT:
          case CSS_PIXEL_UNIT:
            // relative.frameMaxX + (relative.frameHeight * unit)
            anchor = CGPointMake(relative.frameMaxX, 0);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMinX = anchor.x + NICSSUnitToPixels(left, relative.frameWidth);
            break;
        }
      } else if (ruleSet.hasMarginRight) {
        NICSSUnit right = ruleSet.marginRight;
        switch (right.type) {
          case CSS_AUTO_UNIT:
            // Align x center
            anchor = CGPointMake(relative.frameMidX, 0);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMidX = anchor.x;
            break;
          case CSS_PERCENTAGE_UNIT:
          case CSS_PIXEL_UNIT:
            // relative.frameMinX - (relative.frameHeight * unit)
            anchor = CGPointMake(relative.frameMinX, 0);
            if (self.superview != relative.superview) {
              anchor = [self convertPoint:anchor fromView:relative.superview];
            }
            self.frameMaxX = anchor.x - NICSSUnitToPixels(right, relative.frameWidth);
            break;
        }
      }
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray *)buildSubviews:(NSArray *)viewSpecs inDOM:(NIDOM *)dom
{
    @try {
        NSMutableArray *subviews = [[NSMutableArray alloc] init];
        [self _buildSubviews:viewSpecs inDOM:dom withViewArray:subviews];
        
        for (int ix = 0, ct = subviews.count; ix < ct; ix++) {
            NIPrivateViewInfo *viewInfo = [subviews objectAtIndex:ix];
            NSString *firstClass = [viewInfo.cssClasses count] ? [viewInfo.cssClasses objectAtIndex:0] : nil;
            [dom registerView:viewInfo.view withCSSClass:firstClass andId:viewInfo.viewId];
            if (viewInfo.cssClasses.count > 1) {
                for (int i = 1, cct = viewInfo.cssClasses.count; i < cct; i++) {
                    [dom addCssClass:[viewInfo.cssClasses objectAtIndex:i] toView:viewInfo.view];
                }
            }
            [subviews replaceObjectAtIndex:ix withObject:viewInfo.view];
        }
        return subviews;
    }
    @catch (NSException *exception) {
        return nil;
    }
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
    return unit.value * container;
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
      // from the type
      NSDictionary *kv = (NSDictionary*) directive;
      if (!active) {
        NSAssert([kv objectForKey:NICSSViewKey], @"The first NSDictionary passed to build subviews must contain the NICSSViewKey");
      }
      id directiveValue = [kv objectForKey:NICSSViewKey];
      if (directiveValue) {
#ifdef NI_DYNAMIC_VIEWS
        // I have a dream that you can instantiate this whole thing from JSON.
        // So the dictionary version endeavors to make NSString/NSNumber work for every directive
        if ([directiveValue isKindOfClass:[NSString class]]) {
          directiveValue = [[NSClassFromString(directiveValue) alloc] init];
        }
#endif
        if ([directiveValue isKindOfClass:[UIView class]]) {
          active = [[NIPrivateViewInfo alloc] init];
          active.view = (UIView*) directiveValue;
          [self addSubview:active.view];
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
        NSAssert([directiveValue isKindOfClass:[NSString class]], @"The value of NICSSViewIdKey must be an NSString*");
        active.viewId = directiveValue;
      }
      directiveValue = [kv objectForKey:NICSSViewCssClassKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass:[NSString class]] || [directiveValue isKindOfClass:[NSArray class]], @"The value of NICSSViewCssClassKey must be an NSString* or NSArray*");
        active.cssClasses = active.cssClasses ?: [[NSMutableArray alloc] init];
        if ([directiveValue isKindOfClass:[NSString class]]) {
          [active.cssClasses addObject:directiveValue];
        } else {
          [active.cssClasses addObjectsFromArray:directiveValue];
        }
      }
      directiveValue = [kv objectForKey:NICSSViewTextKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass:[NSString class]] || [directiveValue isKindOfClass:[NIUserInterfaceString class]], @"The value of NICSSViewCssClassKey must be an NSString* or NIUserInterfaceString*");
        if ([directiveValue isKindOfClass:[NIUserInterfaceString class]]) {
          [((NIUserInterfaceString*)directive) attach:active.view];
        }
      }
      directiveValue = [kv objectForKey:NICSSViewTagKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass:[NSNumber class]], @"The value of NICSSViewTagKey must be an NSNumber*");
        active.view.tag = [directiveValue integerValue];
      }
      directiveValue = [kv objectForKey:NICSSViewTargetSelectorKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass:[NSInvocation class]] || [directiveValue isKindOfClass:[NSString class]], @"NICSSViewTargetSelectorKey must be an NSInvocation*, or an NSString* if you're adventurous and NI_DYNAMIC_VIEWS is defined.");

#ifdef NI_DYNAMIC_VIEWS
        // NSSelectorFromString has Apple rejection written all over it, even though it's documented. Since its intended
        // use is primarily rapid development right now, use the #ifdef to turn it on.
        if ([directiveValue isKindOfClass:[NSString class]]) {
          // Let's make an invocation out of this puppy.
          SEL selector = NSSelectorFromString(directiveValue);
          directiveValue = NIInvocationWithInstanceTarget(dom.target, selector);
        }
#endif

        NSInvocation *n = (NSInvocation*) directiveValue;
        if ([active.view respondsToSelector:@selector(addTarget:action:forControlEvents:)]) {
          [((id)active.view) addTarget: n.target action: n.selector forControlEvents: UIControlEventTouchUpInside];
        } else {
          NSString *error = [NSString stringWithFormat:@"Cannot apply NSInvocation to class %@", NSStringFromClass(active.class)];
          NSAssert(NO, error);
        }
      }
      directiveValue = [kv objectForKey:NICSSViewSubviewsKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass: [NSArray class]], @"NICSSViewSubviewsKey must be an NSArray*");
        [active.view _buildSubviews:directiveValue inDOM:dom withViewArray:subviews];
      } else if (directiveValue)
      directiveValue = [kv objectForKey:NICSSViewAccessibilityLabelKey];
      if (directiveValue) {
        NSAssert([directiveValue isKindOfClass:[NSString class]], @"NICSSViewAccessibilityLabelKey must be an NSString*");
        active.view.accessibilityLabel = directiveValue;
      }
      continue;
    }
    
    // This first element in a "segment" of the array must be a view or a class object that we will make into a view
    // You can do things like UIView.alloc.init, UIView.class, [[UIView alloc] init]...
    if ([directive isKindOfClass: [UIView class]]) {
      active = [[NIPrivateViewInfo alloc] init];
      active.view = (UIView*) directive;
      [self addSubview:active.view];
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


