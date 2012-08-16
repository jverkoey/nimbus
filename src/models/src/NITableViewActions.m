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

#import "NITableViewActions.h"

#import "NICellFactory.h"
#import "NITableViewModel.h"
#import "NimbusCore.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NITableViewAction : NSObject

@property (nonatomic, copy) NITableViewActionBlock tapAction;
@property (nonatomic, copy) NITableViewActionBlock detailAction;
@property (nonatomic, copy) NITableViewActionBlock navigateAction;

@end

@interface NITableViewActions()

@property (nonatomic, assign) UIViewController* controller;
@property (nonatomic, strong) NSMutableSet* forwardDelegates;
@property (nonatomic, strong) NSMutableDictionary* objectMap;
@property (nonatomic, strong) NSMutableSet* objectSet;
@property (nonatomic, strong) NSMutableDictionary* classMap;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewActions

@synthesize controller = _controller;
@synthesize forwardDelegates = _forwardDelegates;
@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;
@synthesize tableViewCellSelectionStyle = _tableViewCellSelectionStyle;
@synthesize classMap = _classMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(UIViewController *)controller {
  if ((self = [super init])) {
    _controller = controller;
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
    _classMap = [[NSMutableDictionary alloc] init];
    _forwardDelegates = NICreateNonRetainingMutableSet();
    _tableViewCellSelectionStyle = UITableViewCellSelectionStyleBlue;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  return [self initWithController:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)keyForObject:(id<NSObject>)object {
  return [NSNumber numberWithInteger:object.hash];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewAction *)actionForObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NITableViewAction* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [[NITableViewAction alloc] init];
    [self.objectMap setObject:action forKey:key];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewAction *)actionForClass:(Class)class {
  NITableViewAction* action = [self.classMap objectForKey:class];
  if (nil == action) {
    action = [[NITableViewAction alloc] init];
    [self.classMap setObject:action forKey:(id<NSCopying>)class];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewAction *)actionForObjectOrClassOfObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NITableViewAction* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [NICellFactory objectFromKeyClass:object.class map:self.classMap];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelector:(SEL)selector {
  struct objc_method_description description;
  description = protocol_getMethodDescription(@protocol(UITableViewDelegate), selector, NO, YES);
  return (description.name != NULL && description.types != NULL);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)selector {
  if ([super respondsToSelector:selector]) {
    return YES;
    
  } else if ([self shouldForwardSelector:selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        return YES;
      }
    }
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardInvocation:(NSInvocation *)invocation {
  BOOL didForward = NO;
  
  if ([self shouldForwardSelector:invocation.selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
        break;
      }
    }
  }
  
  if (!didForward) {
    [super forwardInvocation:invocation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate {
  [self.forwardDelegates addObject:forwardDelegate];
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeForwarding:(id<UITableViewDelegate>)forwardDelegate; {
  [self.forwardDelegates removeObject:forwardDelegate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachTapAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachDetailAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachNavigationAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].navigateAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachTapAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self actionForClass:aClass].tapAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachDetailAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self actionForClass:aClass].detailAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachNavigationAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self actionForClass:aClass].navigateAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectActionable:(id<NSObject>)object {
  BOOL objectIsActionable = [self.objectSet containsObject:object];
  if (!objectIsActionable) {
    objectIsActionable = (nil != [NICellFactory objectFromKeyClass:object.class map:self.classMap]);
  }
  return objectIsActionable;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource isKindOfClass:[NITableViewModel class]]);
  if ([tableView.dataSource isKindOfClass:[NITableViewModel class]]) {
    NITableViewModel* model = (NITableViewModel *)tableView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NITableViewAction* action = [self actionForObjectOrClassOfObject:object];
      UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;

      // Detail disclosure indicator takes precedence over regular disclosure indicator.
      if (nil != action.detailAction) {
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

      } else if (nil != action.navigateAction) {
        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }

      cell.accessoryType = accessoryType;

      // If the cell is tappable, reflect that in the selection style.
      if (action.navigateAction || action.tapAction) {
        cell.selectionStyle = self.tableViewCellSelectionStyle;
      }
    }
  }

  // Forward the invocation along.
  for (id<UITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource isKindOfClass:[NITableViewModel class]]);
  if ([tableView.dataSource isKindOfClass:[NITableViewModel class]]) {
    NITableViewModel* model = (NITableViewModel *)tableView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NITableViewAction* action = [self actionForObjectOrClassOfObject:object];

      if (action.tapAction) {
        // Tap actions can deselect the row if they return YES.
        if (action.tapAction(object, self.controller)) {
          [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
      }

      if (action.navigateAction) {
        action.navigateAction(object, self.controller);
      }
    }
  }

  // Forward the invocation along.
  for (id<UITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource isKindOfClass:[NITableViewModel class]]);
  if ([tableView.dataSource isKindOfClass:[NITableViewModel class]]) {
    NITableViewModel* model = (NITableViewModel *)tableView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NITableViewAction* action = [self actionForObjectOrClassOfObject:object];

      if (action.detailAction) {
        action.detailAction(object, self.controller);
      }
    }
  }

  // Forward the invocation along.
  for (id<UITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
  }
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewAction

@synthesize tapAction;
@synthesize detailAction;
@synthesize navigateAction;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
NITableViewActionBlock NIPushControllerAction(Class controllerClass) {
  return [^(id object, UIViewController* controller) {
    // You must initialize the actions object with initWithController: and pass a valid
    // controller.
    NIDASSERT(nil != controller);

    if (nil != controller) {
      UIViewController* controllerToPush = [[controllerClass alloc] init];
      [controller.navigationController pushViewController:controllerToPush
                                                 animated:YES];
    }

    return NO;
  } copy];
}
