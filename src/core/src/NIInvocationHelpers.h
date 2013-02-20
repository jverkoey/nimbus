//
//  NSInvocation+NimbusCore.h
//  Nimbus
//
//  Created by Metral, Max on 2/18/13.
//  Copyright (c) 2013 Jeff Verkoeyen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * NSInvocation extensions to make them easier to construct in concise code for things like button handlers
 * and such.
 */

/**
 * Construct an NSInvocation with an instance of an object and a selector
 */
extern NSInvocation* NIInvocationWithInstanceTarget(NSObject* target, SEL selector);

/**
 * Construct an NSInvocation for a class method given a class object and a selector
 */
extern NSInvocation* NIInvocationWithClassTarget(Class targetClass, SEL selector);
