//
// Copyright 2011 Basil Shkara
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

#import "NIPreprocessorMacros.h"

@class NINavigationAppearanceSnapshot;

/**
 * The NINavigationAppearance provides support for saving and restoring the navigation appearance
 * state.
 *
 * This class is now deprecated due to the ease with which it may cause more problems than it
 * solves. It is recommended that instead of obfuscating navigation appearance by using this class
 * that you define and follow a standard practice of modifying navigation appearance throughout your
 * app that is more explicit.
 *
 * Use this when you are about to mutate the navigation bar style and/or status
 * bar style, and you want to be able to restore these bar styles sometime in the
 * future.
 *
 * An example of usage for this pattern is in NIToolbarPhotoViewController which
 * changes the navigation bar style to UIBarStyleBlack and the status bar style to
 * UIStatusBarStyleBlack* in viewWillAppear:.
 *
 * @code
 * [NINavigationAppearance pushAppearanceForNavigationController:self.navigationController]
 *
 * UINavigationBar* navBar = self.navigationController.navigationBar;
 * navBar.barStyle = UIBarStyleBlack;
 * navBar.translucent = YES;
 * @endcode
 *
 * Note that the call to NINavigationAppearance must occur before mutating any bar
 * states so that it is able to capture the original state correctly.
 *
 * Then when NIToolbarPhotoViewController is ready to restore the original navigation
 * appearance state, (in viewWillDisappear:), it calls the following:
 *
 * @code
 * [NINavigationAppearance popAppearanceForNavigationController:self.navigationController]
 * @endcode
 *
 * which pops the last snapshot of the stack and applies it, restoring the original
 * navigation appearance state.
 *
 * @ingroup NimbusCore
 */
__NI_DEPRECATED_METHOD
@interface NINavigationAppearance : NSObject

+ (void)pushAppearanceForNavigationController:(UINavigationController *)navigationController;
+ (void)popAppearanceForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

+ (NSInteger)count;
+ (void)clear;

@end

/**
 * Take a snapshot of the current navigation appearance.
 *
 * Call this method before mutating the nav bar style or status bar style.
 *
 *    @fn NINavigationAppearance::pushAppearanceForNavigationController:
 */

/**
 * Restore the last navigation appearance snapshot.
 *
 * Pops the last appearance values off the stack and applies them.
 *
 *    @fn NINavigationAppearance::popAppearanceForNavigationController:animated:
 */

/**
 * Returns the number of items in the appearance stack.
 *
 *    @fn NINavigationAppearance::count
 */

/**
 * Remove all navigation appearance snapshots from the stack.
 *
 *    @fn NINavigationAppearance::clear
 */
