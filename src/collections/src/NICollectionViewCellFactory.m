//
// Copyright 2011 Jeff Verkoeyen
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

#import "NICollectionViewCellFactory.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NICollectionViewCellFactory()
@property (nonatomic, copy) NSMutableDictionary* objectToCellMap;
@property (nonatomic, copy) NSMutableSet* registeredObjectClasses;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewCellFactory

@synthesize objectToCellMap = _objectToCellMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _objectToCellMap = [[NSMutableDictionary alloc] init];
    _registeredObjectClasses = [[NSMutableSet alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UICollectionViewCell *)cellWithClass:(Class)collectionViewCellClass
                         collectionView:(UICollectionView *)collectionView
                              indexPath:(NSIndexPath *)indexPath
                                 object:(id)object {
  UICollectionViewCell* cell = nil;

  NSString* identifier = NSStringFromClass(collectionViewCellClass);

  cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

  // Allow the cell to configure itself with the object's information.
  if ([cell respondsToSelector:@selector(shouldUpdateCellWithObject:)]) {
    [(id<NICollectionViewCell>)cell shouldUpdateCellWithObject:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                   cellForCollectionView:(UICollectionView *)collectionView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
  UICollectionViewCell* cell = nil;

  // If this assertion fires then your app is about to crash. You need to either add an explicit
  // binding in a NICollectionViewCellFactory object or implement the NICollectionViewCellObject protocol on this object and
  // return a cell class.
  NIDASSERT([object respondsToSelector:@selector(collectionViewCellClass)]);

  // Only NICollectionViewCellObject-conformant objects may pass.
  if ([object respondsToSelector:@selector(collectionViewCellClass)]) {
    Class collectionViewCellClass = [object collectionViewCellClass];
    cell = [self cellWithClass:collectionViewCellClass collectionView:collectionView indexPath:indexPath object:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)collectionViewCellClassFromObject:(id)object {
  if (nil == object) {
    return nil;
  }
  Class objectClass = [object class];
  Class collectionViewCellClass = [self.objectToCellMap objectForKey:objectClass];

  BOOL hasExplicitMapping = (nil != collectionViewCellClass && collectionViewCellClass != [NSNull class]);

  if (!hasExplicitMapping && [object respondsToSelector:@selector(collectionViewCellClass)]) {
    collectionViewCellClass = [object collectionViewCellClass];
  }

  if (nil == collectionViewCellClass) {
    collectionViewCellClass = [self.class objectFromKeyClass:objectClass map:self.objectToCellMap];
  }

  return collectionViewCellClass;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel
                   cellForCollectionView:(UICollectionView *)collectionView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
  UICollectionViewCell* cell = nil;

  Class collectionViewCellClass = [self collectionViewCellClassFromObject:object];

  // If this assertion fires then your app is about to crash. You need to either add an explicit
  // binding in a NICollectionViewCellFactory object or implement the NICollectionViewCellObject protocol on this object and
  // return a cell class.
  NIDASSERT(nil != collectionViewCellClass);

  if (nil != collectionViewCellClass) {
    cell = [[self class] cellWithClass:collectionViewCellClass collectionView:collectionView indexPath:indexPath object:object];
  }
  
  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObjectClass:(Class)objectClass toCellClass:(Class)collectionViewCellClass {
  [self.objectToCellMap setObject:collectionViewCellClass forKey:(id<NSCopying>)objectClass];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewCellFactory (KeyClassMapping)


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
@interface NICollectionViewCellObject()
@property (nonatomic, assign) Class collectionViewCellClass;
@property (nonatomic, NI_STRONG) id userInfo;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICollectionViewCellObject

@synthesize collectionViewCellClass = _collectionViewCellClass;
@synthesize userInfo = _userInfo;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)collectionViewCellClass userInfo:(id)userInfo {
  if ((self = [super init])) {
    _collectionViewCellClass = collectionViewCellClass;
    _userInfo = userInfo;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)collectionViewCellClass {
  return [self initWithCellClass:collectionViewCellClass userInfo:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)collectionViewCellClass userInfo:(id)userInfo {
  return [[self alloc] initWithCellClass:collectionViewCellClass userInfo:userInfo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)collectionViewCellClass {
  return [[self alloc] initWithCellClass:collectionViewCellClass userInfo:nil];
}


@end
