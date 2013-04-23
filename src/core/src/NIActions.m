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
#import "NIActions+Subclassing.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIActions()

@property (nonatomic, NI_STRONG) NSMutableDictionary* objectMap;
@property (nonatomic, NI_STRONG) NSMutableSet* objectSet;
@property (nonatomic, NI_STRONG) NSMutableDictionary* classMap;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIActions

@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;
@synthesize classMap = _classMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTarget:(id)target {
  if ((self = [super init])) {
    _target = target;
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
    _classMap = [[NSMutableDictionary alloc] init];
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

//
// actionForObject: and actionForClass: are used when attaching actions to objects and classes and
// will always return an NIObjectActions object. These methods should not be used for determining
// whether an action is attached to a given object or class.
//
// actionForObjectOrClassOfObject: determines whether an action has been attached to an object
// or class of object and then returns the NIObjectActions or nil if no actions have been attached.
//


///////////////////////////////////////////////////////////////////////////////////////////////////
// Retrieves an NIObjectActions object for the given object or creates one if it doesn't yet exist
// so that actions may be attached.
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
// Retrieves an NIObjectActions object for the given class or creates one if it doesn't yet exist
// so that actions may be attached.
- (NIObjectActions *)actionForClass:(Class)class {
  NIObjectActions* action = [self.classMap objectForKey:class];
  if (nil == action) {
    action = [[NIObjectActions alloc] init];
    [self.classMap setObject:action forKey:(id<NSCopying>)class];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Fetches any attached actions for a given object.
- (NIObjectActions *)actionForObjectOrClassOfObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NIObjectActions* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [self.class objectFromKeyClass:object.class map:self.classMap];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object tapBlock:(NIActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object detailBlock:(NIActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].detailAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object navigationBlock:(NIActionBlock)action {
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
- (void)attachToClass:(Class)aClass tapBlock:(NIActionBlock)action {
  [self actionForClass:aClass].tapAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass detailBlock:(NIActionBlock)action {
  [self actionForClass:aClass].detailAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass navigationBlock:(NIActionBlock)action {
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
    objectIsActionable = (nil != [self.class objectFromKeyClass:object.class map:self.classMap]);
  }
  return objectIsActionable;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectFromKeyClass:(Class)keyClass map:(NSMutableDictionary *)map {
  id object = [map objectForKey:keyClass];

  if (nil == object) {
    // No mapping found for this key class, but it may be a subclass of another object that does
    // have a mapping, so let's see what we can find.
    Class superClass = nil;
    for (Class class in map.allKeys) {
      // We want to find the lowest node in the class hierarchy so that we pick the lowest ancestor
      // in the hierarchy tree.
      if ([keyClass isSubclassOfClass:class]
          && (nil == superClass || [keyClass isSubclassOfClass:superClass])) {
        superClass = class;
      }
    }

    if (nil != superClass) {
      object = [map objectForKey:superClass];

      // Add this subclass to the map so that next time this result is instant.
      [map setObject:object forKey:(id<NSCopying>)keyClass];
    }
  }

  if (nil == object) {
    // We couldn't find a mapping at all so let's add an empty mapping.
    [map setObject:[NSNull class] forKey:(id<NSCopying>)keyClass];

  } else if (object == [NSNull class]) {
    // Don't return null mappings.
    object = nil;
  }

  return object;
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
