//
// Copyright 2011 Max Metral
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

#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif
  
/**
 * For filling in gaps in Apple's Foundation framework.
 *
 * @ingroup NimbusCore
 * @defgroup NSInvocation-Methods NSInvocation Methods
 * @{
 *
 */
/**
 * NSInvocation extensions to make them easier to construct in concise code for things like button handlers
 * and such.
 */

/**
 * Construct an NSInvocation with an instance of an object and a selector
 *
 *  @return an NSInvocation that will call the given selector on the given target
 */
extern NSInvocation* NIInvocationWithInstanceTarget(NSObject* target, SEL selector);

/**
 * Construct an NSInvocation for a class method given a class object and a selector
 *
 *  @return an NSInvocation that will call the given class method/selector.
 */
extern NSInvocation* NIInvocationWithClassTarget(Class targetClass, SEL selector);

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Foundation Methods ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
