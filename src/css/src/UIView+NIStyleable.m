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

#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import <QuartzCore/QuartzCore.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UIView_NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIView (NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  if ([ruleSet hasBackgroundColor]) { self.backgroundColor = ruleSet.backgroundColor; }
  if ([ruleSet hasOpacity]) { self.alpha = ruleSet.opacity; }
  if ([ruleSet hasBorderRadius]) { self.layer.cornerRadius = ruleSet.borderRadius; }
  if ([ruleSet hasBorderWidth]) { self.layer.borderWidth = ruleSet.borderWidth; }
  if ([ruleSet hasBorderColor]) { self.layer.borderColor = ruleSet.borderColor.CGColor; }
  if ([ruleSet hasAutoresizing]) { self.autoresizingMask = ruleSet.autoresizing; }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyViewStyleWithRuleSet:ruleSet];
}


@end
