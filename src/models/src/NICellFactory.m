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

@interface NICellFactory()
@property (nonatomic, readwrite, copy) NSMutableDictionary* objectToCellMap;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICellFactory

@synthesize objectToCellMap = _objectToCellMap;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_objectToCellMap);

  [super dealloc];
}


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

  cell = [tableView dequeueReusableCellWithIdentifier:identifier];

  if (nil == cell) {
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if ([object respondsToSelector:@selector(cellStyle)]) {
      style = [object cellStyle];
    }
    cell = [[[cellClass alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
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

  // Only NICellObject-conformant objects may pass.
  if ([object respondsToSelector:@selector(cellClass)]) {
    Class cellClass = [object cellClass];
    cell = [self cellWithClass:cellClass tableView:tableView object:object];
  }

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  UITableViewCell* cell = nil;

  Class objectClass = [object class];
  Class cellClass = [self.objectToCellMap objectForKey:objectClass];

  // Explicit mappings override implicit mappings.
  if (nil != cellClass) {
    cell = [[self class] cellWithClass:cellClass tableView:tableView object:object];

  } else {
    cell = [[self class] tableViewModel:tableViewModel
                       cellForTableView:tableView
                            atIndexPath:indexPath
                             withObject:object];
  }
  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObjectClass:(Class)objectClass toCellClass:(Class)cellClass {
  [self.objectToCellMap setObject:cellClass forKey:objectClass];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NICellObject()
@property (nonatomic, readwrite, assign) Class cellClass;
@property (nonatomic, readwrite, retain) id userInfo;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICellObject

@synthesize cellClass = _cellClass;
@synthesize userInfo = _userInfo;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_userInfo);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  if ((self = [super init])) {
    _cellClass = cellClass;
    _userInfo = [userInfo retain];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass {
  return [self initWithCellClass:cellClass userInfo:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  return [[[self alloc] initWithCellClass:cellClass userInfo:userInfo] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)cellClass {
  return [[[self alloc] initWithCellClass:cellClass userInfo:nil] autorelease];
}


@end
