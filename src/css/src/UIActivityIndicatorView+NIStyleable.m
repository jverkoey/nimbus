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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UIActivityIndicatorView_NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIActivityIndicatorView (NIStyleable)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyActivityIndicatorStyleWithRuleSet:(NICSSRuleset *)ruleSet {
  [self applyActivityIndicatorStyleWithRuleSet:ruleSet inDOM:nil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyActivityIndicatorStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  if ([ruleSet hasActivityIndicatorStyle]) { [self setActivityIndicatorViewStyle:ruleSet.activityIndicatorStyle]; } else { [self setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge]; }
  if ([ruleSet hasTextColor]) { [self setColor:ruleSet.textColor]; }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
  [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
  [self applyActivityIndicatorStyleWithRuleSet:ruleSet inDOM:dom];
}


@end
