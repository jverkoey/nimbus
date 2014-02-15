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

extern NSString* const NICSSViewKey;
extern NSString* const NICSSViewIdKey;
extern NSString* const NICSSViewCssClassKey;
extern NSString* const NICSSViewTextKey;
extern NSString* const NICSSViewTagKey;
extern NSString* const NICSSViewTargetSelectorKey;
extern NSString* const NICSSViewSubviewsKey;
extern NSString* const NICSSViewAccessibilityLabelKey;
extern NSString* const NICSSViewBackgroundColorKey;

@interface UIView (NIStyleable)

/**
 * Applies the given rule set to this view. Call applyViewStyleWithRuleSet:inDOM: instead.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable.
 */
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet DEPRECATED_ATTRIBUTE;

/**
 * Applies the given rule set to this view.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * applyStyleWithRuleSet: method from NIStyleable.
 */
- (void)applyViewStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM: (NIDOM*) dom;

/**
 * Describes the given rule set when applied to this view.
 *
 * This method is exposed primarily for subclasses to use when implementing the
 * descriptionWithRuleSetFor:forPseudoClass:inDOM:withViewName: method from NIStyleable.
 */
- (NSString*) descriptionWithRuleSetForView: (NICSSRuleset*) ruleSet forPseudoClass: (NSString*) pseudo inDOM: (NIDOM*) dom withViewName: (NSString*) name;

/**
 * Build a view hierarchy. The array is a list of view specs, where viewSpec is a loosely formatted
 * sequence delineated by UIViews. After a UIView, the type of the next object determines what is done
 * with it:
 *   UIView instance - following values will be applied to this UIView (other than Class, which "starts anew")
 *   Class - a UIView subclass that will be alloc'ed and init'ed
 *   NSString starting with a hash - view id (for style application)
 *   NSString starting with a dot - CSS Class (for style application) (you can do this multiple times per view)
 *   NSString - accessibility label for the view.
 *   NIUserInterfaceString - .text or .title(normal) on a button. Asserts otherwise
 *   NSNumber - tag
 *   NSInvocation - selector for TouchUpInside (e.g. on a UIButton)
 *   NSArray - passed to build on the active UIView and results added as subviews
 *   NSDictionary - if you're squeamish about this whole Javascript duck typing auto detecting fancyness
 *        you can pass a boring old dictionary with named values: 
 *        NICSSViewKey, NICSSViewIdKey, NICSSViewCssClassKey, NICSSViewTextKey, NICSSViewTagKey, 
 *        NICSSViewTargetSelectorKey, NICSSViewSubviewsKey, NICSSViewAccessibilityLabelKey
 *
 *   Example (including inline setting of self properties):
 *    [self.view buildSubviews: @[
 *       self.buttonContainer = UIView.alloc.init, @"#LoginContainer", @[
 *         self.myButton = UIButton.alloc.init, @"#Login", @".primary"
 *       ]
 *    ]];
 */
- (NSArray*) buildSubviews: (NSArray*) viewSpecs inDOM: (NIDOM*) dom;

/// View frame and bounds manipulation helpers
@property (nonatomic) CGFloat frameWidth;
@property (nonatomic) CGFloat frameHeight;
@property (nonatomic) CGFloat frameMinX;
@property (nonatomic) CGFloat frameMidX;
@property (nonatomic) CGFloat frameMaxX;
@property (nonatomic) CGFloat frameMinY;
@property (nonatomic) CGFloat frameMidY;
@property (nonatomic) CGFloat frameMaxY;

@end
