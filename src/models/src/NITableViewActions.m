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

#import "NITableViewModel.h"
#import "NimbusCore.h"

@interface NITableViewAction : NSObject
@property (nonatomic, readwrite, copy) NITableViewActionBlock tapAction;
@property (nonatomic, readwrite, copy) NITableViewActionBlock detailAction;
@property (nonatomic, readwrite, copy) NITableViewActionBlock navigateAction;
@end

@interface NITableViewActions()
@property (nonatomic, readonly, assign) UIViewController* controller;
@property (nonatomic, readonly, retain) NSMutableSet* forwardDelegates;
@property (nonatomic, readonly, retain) NSMutableDictionary* objectMap;
@property (nonatomic, readonly, retain) NSMutableSet* objectSet;
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


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_forwardDelegates release];
  [_objectMap release];
  [_objectSet release];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(UIViewController *)controller {
  if ((self = [super init])) {
    _controller = controller;
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
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
- (id)keyForObject:(id)object {
  return [NSNumber numberWithLong:(long)object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewAction *)actionForObject:(id)object {
  id key = [self keyForObject:object];
  NITableViewAction* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [[[NITableViewAction alloc] init] autorelease];
    [self.objectMap setObject:action forKey:key];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardInvocation:(NSInvocation *)invocation {
  BOOL didForward = NO;

  for (id delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:invocation.selector]) {
      [invocation invokeWithTarget:delegate];
      didForward = YES;
      break;
    }
  }

  if (!didForward) {
    [super forwardInvocation:invocation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)selector {
  BOOL doesRespond = [super respondsToSelector:selector];
  if (!doesRespond) {
    for (id delegate in self.forwardDelegates) {
      doesRespond = [delegate respondsToSelector:selector];
      if (doesRespond) {
        break;
      }
    }
  }
  return doesRespond;
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
- (id)attachTapAction:(NITableViewActionBlock)action toObject:(id)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachDetailAction:(NITableViewActionBlock)action toObject:(id)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachNavigationAction:(NITableViewActionBlock)action toObject:(id)object {
  [self.objectSet addObject:object];
  [self actionForObject:object].navigateAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectActionable:(id)object {
  return [self.objectSet containsObject:object];
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
      NITableViewAction* action = [self actionForObject:object];
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
      NITableViewAction* action = [self actionForObject:object];

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
      NITableViewAction* action = [self actionForObject:object];

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

@synthesize tapAction = _tapAction;
@synthesize detailAction = _detailAction;
@synthesize navigateAction = _navigateAction;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_tapAction release];
  [_detailAction release];
  [_navigateAction release];
  
  [super dealloc];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
NITableViewActionBlock NIPushControllerAction(Class controllerClass) {
  return [[^(id object, UIViewController* controller) {
    // You must initialize the actions object with initWithController: and pass a valid
    // controller.
    NIDASSERT(nil != controller);

    if (nil != controller) {
      id nextController = [[[controllerClass alloc] init] autorelease];
      [controller.navigationController pushViewController:nextController
                                                 animated:YES];
    }

    return NO;
  } copy] autorelease];
}
