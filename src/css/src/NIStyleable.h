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
@required

/**
 * The given ruleset should be applied to the view. The ruleset represents a composite of all
 * rulesets in the applicable stylesheet.
 */
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet;

@end
