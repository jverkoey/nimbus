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
  if ([ruleSet hasTextColor]) { [self setTitleColor:ruleSet.textColor forState:UIControlStateNormal]; } else { [self setTitleColor:nil forState:UIControlStateNormal]; }
  if ([ruleSet hasTextShadowColor]) { [self setTitleShadowColor:ruleSet.textShadowColor forState:UIControlStateNormal]; } else { [self setTitleShadowColor:nil forState:UIControlStateNormal]; }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyViewStyleWithRuleSet:ruleSet];
  [self applyButtonStyleWithRuleSet:ruleSet];
}

@end
