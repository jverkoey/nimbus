//
// Copyright 2012 Jeff Verkoeyen
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

#import "UIActivityIndicatorView+NIStyleable.h"

#import "UIView+NIStyleable.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"

NI_FIX_CATEGORY_BUG(UIActivityIndicatorView_NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIActivityIndicatorView (NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyActivityIndicatorStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  if ([ruleSet hasActivityIndicatorStyle]) { [self setActivityIndicatorViewStyle:ruleSet.activityIndicatorStyle]; } else { [self setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge]; }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyViewStyleWithRuleSet:ruleSet];
  [self applyActivityIndicatorStyleWithRuleSet:ruleSet];
}


@end
