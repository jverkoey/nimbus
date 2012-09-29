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

#import "NIRadioGroupController.h"
#import "NITableViewModel.h"
#import "NimbusCore.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static const NSInteger kInvalidSelection = NSIntegerMin;

@interface NIRadioGroup()
@property (nonatomic, readonly, weak) UIViewController* controller;
@property (nonatomic, readonly, retain) NSMutableDictionary* objectMap;
@property (nonatomic, readonly, retain) NSMutableSet* objectSet;
@property (nonatomic, readonly, retain) NSMutableArray* objectOrder;
@property (nonatomic, assign) BOOL hasSelection;
@property (nonatomic, readonly, retain) NSMutableSet* forwardDelegates;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIRadioGroup

@synthesize controller = _controller;
@synthesize delegate = _delegate;
@synthesize objectMap = _objectMap;
@synthesize objectSet = _objectSet;
@synthesize objectOrder = _objectOrder;
@synthesize hasSelection = _hasSelection;
@synthesize selectedIdentifier = _selectedIdentifier;
@synthesize tableViewCellSelectionStyle = _tableViewCellSelectionStyle;
@synthesize forwardDelegates = _forwardDelegates;
@synthesize cellTitle = _cellTitle;
@synthesize controllerTitle = _controllerTitle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(UIViewController *)controller {
  if ((self = [super init])) {
    _controller = controller;
    _objectMap = [[NSMutableDictionary alloc] init];
    _objectSet = [[NSMutableSet alloc] init];
    _objectOrder = [[NSMutableArray alloc] init];
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
- (id)keyForIdentifier:(NSInteger)identifier {
  return [NSNumber numberWithInt:identifier];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NICellObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)cellClass {
  return [NIRadioGroupCell class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellStyle)cellStyle {
  return UITableViewCellStyleValue1;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Forward Invocations


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelector:(SEL)selector {
  struct objc_method_description description;
  description = protocol_getMethodDescription(@protocol(UITableViewDelegate), selector, NO, YES);
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
- (id)mapObject:(id)object toIdentifier:(NSInteger)identifier {
  NIDASSERT(nil != object);
  NIDASSERT(identifier != kInvalidSelection);
  NIDASSERT(![self isObjectInRadioGroup:object]);
  if (nil == object) {
    return nil;
  }
  if (kInvalidSelection == identifier) {
    return nil;
  }
  if ([self isObjectInRadioGroup:object]) {
    return nil;
  }
  [self.objectMap setObject:object forKey:[self keyForIdentifier:identifier]];
  [self.objectSet addObject:object];
  [self.objectOrder addObject:object];
  return object;
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
- (NSArray *)allObjects {
  return [self.objectOrder copy];
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
    if ([self isObjectInRadioGroup:object]) {
      cell.accessoryType = ([self isObjectSelected:object]
                            ? UITableViewCellAccessoryCheckmark
                            : UITableViewCellAccessoryNone);
      cell.selectionStyle = self.tableViewCellSelectionStyle;
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

    if (object == self) {
      // You must provide a controller in the initWithController: initializer.
      NIDASSERT(nil != self.controller);

      NIRadioGroupController* controller = [[NIRadioGroupController alloc] initWithRadioGroup:self tappedCell:(id<NICell>)[tableView cellForRowAtIndexPath:indexPath]];
      controller.title = self.controllerTitle;

      BOOL shouldPush = YES;
      // Notify the delegate that the controller is about to appear.
      if ([self.delegate respondsToSelector:@selector(radioGroup:radioGroupController:willAppear:)]) {
        shouldPush = [self.delegate radioGroup:self radioGroupController:controller willAppear:YES];
      }

      if (shouldPush) {
        [self.controller.navigationController pushViewController:controller animated:YES];
      }

    } else if ([self isObjectInRadioGroup:object]) {
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

        [self.delegate radioGroup:self didSelectIdentifier:newSelection];
      }

      // Fade the selection out.
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
  }

  // Forward the invocation along.
  for (id<UITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
  }
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIRadioGroupCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.textLabel.text = nil;
  self.detailTextLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(NIRadioGroup *)radioGroup {
  self.selectionStyle = radioGroup.tableViewCellSelectionStyle;

  // You should provide a cell title for the radio group.
  NIDASSERT(NIIsStringWithAnyText(radioGroup.cellTitle));
  self.textLabel.text = radioGroup.cellTitle;

  if ([radioGroup.delegate respondsToSelector:@selector(radioGroup:textForIdentifier:)]) {
    self.detailTextLabel.text = [radioGroup.delegate radioGroup:radioGroup
                                              textForIdentifier:radioGroup.selectedIdentifier];
  }
  return YES;
}

@end
