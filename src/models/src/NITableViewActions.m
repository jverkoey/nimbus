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

@interface NITableViewAction : NSObject
@property (nonatomic, readwrite, copy) NITableViewActionBlock tapAction;
@property (nonatomic, readwrite, copy) NITableViewActionBlock detailAction;
@property (nonatomic, readwrite, copy) NITableViewActionBlock navigateAction;
@end

@interface NITableViewActions()
@property (nonatomic, readwrite, assign) UIViewController* controller;
@property (nonatomic, readwrite, assign) id<UITableViewDelegate> forwardDelegate;
@property (nonatomic, readonly, retain) NSMutableDictionary* objectMap;
@property (nonatomic, readonly, retain) NSMutableSet* objectSet;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITableViewActions

@synthesize controller = _controller;
@synthesize forwardDelegate = _forwardDelegate;
@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
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
  if ([self.forwardDelegate respondsToSelector:invocation.selector]) {
    [invocation invokeWithTarget:self.forwardDelegate];

  } else {
    [super forwardInvocation:invocation];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)respondsToSelector:(SEL)selector {
  BOOL doesRespond = [super respondsToSelector:selector];
  if (!doesRespond) {
    doesRespond = [self.forwardDelegate respondsToSelector:selector];
  }
  return doesRespond;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITableViewDelegate>)forwardingTo:(id<UITableViewDelegate>)forwardDelegate {
  self.forwardDelegate = forwardDelegate;
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObject:(id)object toTapAction:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObject:(id)object toDetailAction:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObject:(id)object toNavigateAction:(NITableViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].navigateAction = action;
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
      if (nil != action.detailAction) {
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
      } else if (nil != action.navigateAction) {
        accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      cell.accessoryType = accessoryType;
      if (action.navigateAction || action.tapAction) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
      }
    }
  }

  if ([self.forwardDelegate respondsToSelector:_cmd]) {
    [self.forwardDelegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
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
        action.tapAction(object, self.controller);
      }
      if (action.navigateAction) {
        action.navigateAction(object, self.controller);
      }
    }
  }

  if ([self.forwardDelegate respondsToSelector:_cmd]) {
    [self.forwardDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
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
    id nextController = [[[controllerClass alloc] init] autorelease];
    [controller.navigationController pushViewController:nextController
                                               animated:YES];
  } copy] autorelease];
}
