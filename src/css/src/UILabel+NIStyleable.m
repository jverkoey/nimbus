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
#import "NICSSRuleSet.h"
#import "NimbusCore.h"

NI_FIX_CATEGORY_BUG(UILabel_NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UILabel (NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyLabelStyleWithRuleSet:(NICSSRuleSet *)ruleSet {
  if ([ruleSet hasTextColor]) { self.textColor = ruleSet.textColor; } else { self.textColor = nil; }
  if ([ruleSet hasTextAlignment]) { self.textAlignment = ruleSet.textAlignment; } else {self.textAlignment = UITextAlignmentLeft; }
  if ([ruleSet hasFont]) { self.font = ruleSet.font; } else { self.font = nil; }
  if ([ruleSet hasTextShadowColor]) { self.shadowColor = ruleSet.textShadowColor; } else { self.shadowColor = nil; }
  if ([ruleSet hasTextShadowOffset]) { self.shadowOffset = ruleSet.textShadowOffset; } else { self.shadowOffset = CGSizeZero; }
  if ([ruleSet hasLineBreakMode]) { self.lineBreakMode = ruleSet.lineBreakMode; } else { self.lineBreakMode = UILineBreakModeWordWrap; }
  if ([ruleSet hasNumberOfLines]) { self.numberOfLines = ruleSet.numberOfLines; } else { self.numberOfLines = 1; }
  if ([ruleSet hasMinimumFontSize]) { self.minimumFontSize = ruleSet.minimumFontSize; } else { self.minimumFontSize = 0; }
  if ([ruleSet hasAdjustsFontSize]) { self.adjustsFontSizeToFitWidth = ruleSet.adjustsFontSize; } else { self.adjustsFontSizeToFitWidth = NO; }
  if ([ruleSet hasBaselineAdjustment]) { self.baselineAdjustment = ruleSet.baselineAdjustment; } else { self.baselineAdjustment = UIBaselineAdjustmentNone; }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleSet *)ruleSet {
  [self applyViewStyleWithRuleSet:ruleSet];
  [self applyLabelStyleWithRuleSet:ruleSet];
}

@end
