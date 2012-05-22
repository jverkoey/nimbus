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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^NITableViewActionBlock)(id object, UIViewController* controller);

NITableViewActionBlock NIPushControllerAction(Class controllerClass);

@interface NITableViewActions : NSObject <UITableViewDelegate>

// Designated initializer.
- (id)initWithController:(UIViewController *)controller;

#pragma mark Mapping Objects 

- (void)mapObject:(id)object toTapAction:(NITableViewActionBlock)action;
- (void)mapObject:(id)object toDetailAction:(NITableViewActionBlock)action;
- (void)mapObject:(id)object toNavigateAction:(NITableViewActionBlock)action;

#pragma mark Object State

- (BOOL)isObjectActionable:(id)object;

#pragma mark UITableView Helpers

- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate;

@end
