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

#import "NINavigationAppearance.h"
#import "NIDebuggingTools.h"
#import "NISDKAvailability.h"

static NSMutableArray* sAppearanceStack = nil;

/**
 * @internal
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
 * Holds value of UINavigationBar's translucent property.
 */
@property (nonatomic, readonly, assign) BOOL navBarTranslucent;

/**
 * Holds value of UINavigationBar's barStyle property.
 */
@property (nonatomic, readonly, assign) UIBarStyle navBarStyle;

/**
 * Holds value of UIApplication's statusBarStyle property.
 */
@property (nonatomic, readonly, assign) UIStatusBarStyle statusBarStyle;


/**
 * Create a new snapshot.
 */
- (id)initForNavigationController:(UINavigationController *)navigationController;

/**
 * Apply the previously captured state.
 */
- (void)restoreForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

@end


@implementation NINavigationAppearance


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)pushAppearanceForNavigationController:(UINavigationController *)navigationController {
  if (!sAppearanceStack) {
    sAppearanceStack = [[NSMutableArray alloc] init];
  }

  NINavigationAppearanceSnapshot *snapshot = [[NINavigationAppearanceSnapshot alloc] initForNavigationController:navigationController];
  [sAppearanceStack addObject:snapshot];
  [snapshot release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)popAppearanceForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
  NIDASSERT([sAppearanceStack count] > 0);
  if ([sAppearanceStack count]) {
    NINavigationAppearanceSnapshot *snapshot = [sAppearanceStack objectAtIndex:0];
    [snapshot restoreForNavigationController:navigationController animated:animated];
    [sAppearanceStack removeObject:snapshot];
  }

  if (![sAppearanceStack count]) {
    [sAppearanceStack release];
    sAppearanceStack = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSInteger)count {
  return [sAppearanceStack count];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)clear {
  [sAppearanceStack removeAllObjects];
  [sAppearanceStack release];
  sAppearanceStack = nil;
}


@end


@implementation NINavigationAppearanceSnapshot

@synthesize navBarTranslucent = _navBarTranslucent;
@synthesize navBarStyle = _navBarStyle;
@synthesize statusBarStyle = _statusBarStyle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initForNavigationController:(UINavigationController *)navigationController {
  self = [super init];
  if (self) {
    _statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    _navBarStyle = navigationController.navigationBar.barStyle;
    _navBarTranslucent = navigationController.navigationBar.translucent;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreForNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:animated];
  navigationController.navigationBar.barStyle = self.navBarStyle;
  navigationController.navigationBar.translucent = self.navBarTranslucent;
}


@end
