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

#import "UIView+NIStyleable.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import "NIUserInterfaceString.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UIButton_NIStyleable)

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
    [self setImage:[UIImage imageNamed:ruleSet.image] forState:UIControlStateNormal];
  }
  if (ruleSet.hasBackgroundImage) {
    UIImage *backImage = [UIImage imageNamed:ruleSet.backgroundImage];
    if (ruleSet.hasBackgroundStretchInsets) {
      backImage = [backImage resizableImageWithCapInsets:ruleSet.backgroundStretchInsets];
    }
    [self setBackgroundImage:backImage forState:UIControlStateNormal];
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
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyStyleWithRuleSet:ruleSet inDOM:nil];
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
  UIControlState state = UIControlStateNormal;
  if ([pseudo caseInsensitiveCompare:@"selected"] == NSOrderedSame) {
    state = UIControlStateSelected;
  } else if ([pseudo caseInsensitiveCompare:@"highlighted"] == NSOrderedSame) {
    state = UIControlStateHighlighted;
  } else if ([pseudo caseInsensitiveCompare:@"disabled"] == NSOrderedSame) {
    state = UIControlStateDisabled;
  }
  if (ruleSet.hasTextKey) {
      NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
      [nis attach:self withSelector:@selector(setTitle:forState:) forControlState:state];
  }
  if (ruleSet.hasTextColor) {
    [self setTitleColor:ruleSet.textColor forState:state];
  }
  if (ruleSet.hasTextShadowColor) {
    [self setTitleShadowColor:ruleSet.textShadowColor forState:state];
  }
  if (ruleSet.hasImage) {
    [self setImage:[UIImage imageNamed:ruleSet.image] forState:state];
  }
  if (ruleSet.hasBackgroundImage) {
    UIImage *backImage = [UIImage imageNamed:ruleSet.backgroundImage];
    if (ruleSet.hasBackgroundStretchInsets) {
      backImage = [backImage resizableImageWithCapInsets:ruleSet.backgroundStretchInsets];
    }
    [self setBackgroundImage:backImage forState:state];
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
@end
