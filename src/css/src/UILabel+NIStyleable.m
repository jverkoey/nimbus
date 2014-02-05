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
#import "NSString+NIStyleable.h"

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
  if ([ruleSet hasFont]) { self.font = ruleSet.font; }
  if ([ruleSet hasTextShadowColor]) { self.shadowColor = ruleSet.textShadowColor; }
  if ([ruleSet hasTextShadowOffset]) { self.shadowOffset = ruleSet.textShadowOffset; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyLabelStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
  if (ruleSet.hasTextKey) {
    NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
    [nis attach:self withSelector:@selector(setText:)];
  }
  if ([ruleSet hasLineBreakMode]) { self.lineBreakMode = ruleSet.lineBreakMode; }
  if ([ruleSet hasNumberOfLines]) { self.numberOfLines = ruleSet.numberOfLines; }
  if ([ruleSet hasMinimumFontSize]) { self.minimumFontSize = ruleSet.minimumFontSize; }
  if ([ruleSet hasAdjustsFontSize]) { self.adjustsFontSizeToFitWidth = ruleSet.adjustsFontSize; }
  if ([ruleSet hasTextAlignment]) { self.textAlignment = ruleSet.textAlignment; }
  if ([ruleSet hasBaselineAdjustment]) { self.baselineAdjustment = ruleSet.baselineAdjustment; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyLabelStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
  [self applyLabelStyleWithRuleSet:ruleSet inDOM:dom];
  [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) autoSize: (NICSSRuleset*) ruleSet inDOM: (NIDOM*) dom {
  CGFloat newWidth = self.frameWidth, newHeight = self.frameHeight;
  
  if (ruleSet.hasWidth && ruleSet.width.type == CSS_AUTO_UNIT) {
    
    CGSize size = [self.text
                   niSizeWithFont:self.font
                   constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)];
    newWidth = ceilf(size.width);
  }
  
  if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
    CGSize sizeForOneLine = [@"." sizeWithFont:self.font constrainedToSize:CGSizeMake(newWidth, CGFLOAT_MAX)];
    float heightForOneLine = sizeForOneLine.height;
    
    CGSize size = [self.text
                   niSizeWithFont:self.font
                   constrainedToSize:CGSizeMake(newWidth, CGFLOAT_MAX)];

    float maxHeight = (self.numberOfLines == 0) ? CGFLOAT_MAX : (heightForOneLine * self.numberOfLines);
    
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
@end
