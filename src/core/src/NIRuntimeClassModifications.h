//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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
 * For modifying class implementations at runtime.
 *
 * @ingroup NimbusCore
 * @defgroup Runtime-Class-Modifications Runtime Class Modifications
 * @{
 *
 *      @attention Please use caution when modifying class implementations at runtime.
 *                 Apple is prone to rejecting apps for gratuitous use of method swapping.
 *                 In particular, avoid swapping any NSObject methods such as dealloc, init,
 *                 and retain/release on UIKit classes.
 *
 * See example: @link ExampleRuntimeDebugging.m Runtime Debugging with Method Swizzling@endlink
 */

/**
 * Swap two class instance method implementations.
 *
 * Use this method when you would like to replace an existing method implementation in a class
 * with your own implementation at runtime. In practice this is often used to replace the
 * implementations of UIKit classes where subclassing isn't an adequate solution.
 *
 * This will only work for methods declared with a -.
 *
 * After calling this method, any calls to originalSel will actually call newSel and vice versa.
 *
 * Uses method_exchangeImplementations to accomplish this.
 */
void NISwapInstanceMethods(Class cls, SEL originalSel, SEL newSel);

/**
 * Swap two class method implementations.
 *
 * Use this method when you would like to replace an existing method implementation in a class
 * with your own implementation at runtime. In practice this is often used to replace the
 * implementations of UIKit classes where subclassing isn't an adequate solution.
 *
 * This will only work for methods declared with a +.
 *
 * After calling this method, any calls to originalSel will actually call newSel and vice versa.
 *
 * Uses method_exchangeImplementations to accomplish this.
 */
void NISwapClassMethods(Class cls, SEL originalSel, SEL newSel);

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Runtime Class Modifications //////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
