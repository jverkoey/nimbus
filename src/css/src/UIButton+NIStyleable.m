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

#import "UIButton+NIStyleable.h"

#import "NIStylesheet.h"
#import "UIView+NIStyleable.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import "NIUserInterfaceString.h"
#import "NIDOM.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UIButton_NIStyleable)

// These chars are used as keys for objc_setAssociatedObject and objc_getAssociatedObject.
// We need to use associated objects to store DOMs so that we can apply
// styles for pseudoclasses (by refreshing each DOM) when the control state of the button changes.
// Since we're in a category, we can't add properties or ivars, so the only way to store additional
// state on the object is with associated objects.
static char nibutton_DOMArrayKey = 0;
static char nibutton_isRefreshingDueToKVOKey = 0;
static char nibutton_didSetupKVOKey = 0;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIButton (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyButtonStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyButtonStyleWithRuleSet:ruleSet inDOM:nil];
}

-(void)applyButtonStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
  if (ruleSet.hasFont) {
    self.titleLabel.font = ruleSet.font;
  }
  if (ruleSet.hasTextKey) {
    NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
    [nis attach:self withSelector:@selector(setTitle:forState:) forControlState:UIControlStateNormal];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyButtonStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  if ([ruleSet hasTextColor]) {
    // If you want to reset this color, set none as the color
    [self setTitleColor:ruleSet.textColor forState:UIControlStateNormal];
  }
  if ([ruleSet hasTextShadowColor]) {
    // If you want to reset this color, set none as the color
    [self setTitleShadowColor:ruleSet.textShadowColor forState:UIControlStateNormal];
  }
  if (ruleSet.hasImage) {
    UIImage *uiImage;
    if ([NIStylesheet resourceResolver] && [[NIStylesheet resourceResolver] respondsToSelector: @selector(imageNamed:)]) {
        uiImage = [[NIStylesheet resourceResolver] imageNamed:ruleSet.image];
    } else {
        uiImage = [UIImage imageNamed:ruleSet.image];
    }

    [self setImage:uiImage forState:UIControlStateNormal];
  }
  if (ruleSet.hasBackgroundImage) {
    UIImage *uiImage;
    if ([NIStylesheet resourceResolver] && [[NIStylesheet resourceResolver] respondsToSelector: @selector(imageNamed:)]) {
        uiImage = [[NIStylesheet resourceResolver] imageNamed:ruleSet.backgroundImage];
    } else {
        uiImage = [UIImage imageNamed:ruleSet.backgroundImage];
    }
    if (ruleSet.hasBackgroundStretchInsets) {
      uiImage = [uiImage resizableImageWithCapInsets:ruleSet.backgroundStretchInsets];
    }
    [self setBackgroundImage:uiImage forState:UIControlStateNormal];
  }
  if ([ruleSet hasTextShadowOffset]) {
    self.titleLabel.shadowOffset = ruleSet.textShadowOffset;
  }
  if ([ruleSet hasTitleInsets]) { self.titleEdgeInsets = ruleSet.titleInsets; }
  if ([ruleSet hasContentInsets]) { self.contentEdgeInsets = ruleSet.contentInsets; }
  if ([ruleSet hasImageInsets]) { self.imageEdgeInsets = ruleSet.imageInsets; }
  if ([ruleSet hasButtonAdjust]) {
    self.adjustsImageWhenDisabled = ((ruleSet.buttonAdjust & NICSSButtonAdjustDisabled) != 0);
    self.adjustsImageWhenHighlighted = ((ruleSet.buttonAdjust & NICSSButtonAdjustHighlighted) != 0);
  }
  if ([ruleSet hasLineBreakMode]) {
    self.titleLabel.lineBreakMode = ruleSet.lineBreakMode;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyButtonStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
  [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
  [self applyButtonStyleWithRuleSet:ruleSet inDOM:dom];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet forPseudoClass:(NSString *)pseudo inDOM:(NIDOM *)dom
{
  // This button now has at least one pseudoclass, which means it needs to refresh itself when its
  // control state changes.
  if (![objc_getAssociatedObject(self, &nibutton_didSetupKVOKey) boolValue]) {
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&nibutton_isRefreshingDueToKVOKey];
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&nibutton_isRefreshingDueToKVOKey];
    [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&nibutton_isRefreshingDueToKVOKey];
    objc_setAssociatedObject(self, &nibutton_didSetupKVOKey, @(YES), OBJC_ASSOCIATION_RETAIN);
  }
  
  UIControlState state = UIControlStateNormal;
  if ([pseudo caseInsensitiveCompare:@"selected"] == NSOrderedSame) {
    state = UIControlStateSelected;
  } else if ([pseudo caseInsensitiveCompare:@"highlighted"] == NSOrderedSame) {
    state = UIControlStateHighlighted;
  } else if ([pseudo caseInsensitiveCompare:@"disabled"] == NSOrderedSame) {
    state = UIControlStateDisabled;
  }
  
  if (self.state == state ||
      (!self.enabled && [pseudo caseInsensitiveCompare:@"disabled"] == NSOrderedSame)) {
    [self applyStyleWithRuleSet:ruleSet inDOM:dom];
  }
  
  return;
}

- (void)stopKVO
{
  if ([objc_getAssociatedObject(self, &nibutton_didSetupKVOKey) boolValue]) {
    [self removeObserver:self forKeyPath:@"highlighted" context:&nibutton_isRefreshingDueToKVOKey];
    [self removeObserver:self forKeyPath:@"selected" context:&nibutton_isRefreshingDueToKVOKey];
    [self removeObserver:self forKeyPath:@"enabled" context:&nibutton_isRefreshingDueToKVOKey];
    objc_setAssociatedObject(self, &nibutton_didSetupKVOKey, @(NO), OBJC_ASSOCIATION_RETAIN);
  }
}

-(NSArray *)pseudoClasses
{
  static dispatch_once_t onceToken;
  static NSArray *buttonPseudos;
  dispatch_once(&onceToken, ^{
    buttonPseudos = @[@":selected", @":highlighted", @":disabled"];
  });
  return buttonPseudos;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)autoSize:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  CGFloat newWidth = self.frameWidth, newHeight = self.frameHeight;
  
  if (ruleSet.hasWidth && ruleSet.width.type == CSS_AUTO_UNIT) {
    
    CGSize size = [[self titleForState:UIControlStateNormal]
                   sizeWithFont:self.titleLabel.font
                   constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)];
    newWidth = ceilf(size.width);
  }
  
  if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
    CGSize sizeForOneLine = [@"." sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    float heightForOneLine = sizeForOneLine.height;
    
    CGSize size = [[self titleForState:UIControlStateNormal]
                   sizeWithFont: self.titleLabel.font
                   constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    float maxHeight = (self.titleLabel.numberOfLines == 0) ? CGFLOAT_MAX : (heightForOneLine * self.titleLabel.numberOfLines);
    
    if (size.height > maxHeight) {
      size.height = maxHeight;
    }
    newHeight = ceilf(size.height);
  }
  
  self.frame = CGRectMake(self.frame.origin.x,
                          self.frame.origin.y,
                          newWidth,
                          newHeight);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRegisterInDOM:(NIDOM *)dom {
  NSMutableArray *array = objc_getAssociatedObject(self, &nibutton_DOMArrayKey);
  if (!array) {
    array = NICreateNonRetainingMutableArray();
    objc_setAssociatedObject(self, &nibutton_DOMArrayKey, array, OBJC_ASSOCIATION_RETAIN);
  }
  [array addObject:dom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didUnregisterInDOM:(NIDOM *)dom {
  NSMutableArray *array = objc_getAssociatedObject(self, &nibutton_DOMArrayKey);
  [array removeObject:dom];
  if (!array.count) {
    [self stopKVO];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (![objc_getAssociatedObject(self, &nibutton_isRefreshingDueToKVOKey) boolValue] &&
      [change objectForKey:NSKeyValueChangeNewKey] != [change objectForKey:NSKeyValueChangeOldKey]) {
    
    objc_setAssociatedObject(self, &nibutton_isRefreshingDueToKVOKey, @(YES), OBJC_ASSOCIATION_RETAIN);
    for (NIDOM *dom in objc_getAssociatedObject(self, &nibutton_DOMArrayKey)) {
      [dom refreshView:self];
    }
    objc_setAssociatedObject(self, &nibutton_isRefreshingDueToKVOKey, @(NO), OBJC_ASSOCIATION_RETAIN);
    
  }
}

@end

