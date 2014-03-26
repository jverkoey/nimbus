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

#import <SenTestingKit/SenTestingKit.h>

#import "NimbusCore.h"

@interface NINavigationAppearanceTests : SenTestCase {
}

@end


@implementation NINavigationAppearanceTests


- (void)setUp {
  // Clear appearance stack before each test
  [NINavigationAppearance clear];
}

- (void)testSinglePush {
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  STAssertEquals([NINavigationAppearance count], 1, @"Stack count should be 1");
}

- (void)testMultiplePushes {
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  STAssertEquals([NINavigationAppearance count], 3, @"Stack count should be 3");
}

- (void)testSinglePushPop {
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [NINavigationAppearance popAppearanceForNavigationController:nil animated:NO];
  STAssertEquals([NINavigationAppearance count], 0, @"Stack count should be 0");
}

- (void)testEmptyPop {
  NIDebugAssertionsShouldBreak = NO;
  [NINavigationAppearance popAppearanceForNavigationController:nil animated:NO];
  STAssertEquals([NINavigationAppearance count], 0, @"Stack count should be 0");
  NIDebugAssertionsShouldBreak = YES;
}

- (void)testMultiplePushPops {
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [NINavigationAppearance popAppearanceForNavigationController:nil animated:NO];
  STAssertEquals([NINavigationAppearance count], 1, @"Stack count should be 1");
}

- (void)testNavBarStyleRestored {
  UINavigationController *navigationController = [[UINavigationController alloc] init];
  navigationController.navigationBar.barStyle = UIBarStyleDefault;
  [NINavigationAppearance pushAppearanceForNavigationController:navigationController];
  navigationController.navigationBar.barStyle = UIBarStyleBlack;
  [NINavigationAppearance popAppearanceForNavigationController:navigationController animated:NO];
  STAssertEquals(navigationController.navigationBar.barStyle, UIBarStyleDefault, @"Nav bar style should be UIBarStyleDefault");
}

- (void)testNavBarTranslucencyRestored {
  UINavigationController *navigationController = [[UINavigationController alloc] init];
  navigationController.navigationBar.translucent = NO;
  [NINavigationAppearance pushAppearanceForNavigationController:navigationController];
  navigationController.navigationBar.translucent = YES;
  [NINavigationAppearance popAppearanceForNavigationController:navigationController animated:NO];
  STAssertEquals(navigationController.navigationBar.translucent, NO, @"Nav bar should not be translucent");
}

- (void)testStatusBarStyleRestored {
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
  [NINavigationAppearance pushAppearanceForNavigationController:nil];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  [NINavigationAppearance popAppearanceForNavigationController:nil animated:NO];
  STAssertEquals([[UIApplication sharedApplication] statusBarStyle], UIStatusBarStyleDefault, @"Status bar style should be UIStatusBarStyleDefault");
}


@end
