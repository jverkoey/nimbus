//
// Copyright 2011-2014 NimbusKit
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

#import "NimbusLauncher.h"

@class NIBadgeView;

/**
 * A subclass of NILauncherViewObject that provides badging support.
 *
 * Adding this type of object to a NILauncherViewModel will create a BadgedLauncherButtonView view.
 */
@interface BadgedLauncherViewObject : NILauncherViewObject
@property (nonatomic, assign) NSInteger badgeNumber;
- (id)initWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber;
+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber;
@end

/**
 * A launcher button view that displays a badge number.
 *
 * The badge is hidden if the number is 0.
 * The badge displays 99+ if the number is greater than 99.
 */
@interface BadgedLauncherButtonView : NILauncherButtonView
@property (nonatomic, retain) NIBadgeView* badgeView;
@end
