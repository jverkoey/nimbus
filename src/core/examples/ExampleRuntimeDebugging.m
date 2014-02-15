//
// Copyright 2011-2014 NimbusKit
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

/**
 * @example ExampleRuntimeDebugging.m
 *
 * Modifying class methods at runtime can be a very powerful debugging tool. Consider the
 * following example:
 *
 * You are finding that you have a memory leak with one of your view controllers, but you're
 * not sure where the extra retain is being made. If you swap the retain implementation on
 * UIViewController with your own method then you can set a breakpoint in the method and look
 * at the stack each time retain is called. This method is similar to setting a breakpoint
 * in GDB on the UIViewController's retain method but allows programmatic control over when you
 * want to hit the breakpoint.
 *
 * This example is part of @link Runtime-Class-Modifications Runtime Class Modifications@endlink.
 */

@interface UIViewController()

- (id)_retain;

@end


@implementation UIViewController()

- (id)_retain {
  // _retain has been swizzled so calling _retain here will actually call retain.
  [self _retain]; // Set a breakpoint here.
}

@end


- (BOOL)              application: (UIApplication *)application
    didFinishLaunchingWithOptions: (NSDictionary *)options {

  // Swap the default retain implementation with our custom implementation with which we can
  // visually set a breakpoint.
  NISwapInstanceMethods([UIViewController class], @selector(retain), @selector(_retain));

}
