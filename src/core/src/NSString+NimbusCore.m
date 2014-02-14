//
// Copyright 2011-2014 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import "NSString+NimbusCore.h"

#import "NIFoundationMethods.h"
#import "NIPreprocessorMacros.h"

#import <UIKit/UIKit.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(NSStringNimbusCore)
/**
 * For manipulating NSStrings.
 */
@implementation NSString (NimbusCore)


/**
 * Calculates the height of this text given the font, max width, and line break mode.
 *
 * A convenience wrapper for sizeWithFont:constrainedToSize:lineBreakMode:
 */
// COV_NF_START
- (CGFloat)heightWithFont:(UIFont*)font
       constrainedToWidth:(CGFloat)width
            lineBreakMode:(NSLineBreakMode)lineBreakMode {
  return [self sizeWithFont:font
          constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
              lineBreakMode:lineBreakMode].height;
}
// COV_NF_END

@end
