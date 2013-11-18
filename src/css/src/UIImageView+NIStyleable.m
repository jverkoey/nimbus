//
// Copyright 2013 Max Metral
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

#import "UIImageView+NIStyleable.h"

#import "NIStylesheet.h"
#import "UIView+NIStyleable.h"
#import "NICSSRuleset.h"
#import "NimbusCore.h"
#import "NIUserInterfaceString.h"
#import "NIDOM.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(UIImageView_NIStyleable)

@implementation UIImageView (NIStyleable)

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)applyImageViewStyleBeforeViewWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom
{
    if (ruleSet.hasImage) {
        UIImage *uiImage;
        if ([NIStylesheet resourceResolver] && [[NIStylesheet resourceResolver] respondsToSelector: @selector(imageNamed:)]) {
            uiImage = [[NIStylesheet resourceResolver] imageNamed:ruleSet.image];
        } else {
            uiImage = [UIImage imageNamed:ruleSet.image];
        }
        self.image = uiImage;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applyStyleWithRuleSet:(NICSSRuleset *)ruleSet inDOM:(NIDOM *)dom {
    [self applyImageViewStyleBeforeViewWithRuleSet:ruleSet inDOM:dom];
    [self applyViewStyleWithRuleSet:ruleSet inDOM:dom];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void) autoSize: (NICSSRuleset*) ruleSet inDOM: (NIDOM*) dom {
    CGFloat newWidth = self.frameWidth, newHeight = self.frameHeight;
    
    if (ruleSet.hasWidth && ruleSet.width.type == CSS_AUTO_UNIT) {
        CGSize size = self.image.size;
        newWidth = ceilf(size.width);
    }
    
    if (ruleSet.hasHeight && ruleSet.height.type == CSS_AUTO_UNIT) {
        CGSize size = self.image.size;
        newHeight = ceilf(size.height);
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newWidth,
                            newHeight);
}
@end
