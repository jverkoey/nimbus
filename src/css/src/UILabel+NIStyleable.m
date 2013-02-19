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

#import "UILabel+NIStyleable.h"

#import "UIView+NIStyleable.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import "NIUserInterfaceString.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UILabel_NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UILabel (NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyLabelStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyLabelStyleWithRuleSet:ruleSet inDOM:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyLabelStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  if ([ruleSet hasTextColor]) { self.textColor = ruleSet.textColor; }
  if ([ruleSet hasHighlightedTextColor]) { self.highlightedTextColor = ruleSet.highlightedTextColor; }
  if ([ruleSet hasTextAlignment]) { self.textAlignment = ruleSet.textAlignment; }
  if ([ruleSet hasFont]) { self.font = ruleSet.font; }
  if ([ruleSet hasTextShadowColor]) { self.shadowColor = ruleSet.textShadowColor; }
  if ([ruleSet hasTextShadowOffset]) { self.shadowOffset = ruleSet.textShadowOffset; }
  if ([ruleSet hasLineBreakMode]) { self.lineBreakMode = ruleSet.lineBreakMode; }
  if ([ruleSet hasNumberOfLines]) { self.numberOfLines = ruleSet.numberOfLines; }
  if ([ruleSet hasMinimumFontSize]) { self.minimumFontSize = ruleSet.minimumFontSize; }
  if ([ruleSet hasAdjustsFontSize]) { self.adjustsFontSizeToFitWidth = ruleSet.adjustsFontSize; }
  if ([ruleSet hasBaselineAdjustment]) { self.baselineAdjustment = ruleSet.baselineAdjustment; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyLabelStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
  if (ruleSet.hasTextKey) {
    NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
    [nis attach:self withSelector:@selector(setText:)];
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyStyleWithRuleSet:ruleSet inDOM:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyLabelStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
  [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
  [self applyLabelStyleWithRuleSet:ruleSet inDOM:dom];
}

@end
