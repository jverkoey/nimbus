//
// Copyright 2011 Max Metral
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

#import "NITextField+NIStyleable.h"
#import "UITextField+NIStyleable.h"
#import "UIView+NIStyleable.h"

#import "NIDOM.h"
#import "NICSSRuleset.h"
#import "NIUserInterfaceString.h"
#import "NIPreprocessorMacros.h"

NI_FIX_CATEGORY_BUG(NITextField_NIStyleable)

@implementation NITextField (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
    [self applyNITextFieldStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
    [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
    [self applyNITextFieldStyleWithRuleSet:ruleSet inDOM:dom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyStyleWithRuleSet:(NICSSRuleset*)ruleSet forPseudoClass:(NSString *)pseudo inDOM:(NIDOM*)dom
{
    if (ruleSet.hasFont) {
        self.placeholderFont = ruleSet.font;
    }
    if (ruleSet.hasTextColor) {
        self.placeholderTextColor = ruleSet.textColor;
    }
    if (ruleSet.hasTextKey) {
        NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
        [nis attach:self withSelector:@selector(setPlaceholder:)];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyNITextFieldStyleBeforeViewWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    [self applyTextFieldStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
    if (ruleSet.hasTitleInsets) {
        self.textInsets = ruleSet.titleInsets;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyNITextFieldStyleWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    [self applyTextFieldStyleWithRuleSet:ruleSet inDOM:dom];
}

@end
