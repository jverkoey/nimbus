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

#import "NIUserInterfaceString.h"
#import "NIDebuggingTools.h"
#import <objc/runtime.h>

static NSMutableDictionary*               sStringToViewMap;
static char                               sBaseStringAssocationKey;
static id<NIUserInterfaceStringResolver>  sResolver;

NSString* const NIStringsDidChangeNotification = @"NIStringsDidChangeNotification";
NSString* const NIStringsDidChangeFilePathKey = @"NIStringsPathKey";

////////////////////////////////////////////////////////////////////////////////
/**
 * Information about an attachment
 */
@interface NIUserInterfaceStringAttachment : NSObject
@property (unsafe_unretained,nonatomic) id element;
@property (assign) SEL setter;
@property (assign) UIControlState controlState;
@property (assign) BOOL setterIsWithControlState;
-(void)attach: (NSString*) value;
@end

////////////////////////////////////////////////////////////////////////////////
/**
 * This class exists solely to be attached to objects that strings have been
 * attached to so that we can easily detach them on dealloc
 */
@interface NIUserInterfaceStringDeallocTracker : NSObject
+(void)attachString: (NIUserInterfaceString*) string withInfo: (NIUserInterfaceStringAttachment*) attachment;
@property (strong, nonatomic) NIUserInterfaceStringAttachment *attachment;
@property (strong, nonatomic) NIUserInterfaceString *string;
@end

////////////////////////////////////////////////////////////////////////////////
@interface NIUserInterfaceStringResolverDefault : NSObject <
NIUserInterfaceStringResolver
>
// The path of a file that was loaded from Chameleon that should be checked first
// before the built in bundle
@property (nonatomic,strong) NSDictionary *overrides;
// For dev/debug purposes, if we read "/* SHOW KEYS */" at the front of the file, we'll
// just return all keys in the UI
@property (nonatomic,assign) BOOL returnKeys;
@end

////////////////////////////////////////////////////////////////////////////////
@implementation NIUserInterfaceString

+(void)setStringResolver:(id<NIUserInterfaceStringResolver>)stringResolver
{
  sResolver = stringResolver;
}

+(id<NIUserInterfaceStringResolver>)stringResolver
{
  return sResolver ?: (sResolver = [[NIUserInterfaceStringResolverDefault alloc] init]);
}

-(NSMutableDictionary*) viewMap
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sStringToViewMap = [[NSMutableDictionary alloc] init];
  });
  return sStringToViewMap;
}

////////////////////////////////////////////////////////////////////////////////
-(id)initWithKey:(NSString *)key
{
  return [self initWithKey:key defaultValue:nil];
}

-(id)initWithKey:(NSString *)key defaultValue: (NSString*) value
{
  NSString *v =[[NIUserInterfaceString stringResolver] stringForKey:key withDefaultValue:value];
  if (!v) { return nil; }
  
  self = [super init];
  if (self) {
    _string = v;
    _originalKey = key;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////
-(void)attach:(UIView *)view
{
  if ([view respondsToSelector:@selector(setText:)]) {
    // UILabel
    [self attach: view withSelector:@selector(setText:)];
  } else if ([view respondsToSelector:@selector(setTitle:forState:)]) {
    [self attach:view withSelector:@selector(setTitle:forState:) withControlState:UIControlStateNormal hasControlState:YES];
  } else if ([view respondsToSelector:@selector(setTitle:)]) {
    [self attach: view withSelector:@selector(setTitle:)];
  } else {
    NIDASSERT([view respondsToSelector:@selector(setText:)] || [view respondsToSelector:@selector(setTitle:)]);
  }
}

////////////////////////////////////////////////////////////////////////////////
-(void)attach:(id)element withSelector:(SEL)selector
{
  [self attach:element withSelector:selector withControlState:UIControlStateNormal hasControlState:NO];
}

////////////////////////////////////////////////////////////////////////////////
-(void)attach:(UIView *)view withSelector:(SEL)selector forControlState:(UIControlState)state
{
  [self attach:view withSelector:selector withControlState:state hasControlState:YES];
}

////////////////////////////////////////////////////////////////////////////////
-(void)attach:(id)element withSelector:(SEL)selector withControlState: (UIControlState) state hasControlState: (BOOL) hasControlState
{
  NIUserInterfaceStringAttachment *attachment = [[NIUserInterfaceStringAttachment alloc] init];
  attachment.element = element;
  attachment.controlState = state;
  attachment.setterIsWithControlState = hasControlState;
  attachment.setter = selector;
  
  // If we're keeping track of attachments, set all that up. Else just call the selector
  if ([[NIUserInterfaceString stringResolver] isChangeTrackingEnabled]) {
    NSMutableDictionary *viewMap =  self.viewMap;
    @synchronized (viewMap) {
      // Call this first, because if there's an existing association, it will detach it in dealloc
      [NIUserInterfaceStringDeallocTracker attachString:self withInfo:attachment];
      id existing = [viewMap objectForKey:_originalKey];
      if (!existing) {
        // Simple, no map exists, make one
        [viewMap setObject:attachment forKey:_originalKey];
      } else if ([existing isKindOfClass: [NIUserInterfaceStringAttachment class]]) {
        // An attachment exists, convert it to a list
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:2];
        [list addObject:existing];
        [list addObject:attachment];
        [viewMap setObject:list forKey:_originalKey];
      } else {
        // NSMutableArray*
        NSMutableArray *a = (NSMutableArray*) existing;
        [a addObject: attachment];
      }
    }
  }
  [attachment attach: _string];
}

////////////////////////////////////////////////////////////////////////////////
-(void)detach:(UIView *)view
{
  if ([view respondsToSelector:@selector(setText:)]) {
    // UILabel
    [self detach: view withSelector:@selector(setText:) withControlState:UIControlStateNormal hasControlState:NO];
  } else if ([view respondsToSelector:@selector(setTitle:)]) {
    [self detach: view withSelector:@selector(setTitle:) withControlState:UIControlStateNormal hasControlState:NO];
  } else {
    NIDASSERT([view respondsToSelector:@selector(setText:)] || [view respondsToSelector:@selector(setTitle:)]);
  }
  
}

-(void)detach:(id)element withSelector:(SEL)selector
{
  [self detach:element withSelector:selector withControlState:UIControlStateNormal hasControlState:NO];
}

-(void)detach:(UIView *)element withSelector:(SEL)selector forControlState:(UIControlState)state
{
  [self detach:element withSelector:selector withControlState:state hasControlState:YES];
}

-(void)detach:(id)element withSelector:(SEL)selector withControlState: (UIControlState) state hasControlState: (BOOL) hasControlState
{
  NSMutableDictionary *viewMap = self.viewMap;
  @synchronized (viewMap) {
    
  }
}

@end

////////////////////////////////////////////////////////////////////////////////
@implementation NIUserInterfaceStringResolverDefault

-(id)init
{
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stringsDidChange:) name:NIStringsDidChangeNotification object:nil];
  }
  return self;
}

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)stringsDidChange: (NSNotification*) notification
{
  NSString *path = [notification.userInfo objectForKey:NIStringsDidChangeFilePathKey];
  NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

  if ([content hasPrefix:@"/* SHOW KEYS */"]) {
    self.returnKeys = YES;
  } else {
    self.returnKeys = NO;
  }
  self.overrides = [[NSDictionary alloc] initWithContentsOfFile:path];
  if (sStringToViewMap && self.overrides.count > 0) {
    @synchronized (sStringToViewMap) {
      [sStringToViewMap enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        NSString *o = self.returnKeys ? key : [self.overrides objectForKey:key];
        if (o) {
          if ([obj isKindOfClass:[NIUserInterfaceStringAttachment class]]) {
            [((NIUserInterfaceStringAttachment*)obj) attach: o];
          } else {
            NSArray *attachments = (NSArray*) obj;
            for (NIUserInterfaceStringAttachment *a in attachments) {
              [a attach:o];
            }
          }
        }
      }];
    }
  }
}

-(NSString *)stringForKey:(NSString *)key withDefaultValue:(NSString *)value
{
  if (self.returnKeys) {
    return key; // TODO should we maybe return 
  }
  if (self.overrides) {
    NSString *overridden = [self.overrides objectForKey:key];
    if (overridden) {
      return overridden;
    }
  }
  return NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], value, nil);
}

-(BOOL)isChangeTrackingEnabled
{
#ifdef DEBUG
  return YES;
#else
  return NO;
#endif
}
@end

////////////////////////////////////////////////////////////////////////////////
@implementation NIUserInterfaceStringAttachment
-(void)attach: (NSString*) value
{
  if (self.setterIsWithControlState) {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[_element methodSignatureForSelector:_setter]];
    [inv setSelector:_setter];
    [inv setTarget:_element];
    [inv setArgument:&value atIndex:2]; //this is the string to set (0 and 1 are self and message respectively)
    [inv setArgument:&_controlState atIndex:3];
    [inv invoke];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_element performSelector:_setter withObject:value];
#pragma clang diagnostic pop
  }
}
@end

////////////////////////////////////////////////////////////////////////////////
@implementation NIUserInterfaceStringDeallocTracker
+(void)attachString:(NIUserInterfaceString *)string withInfo:(NIUserInterfaceStringAttachment *)attachment
{
  NIUserInterfaceStringDeallocTracker *tracker = [[NIUserInterfaceStringDeallocTracker alloc] init];
  tracker.attachment = attachment;
  tracker.string = string;
  char* key = &sBaseStringAssocationKey;
  if (attachment.setterIsWithControlState) {
    key += attachment.controlState;
  }
  objc_setAssociatedObject(attachment.element, key, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)dealloc
{
  [self.string detach:self.attachment.element withSelector:self.attachment.setter withControlState:self.attachment.controlState hasControlState:self.attachment.setterIsWithControlState];
}
@end