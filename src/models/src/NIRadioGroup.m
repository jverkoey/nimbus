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

#import "NIRadioGroup.h"

#import "NimbusCore.h"

static const NSInteger kInvalidSelection = NSIntegerMin;

@interface NIRadioGroup()
@property (nonatomic, readonly, retain) NSMutableDictionary* objectMap;
@property (nonatomic, readonly, retain) NSMutableSet* objectSet;
@property (nonatomic, readwrite, assign) BOOL hasSelection;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIRadioGroup

@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;
@synthesize hasSelection = _hasSelection;
@synthesize selectedIdentifier = _selectedIdentifier;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if ((self = [super init])) {
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)keyForIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInt:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapObject:(id)object toIdentifier:(NSInteger)identifier {
  NIDASSERT(nil != object);
  NIDASSERT(identifier != kInvalidSelection);
  NIDASSERT(![self isObjectInRadioGroup:object]);
  if (nil == object) {
    return;
  }
  if (kInvalidSelection == identifier) {
    return;
  }
  if ([self isObjectInRadioGroup:object]) {
    return;
  }
  [self.objectMap setObject:object forKey:[self keyForIdentifier:identifier]];
  [self.objectSet addObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedIdentifier:(NSInteger)selectedIdentifier {
  id key = [self keyForIdentifier:selectedIdentifier];
  NIDASSERT(nil != [self.objectMap objectForKey:key]);
  if (nil != [self.objectMap objectForKey:key]) {
    _selectedIdentifier = selectedIdentifier;
    self.hasSelection = YES;
  } else {
    // If we set an invalid identifier then clear the current selection.
    self.hasSelection = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)selectedIdentifier {
  return self.hasSelection ? _selectedIdentifier : kInvalidSelection;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)clearSelection {
  self.hasSelection = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectInRadioGroup:(id)object {
  if (nil == object) {
    return NO;
  }
  return [self.objectSet containsObject:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isObjectSelected:(id)object {
  if (nil == object) {
    return NO;
  }
  NIDASSERT(nil != object);
  NIDASSERT([self isObjectInRadioGroup:object]);
  NSArray* keys = [self.objectMap allKeysForObject:object];
  NSInteger selectedIdentifier = self.selectedIdentifier;
  for (NSNumber* key in keys) {
    if ([key intValue] == selectedIdentifier) {
      return YES;
    }
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)identifierForObject:(id)object {
  if (nil == object) {
    return NO;
  }
  NIDASSERT(nil != object);
  NIDASSERT([self isObjectInRadioGroup:object]);
  NSArray* keys = [self.objectMap allKeysForObject:object];
  return keys.count > 0 ? [[keys objectAtIndex:0] intValue] : kInvalidSelection;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willDisplayCell:(UITableViewCell *)cell forObject:(id)object {
  if ([self isObjectInRadioGroup:object]) {
    cell.accessoryType = ([self isObjectSelected:object]
                          ? UITableViewCellAccessoryCheckmark
                          : UITableViewCellAccessoryNone);
    return YES;
  }
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView*)tableView didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
  if ([self isObjectInRadioGroup:object]) {
    NSInteger newSelection = [self identifierForObject:object];

    if (newSelection != self.selectedIdentifier) {
      [self setSelectedIdentifier:newSelection];

      // It's easiest to simply reload the visible table cells. Reloading only the radio group
      // cells would require iterating through the visible cell objects and determining whether
      // each was in the radio group. This is more complex behavior that should be relegated to
      // the controller.
      [tableView reloadRowsAtIndexPaths:tableView.indexPathsForVisibleRows
                       withRowAnimation:UITableViewRowAnimationNone];

      // After we reload the table view the selection will be lost, so set the selection again.
      [tableView selectRowAtIndexPath:indexPath
                             animated:NO
                       scrollPosition:UITableViewScrollPositionNone];
      // And then fade the selection out.
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      return YES;
    }
  }
  return NO;
}

@end
