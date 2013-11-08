//
//  UITextView+NIStyleable.h
//  PPHCore
//
//  Created by Fisher, Mitch on 10/31/13.
//  Copyright (c) 2013 PayPal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NICSSRuleset;
@class NIDOM;

@interface UITextView (NIStyleable)

/**
 * Applies the given rule set to this text view.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable.
 */
- (void)applyTextViewStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

/**
 * Applies the given rule set to this label.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable. Since some of the view
 * styles (e.g. positioning) may rely on some label elements (like text), this is called
 * before the view styling is done.
 */
- (void)applyTextViewStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

/**
 * Tells the CSS engine a set of pseudo classes that apply to views of this class.
 * In the case of UITextView, this is :empty.
 * In CSS, you specify these with selectors like UITextView:empty.
 *
 * Make sure to include the leading colon.
 */
- (NSArray*) pseudoClasses;

/**
 * Applies the given rule set to this text view but for a pseudo class. Thus it only supports the subset of
 * properties that can be set on states of the button. (There's no fancy stuff that applies the styles
 * manually on state transitions.
 *
 * Since UIView doesn't have psuedo's, we don't need the specific version for UITextView like we do with
 * applyTextViewStyleWithRuleSet.
 */
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet forPseudoClass: (NSString*) pseudo inDOM: (NIDOM*) dom;

@end
