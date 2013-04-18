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

#import "NICellFactory.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NICellFactory()
@property (nonatomic, copy) NSMutableDictionary* objectToCellMap;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICellFactory

@synthesize objectToCellMap = _objectToCellMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _objectToCellMap = [[NSMutableDictionary alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UITableViewCell *)cellWithClass:(Class)cellClass
                         tableView:(UITableView *)tableView
                            object:(id)object {
  UITableViewCell* cell = nil;

  NSString* identifier = NSStringFromClass(cellClass);

  if ([cellClass respondsToSelector:@selector(shouldAppendObjectClassToReuseIdentifier)]
      && [cellClass shouldAppendObjectClassToReuseIdentifier]) {
    identifier = [identifier stringByAppendingFormat:@".%@", NSStringFromClass([object class])];
  }

  cell = [tableView dequeueReusableCellWithIdentifier:identifier];

  if (nil == cell) {
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if ([object respondsToSelector:@selector(cellStyle)]) {
      style = [object cellStyle];
    }
    cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:identifier];
  }

  // Allow the cell to configure itself with the object's information.
  if ([cell respondsToSelector:@selector(shouldUpdateCellWithObject:)]) {
    [(id<NICell>)cell shouldUpdateCellWithObject:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
  UITableViewCell* cell = nil;

  // If this assertion fires then your app is about to crash. You need to either add an explicit
  // binding in a NICellFactory object or implement the NICellObject protocol on this object and
  // return a cell class.
  NIDASSERT([object respondsToSelector:@selector(cellClass)]);

  // Only NICellObject-conformant objects may pass.
  if ([object respondsToSelector:@selector(cellClass)]) {
    Class cellClass = [object cellClass];
    cell = [self cellWithClass:cellClass tableView:tableView object:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClassFromObject:(id)object {
  if (nil == object) {
    return nil;
  }
  Class objectClass = [object class];
  Class cellClass = [self.objectToCellMap objectForKey:objectClass];

  BOOL hasExplicitMapping = (nil != cellClass && cellClass != [NSNull class]);

  if (!hasExplicitMapping && [object respondsToSelector:@selector(cellClass)]) {
    cellClass = [object cellClass];
  }

  if (nil == cellClass) {
    cellClass = [NIActions objectFromKeyClass:objectClass map:self.objectToCellMap];
  }

  return cellClass;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel:(NITableViewModel *)tableViewModel
                   cellForTableView:(UITableView *)tableView
                        atIndexPath:(NSIndexPath *)indexPath
                         withObject:(id)object {
  UITableViewCell* cell = nil;

  Class cellClass = [self cellClassFromObject:object];

  // If this assertion fires then your app is about to crash. You need to either add an explicit
  // binding in a NICellFactory object or implement the NICellObject protocol on this object and
  // return a cell class.
  NIDASSERT(nil != cellClass);

  if (nil != cellClass) {
    cell = [[self class] cellWithClass:cellClass tableView:tableView object:object];
  }
  
  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObjectClass:(Class)objectClass toCellClass:(Class)cellClass {
  [self.objectToCellMap setObject:cellClass forKey:(id<NSCopying>)objectClass];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath model:(NITableViewModel *)model {
  CGFloat height = tableView.rowHeight;
  id object = [model objectAtIndexPath:indexPath];
  Class cellClass = [self cellClassFromObject:object];
  if ([cellClass respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
    CGFloat cellHeight = [cellClass heightForObject:object
                                        atIndexPath:indexPath tableView:tableView];
    if (cellHeight > 0) {
      height = cellHeight;
    }
  }
  return height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath model:(NITableViewModel *)model {
  CGFloat height = tableView.rowHeight;
  id object = [model objectAtIndexPath:indexPath];
  Class cellClass = nil;
  if ([object respondsToSelector:@selector(cellClass)]) {
    cellClass = [object cellClass];
  }
  if ([cellClass respondsToSelector:@selector(heightForObject:atIndexPath:tableView:)]) {
    CGFloat cellHeight = [cellClass heightForObject:object
                                        atIndexPath:indexPath tableView:tableView];
    if (cellHeight > 0) {
      height = cellHeight;
    }
  }
  return height;
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NICellObject()
@property (nonatomic, assign) Class cellClass;
@property (nonatomic, NI_STRONG) id userInfo;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICellObject

@synthesize cellClass = _cellClass;
@synthesize userInfo = _userInfo;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  if ((self = [super init])) {
    _cellClass = cellClass;
    _userInfo = userInfo;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass {
  return [self initWithCellClass:cellClass userInfo:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  return [[self alloc] initWithCellClass:cellClass userInfo:userInfo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)cellClass {
  return [[self alloc] initWithCellClass:cellClass userInfo:nil];
}


@end
