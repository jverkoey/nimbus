//
//  UITextView+NIStyleable.m
//  PPHCore
//
//  Created by Fisher, Mitch on 10/31/13.
//  Copyright (c) 2013 PayPal. All rights reserved.
//

#import "UITextView+NIStyleable.h"
#import "UIView+NIStyleable.h"

#import "NICSSRuleset.h"
#import "NIUserInterfaceString.h"
#import "NIPreprocessorMacros.h"

@class NIDOM;

NI_FIX_CATEGORY_BUG(UITextView_NIStyleable)

@implementation UITextView (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
    [self applyTextViewStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
    [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
    [self applyTextViewStyleWithRuleSet:ruleSet inDOM:dom];
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
-(void)applyTextViewStyleBeforeViewWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    if (ruleSet.hasTextKey) {
        NIUserInterfaceString *nis = [[NIUserInterfaceString alloc] initWithKey:ruleSet.textKey];
        [nis attach:self withSelector:@selector(setTitle:forState:) forControlState:UIControlStateNormal];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyTextViewStyleWithRuleSet:(NICSSRuleset*)ruleSet inDOM:(NIDOM*)dom
{
    if ([ruleSet hasTextColor]) { self.textColor = ruleSet.textColor; }
    if ([ruleSet hasTextAlignment]) { self.textAlignment = ruleSet.textAlignment; }
    if ([ruleSet hasFont]) { self.font = ruleSet.font; }
    if ([ruleSet hasReturnKeyType]) { self.returnKeyType = ruleSet.returnKeyType; }
    if ([ruleSet hasKeyboardType]) { self.keyboardType = ruleSet.keyboardType; }
    if ([ruleSet hasAutocapitalizationType]) { self.autocapitalizationType = ruleSet.autocapitalizationType; }
    if ([ruleSet hasAutocorrectionType]) { self.autocorrectionType = ruleSet.autocorrectionType; }
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
