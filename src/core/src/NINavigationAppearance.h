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

/**
 * Convenience class for saving and restoring the navigation appearance state.
 *
 *      @ingroup NimbusCore
 */
@interface NINavigationAppearance : NSObject

/**
 * Take a snapshot of the current navigation appearance.
 *
 * Call this method before mutating the nav bar style or status bar style.
 */
+ (void)pushAppearanceForNavigationController:(UINavigationController *)navigationController;


/**
 * Restore the last navigation appearance snapshot.
 *
 * Pops the last appearance values off the stack and applies them.
 */
+ (void)popAppearanceForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

@end


/**
 * Model class which captures and stores navigation appearance.
 *
 * Used in conjunction with NINavigationAppearance.
 *
 *      @ingroup NimbusCore
 */
@interface NINavigationAppearanceSnapshot : NSObject {
@private
  BOOL _navBarTranslucent;
  UIBarStyle _navBarStyle;
  UIStatusBarStyle _statusBarStyle;
}

/**
 * Create a new snapshot.
 */
- (id)initForNavigationController:(UINavigationController *)navigationController;

/**
 * Apply the previously captured state.
 */
- (void)restoreForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

@end
