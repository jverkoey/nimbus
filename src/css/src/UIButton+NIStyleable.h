//
// Copyright 2011-2014 NimbusKit
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

#import <UIKit/UIKit.h>

@class NICSSRuleset;
@class NIDOM;

@interface UIButton (NIStyleable)

/**
 * Applies the given rule set to this button. Call applyButtonStyleWithRuleSet:inDOM:
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable.
 */
- (void)applyButtonStyleWithRuleSet:(NICSSRuleset *)ruleSet DEPRECATED_ATTRIBUTE;

/**
 * Applies the given rule set to this button.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable.
 */
- (void)applyButtonStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

/**
 * Applies the given rule set to this label.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable. Since some of the view
 * styles (e.g. positioning) may rely on some label elements (like text), this is called
 * before the view styling is done.
 */
- (void)applyButtonStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

/**
 * Tells the CSS engine a set of pseudo classes that apply to views of this class.
 * In the case of UIButton, this includes :selected, :highlighted, and :disabled.
 * In CSS, you specify these with selectors like UIButton:active. If you implement this you need to respond
 * to applyStyleWithRuleSet:forPseudoClass:inDOM:
 *
 * Make sure to include the leading colon.
 */
- (NSArray*) pseudoClasses;

/**
 * Applies the given rule set to this button but for a pseudo class. Thus it only supports the subset of
 * properties that can be set on states of the button. (There's no fancy stuff that applies the styles
 * manually on state transitions.
 *
 * Since UIView doesn't have psuedo's, we don't need the specific version for UIButton like we do with
 * applyButtonStyleWithRuleSet.
 */
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet forPseudoClass: (NSString*) pseudo inDOM: (NIDOM*) dom;

@end
