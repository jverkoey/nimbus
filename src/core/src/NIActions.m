//
// Copyright 2011-2013 Jeff Verkoeyen
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

#import "NIActions.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIObjectActions : NSObject

@property (nonatomic, copy) NITableViewActionBlock tapAction;
@property (nonatomic, copy) NITableViewActionBlock detailAction;
@property (nonatomic, copy) NITableViewActionBlock navigateAction;

@property (nonatomic, assign) SEL tapSelector;
@property (nonatomic, assign) SEL detailSelector;
@property (nonatomic, assign) SEL navigateSelector;

@end

@interface NIActions()

@property (nonatomic, NI_WEAK) id target;
@property (nonatomic, NI_STRONG) NSMutableSet* forwardDelegates;
@property (nonatomic, NI_STRONG) NSMutableDictionary* objectMap;
@property (nonatomic, NI_STRONG) NSMutableSet* objectSet;
@property (nonatomic, NI_STRONG) NSMutableDictionary* classMap;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIActions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTarget:(id)target {
  if ((self = [super init])) {
    _target = target;
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
    _classMap = [[NSMutableDictionary alloc] init];
    _forwardDelegates = NICreateNonRetainingMutableSet();
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
- (NIObjectActions *)actionForObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NIObjectActions* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [[NIObjectActions alloc] init];
    [self.objectMap setObject:action forKey:key];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIObjectActions *)actionForClass:(Class)class {
  NIObjectActions* action = [self.classMap objectForKey:class];
  if (nil == action) {
    action = [[NIObjectActions alloc] init];
    [self.classMap setObject:action forKey:(id<NSCopying>)class];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NIObjectActions *)actionForObjectOrClassOfObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NIObjectActions* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [NICellFactory objectFromKeyClass:object.class map:self.classMap];
  }
  return action;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIObjectActions
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
NIActionBlock NIPushControllerAction(Class controllerClass) {
  return [^(id object, id target, NSIndexPath* indexPath) {
    // You must initialize the actions object with initWithTarget: and pass a valid
    // controller.
    NIDASSERT(nil != target);
    NIDASSERT([target isKindOfClass:[UIViewController class]]);
    UIViewController *controller = target;

    if (nil != controller && [controller isKindOfClass:[UIViewController class]]) {
      // No navigation controller to push this new controller; this controller
      // is going to be lost.
      NIDASSERT(nil != controller.navigationController);

      UIViewController* controllerToPush = [[controllerClass alloc] init];
      [controller.navigationController pushViewController:controllerToPush
                                                 animated:YES];
    }

    return NO;
  } copy];
}
