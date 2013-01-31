//
// Copyright 2011-2013 Jeff Verkoeyen
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
#import <UIKit/UIKit.h>

#if defined __cplusplus
extern "C" {
#endif

/**
 * For manipulating UIButton objects.
 *
 * @ingroup NimbusCore
 * @defgroup Button-Utilities Button Utilities
 * @{
 *
 * The methods provided here make it possible to specify different properties for different button
 * states in a scalable way. For example, you can define a stylesheet class that has a number of
 * class methods that return the various properties for buttons.
 *
@code
@implementation Stylesheet

+ (UIImage *)backgroundImageForButtonWithState:(UIControlState)state {
  if (state & UIControlStateHighlighted) {
    return [UIImage imageNamed:@"button_highlighted"];

  } else if (state == UIControlStateNormal) {
    return [UIImage imageNamed:@"button"];
  }
  return nil;
}

@end

// The result of the implementation above will set the background images for the button's
// highlighted and default states.
NIApplyBackgroundImageSelectorToButton(@selector(backgroundImageForButtonWithState:),
                                       [Stylesheet class],
                                       button);
@endcode
 */

/**
 * Sets the images for a button's states.
 *
 *      @param selector A selector of the form:
 *                      (UIImage *)imageWithControlState:(UIControlState)controlState
 *      @param target The target upon which the selector will be invoked.
 *      @param button The button object whose properties should be modified.
 */
void NIApplyImageSelectorToButton(SEL selector, id target, UIButton* button);

/**
 * Sets the background images for a button's states.
 *
 *      @param selector A selector of the form:
 *                      (UIImage *)backgroundImageWithControlState:(UIControlState)controlState
 *      @param target The target upon which the selector will be invoked.
 *      @param button The button object whose properties should be modified.
 */
void NIApplyBackgroundImageSelectorToButton(SEL selector, id target, UIButton* button);

/**
 * Sets the title colors for a button's states.
 *
 *      @param selector A selector of the form:
 *                      (UIColor *)colorWithControlState:(UIControlState)controlState
 *      @param target The target upon which the selector will be invoked.
 *      @param button The button object whose properties should be modified.
 */
void NIApplyTitleColorSelectorToButton(SEL selector, id target, UIButton* button);

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Button Utilities /////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#if defined __cplusplus
};
#endif
