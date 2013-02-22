//
//  UITextField+NIStyleable.m
//  Nimbus
//
//  Created by Metral, Max on 2/22/13.
//  Copyright (c) 2013 Jeff Verkoeyen. All rights reserved.
//

#import "UITextField+NIStyleable.h"
#import "UIView+NIStyleable.h"

#import "NICSSRuleset.h"
#import "NIUserInterfaceString.h"
#import "NIPreprocessorMacros.h"

@class NIDOM;

NI_FIX_CATEGORY_BUG(UITextField_NIStyleable)

@implementation UITextField (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
    [self applyTextFieldStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
    [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
    [self applyTextFieldStyleWithRuleSet:ruleSet inDOM:dom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyStyleWithRuleSet:(NICSSRuleset*)ruleSet forPseudoClass:(NSString *)pseudo inDOM:(NIDOM*)dom
{
    if (ruleSet.hasTextKey) {
        NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
        [nis attach:self withSelector:@selector(setPlaceholder:)];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyTextFieldStyleBeforeViewWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    if (ruleSet.hasTextKey) {
        NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
        [nis attach:self withSelector:@selector(setTitle:forState:) forControlState:UIControlStateNormal];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyTextFieldStyleWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    if ([ruleSet hasTextColor]) { self.textColor = ruleSet.textColor; }
    if ([ruleSet hasTextAlignment]) { self.textAlignment = ruleSet.textAlignment; }
    if ([ruleSet hasFont]) { self.font = ruleSet.font; }
    if ([ruleSet hasMinimumFontSize]) { self.minimumFontSize = ruleSet.minimumFontSize; }
    if ([ruleSet hasAdjustsFontSize]) { self.adjustsFontSizeToFitWidth = ruleSet.adjustsFontSize; }
    if ([ruleSet hasVerticalAlign]) { self.contentVerticalAlignment = ruleSet.verticalAlign; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray *)pseudoClasses
{
    static dispatch_once_t onceToken;
    static NSArray *pseudos;
    dispatch_once(&onceToken, ^{
        pseudos = @[@":empty"];
    });
    return pseudos;
}

@end
