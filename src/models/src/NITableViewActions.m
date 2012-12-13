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

@property (nonatomic, assign) SEL tapSelector;
@property (nonatomic, assign) SEL detailSelector;
@property (nonatomic, assign) SEL navigateSelector;

@end

@interface NITableViewActions()

@property (nonatomic, NI_WEAK) id target;
@property (nonatomic, NI_STRONG) NSMutableSet* forwardDelegates;
@property (nonatomic, NI_STRONG) NSMutableDictionary* objectMap;
@property (nonatomic, NI_STRONG) NSMutableSet* objectSet;
@property (nonatomic, NI_STRONG) NSMutableDictionary* classMap;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewActions

@synthesize target = _target;
@synthesize forwardDelegates = _forwardDelegates;
@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;
@synthesize tableViewCellSelectionStyle = _tableViewCellSelectionStyle;
@synthesize classMap = _classMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (id)initWithController:(UIViewController *)controller {
  return [self initWithTarget:controller];
}
#pragma clang diagnostic pop


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTarget:(id)target {
  if ((self = [super init])) {
    _target = target;
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
  return [self initWithTarget:nil];
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
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  NSMethodSignature *signature = [super methodSignatureForSelector:selector];
  if (signature == nil) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        signature = [delegate methodSignatureForSelector:selector];
      }
    }
  }
  return signature;
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
#pragma mark - Deprecated Public Methods

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachTapAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  return [self attachToObject:object tapBlock:action];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachDetailAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  return [self attachToObject:object detailBlock:action];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachNavigationAction:(NITableViewActionBlock)action toObject:(id<NSObject>)object {
  return [self attachToObject:object navigationBlock:action];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachTapAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self attachToClass:aClass tapBlock:action];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachDetailAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self attachToClass:aClass detailBlock:action];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachNavigationAction:(NITableViewActionBlock)action toClass:(Class)aClass {
  [self attachToClass:aClass navigationBlock:action];
}

#pragma clang diagnostic pop

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object tapBlock:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object detailBlock:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object navigationBlock:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].navigateAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object tapSelector:(SEL)selector {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapSelector = selector;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object detailSelector:(SEL)selector {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailSelector = selector;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object navigationSelector:(SEL)selector {
  [self.objectSet addObject:object];
  [self actionForObject:object].navigateSelector = selector;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass tapBlock:(NITableViewActionBlock)action {
  [self actionForClass:aClass].tapAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass detailBlock:(NITableViewActionBlock)action {
  [self actionForClass:aClass].detailAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass navigationBlock:(NITableViewActionBlock)action {
  [self actionForClass:aClass].navigateAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass tapSelector:(SEL)selector {
  [self actionForClass:aClass].tapSelector = selector;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass detailSelector:(SEL)selector {
  [self actionForClass:aClass].detailSelector = selector;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass navigationSelector:(SEL)selector {
  [self actionForClass:aClass].navigateSelector = selector;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectActionable:(id<NSObject>)object {
  if (nil == object) {
    return NO;
  }

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

      // Detail disclosure indicator takes precedence over regular disclosure indicator.
      if (nil != action.detailAction || nil != action.detailSelector) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

      } else if (nil != action.navigateAction || nil != action.navigateSelector) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

      } else {
        // We must maintain consistency of modifications to the accessoryType within this call due
        // to the fact that cells will be reused.
        cell.accessoryType = UITableViewCellAccessoryNone;
      }

      // If the cell is tappable, reflect that in the selection style.
      if (action.navigateAction || action.tapAction
          || action.navigateSelector || action.tapSelector) {
        cell.selectionStyle = self.tableViewCellSelectionStyle;

      } else {
        // We must maintain consistency of modifications to the selectionStyle within this call due
        // to the fact that cells will be reused.
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
      }

    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

      BOOL shouldDeselect = NO;
      if (action.tapAction) {
        // Tap actions can deselect the row if they return YES.
        shouldDeselect = action.tapAction(object, self.target);
      }
      if (action.tapSelector && [self.target respondsToSelector:action.tapSelector]) {
        NSMethodSignature *methodSignature = [self.target methodSignatureForSelector:action.tapSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = action.tapSelector;
        if (methodSignature.numberOfArguments >= 3) {
          [invocation setArgument:&object atIndex:2];
        }
        [invocation invokeWithTarget:self.target];

        NSUInteger length = invocation.methodSignature.methodReturnLength;
        if (length > 0) {
          char *buffer = (void *)malloc(length);
          memset(buffer, 0, sizeof(char) * length);
          [invocation getReturnValue:buffer];
          for (NSUInteger index = 0; index < length; ++index) {
            if (buffer[index]) {
              shouldDeselect = YES;
              break;
            }
          }
          free(buffer);
        }
      }
      if (shouldDeselect) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
      }

      if (action.navigateAction) {
        action.navigateAction(object, self.target);
      }
      if (action.navigateSelector && [self.target respondsToSelector:action.navigateSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:action.navigateSelector withObject:object];
#pragma clang diagnostic pop
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
        action.detailAction(object, self.target);
      }
      if (action.detailSelector && [self.target respondsToSelector:action.detailSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:action.detailSelector withObject:object];
#pragma clang diagnostic pop
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
@synthesize tapSelector;
@synthesize detailSelector;
@synthesize navigateSelector;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
NITableViewActionBlock NIPushControllerAction(Class controllerClass) {
  return [^(id object, id target) {
    // You must initialize the actions object with initWithTarget: and pass a valid
    // controller.
    NIDASSERT(nil != target);
    NIDASSERT([target isKindOfClass:[UIViewController class]]);
    UIViewController *controller = target;

    if (nil != controller && [controller isKindOfClass:[UIViewController class]]) {
      UIViewController* controllerToPush = [[controllerClass alloc] init];
      [controller.navigationController pushViewController:controllerToPush
                                                 animated:YES];
    }

    return NO;
  } copy];
}
