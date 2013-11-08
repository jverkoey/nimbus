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

#import <Foundation/Foundation.h>

@class NICSSRuleset;
@class NIDOM;

/**
 * The protocol used by the NIStylesheet to apply NICSSRuleSets to views.
 *
 *      @ingroup NimbusCSS
 *
 * If you implement this protocol in a category it is recommended that you implement the
 * logic as a separate method and call that method from applyStyleWithRuleSet: so as to allow
 * subclasses to call super implementations. See UILabel+NIStyleable.h/m for an example.
 */
@protocol NIStyleable <NSObject>

/**
 * The given ruleset should be applied to the view. The ruleset represents a composite of all
 * rulesets in the applicable stylesheet.
 */
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

@optional
/**
 * Tells the CSS engine a set of pseudo classes that apply to views of this class.
 * In the case of UIButton, for example, this includes :selected, :highlighted, and :disabled.
 * In CSS, you specify these with selectors like UIButton:active. If you implement this you need to respond
 * to applyStyleWithRuleSet:forPseudoClass:
 *
 * Make sure to include the leading colon.
 */
- (NSArray*) pseudoClasses;

/**
 * Applies the given rule set to this view but for a pseudo class. Thus it only supports the subset of
 * properties that can be set on states of the view. (e.g. UIButton textColor or background)
 */
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet forPseudoClass: (NSString*) pseudo inDOM: (NIDOM*) dom;

/**
 * Return a string describing what would be done with the view. The current implementations return actual
 * Objective-C using the view name as the message target. The intent is to allow developers to debug
 * the logic, but also to be able to strip out the CSS infrastructure if desired and replace it with manual code.
 */
- (NSString*) descriptionWithRuleSet: (NICSSRuleset*) ruleSet forPseudoClass: (NSString*) pseudo inDOM: (NIDOM*) dom withViewName: (NSString*) name;

/**
 * sizeToFit is... bad. So if, let's say you ACTUALLY want to adjust size to fit based on width/height "auto", override this method
 * and then check the ruleSet width and height properties (at least one of them will be auto) and do your thing.
 */
- (void) autoSize: (NICSSRuleset*) ruleSet inDOM: (NIDOM*) dom;

/**
 * Called when your view is added to a DOM
 */
- (void) didRegisterInDOM: (NIDOM*) dom;

/**
 * Called when your view is removed from a DOM
 */
- (void) didUnregisterInDOM: (NIDOM*) dom;
@end
