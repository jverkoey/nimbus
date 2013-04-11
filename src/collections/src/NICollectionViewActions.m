//
// Copyright 2013 Jeff Verkoeyen
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

#import "NICollectionViewActions.h"

#import "NICollectionViewCellFactory.h"
#import "NimbusCore.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NICollectionViewAction : NSObject

@property (nonatomic, copy) NICollectionViewActionBlock tapAction;
@property (nonatomic, assign) SEL tapSelector;

@end

@interface NICollectionViewActions()

@property (nonatomic, NI_WEAK) id target;
@property (nonatomic, NI_STRONG) NSMutableSet* forwardDelegates;
@property (nonatomic, NI_STRONG) NSMutableDictionary* objectMap;
@property (nonatomic, NI_STRONG) NSMutableSet* objectSet;
@property (nonatomic, NI_STRONG) NSMutableDictionary* classMap;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewActions

@synthesize target = _target;
@synthesize forwardDelegates = _forwardDelegates;
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
- (NICollectionViewAction *)actionForObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NICollectionViewAction* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [[NICollectionViewAction alloc] init];
    [self.objectMap setObject:action forKey:key];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NICollectionViewAction *)actionForClass:(Class)class {
  NICollectionViewAction* action = [self.classMap objectForKey:class];
  if (nil == action) {
    action = [[NICollectionViewAction alloc] init];
    [self.classMap setObject:action forKey:(id<NSCopying>)class];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NICollectionViewAction *)actionForObjectOrClassOfObject:(id<NSObject>)object {
  id key = [self keyForObject:object];
  NICollectionViewAction* action = [self.objectMap objectForKey:key];
  if (nil == action) {
    action = [NICollectionViewCellFactory objectFromKeyClass:object.class map:self.classMap];
  }
  return action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelector:(SEL)selector {
  struct objc_method_description description;
  description = protocol_getMethodDescription(@protocol(UICollectionViewDelegate), selector, NO, YES);
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
- (id<UICollectionViewDelegate>)forwardingTo:(id<UICollectionViewDelegate>)forwardDelegate {
  [self.forwardDelegates addObject:forwardDelegate];
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeForwarding:(id<UICollectionViewDelegate>)forwardDelegate {
  [self.forwardDelegates removeObject:forwardDelegate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object tapBlock:(NICollectionViewActionBlock)action {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapAction = action;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)attachToObject:(id<NSObject>)object tapSelector:(SEL)selector {
  [self.objectSet addObject:object];
  [self actionForObject:object].tapSelector = selector;
  return object;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass tapBlock:(NICollectionViewActionBlock)action {
  [self actionForClass:aClass].tapAction = action;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)attachToClass:(Class)aClass tapSelector:(SEL)selector {
  [self actionForClass:aClass].tapSelector = selector;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectActionable:(id<NSObject>)object {
  if (nil == object) {
    return NO;
  }

  BOOL objectIsActionable = [self.objectSet containsObject:object];
  if (!objectIsActionable) {
    objectIsActionable = (nil != [NICollectionViewCellFactory objectFromKeyClass:object.class map:self.classMap]);
  }
  return objectIsActionable;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UICollectionViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  BOOL shouldHighlight = YES;

  // Forward the invocation along.
  for (id<UICollectionViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      if (![delegate collectionView:collectionView shouldHighlightItemAtIndexPath:indexPath]) {
        shouldHighlight = NO;
      }
    }
  }

  NIDASSERT([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]);
  if ([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]
      && shouldHighlight) {
    NICollectionViewModel* model = (NICollectionViewModel *)collectionView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NICollectionViewAction* action = [self actionForObjectOrClassOfObject:object];

      // If the cell is tappable, reflect that in the selection style.
      if (!action.tapAction && !action.tapSelector) {
        shouldHighlight = NO;
      }
    }
  }

  return shouldHighlight;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]);
  if ([collectionView.dataSource isKindOfClass:[NICollectionViewModel class]]) {
    NICollectionViewModel* model = (NICollectionViewModel *)collectionView.dataSource;
    id object = [model objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NICollectionViewAction* action = [self actionForObjectOrClassOfObject:object];

      BOOL shouldDeselect = NO;
      if (action.tapAction) {
        // Tap actions can deselect the cell if they return YES.
        shouldDeselect = action.tapAction(object, self.target, indexPath);
      }
      if (action.tapSelector && [self.target respondsToSelector:action.tapSelector]) {
        NSMethodSignature *methodSignature = [self.target methodSignatureForSelector:action.tapSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = action.tapSelector;
        if (methodSignature.numberOfArguments >= 3) {
          [invocation setArgument:&object atIndex:2];
        }
        if (methodSignature.numberOfArguments >= 4) {
          [invocation setArgument:&indexPath atIndex:3];
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
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
      }
    }
  }

  // Forward the invocation along.
  for (id<UICollectionViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
  }
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewAction

@synthesize tapAction;
@synthesize tapSelector;

@end
