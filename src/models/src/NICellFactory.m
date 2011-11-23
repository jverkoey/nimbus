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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NICellFactory


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  UITableViewCell* cell = nil;

  // Only NICellObject-conformant objects may pass.
  if ([object respondsToSelector:@selector(cellClass)]) {
    Class cellClass = [object cellClass];
    NSString* identifier = NSStringFromClass(cellClass);

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
  }

  return cell;
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
+ (id)objectWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  return [[self alloc] initWithCellClass:cellClass userInfo:userInfo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithCellClass:(Class)cellClass {
  return [[self alloc] initWithCellClass:cellClass userInfo:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  if ((self = [super init])) {
    self.cellClass = cellClass;
    self.userInfo = userInfo;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass {
  return [self initWithCellClass:cellClass userInfo:nil];
}


@end
