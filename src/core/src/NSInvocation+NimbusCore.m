//
//  NSInvocation+NimbusCore.m
//  Nimbus
//
//  Copyright (c) 2013 Jeff Verkoeyen. All rights reserved.
//

#import "NSInvocation+NimbusCore.h"
#import <objc/runtime.h>

NI_FIX_CATEGORY_BUG(NSInvocation_NimbusCore)

@implementation NSInvocation (NimbusCore)

+ (id)invocationWithTarget:(NSObject*)targetObject selector:(SEL)selector {
  NSMethodSignature* sig = [targetObject methodSignatureForSelector:selector];
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
  [inv setTarget:targetObject];
  [inv setSelector:selector];
  return inv;
}

+ (id)invocationWithClass:(Class)targetClass selector:(SEL)selector {
  Method method = class_getInstanceMethod(targetClass, selector);
  struct objc_method_description* desc = method_getDescription(method);
  if (desc == NULL || desc->name == NULL)
    return nil;
  
  NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:desc->types];
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
  [inv setSelector:selector];
  return inv;
}

@end
