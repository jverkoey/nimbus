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

#import <Foundation/Foundation.h>

@interface NSDate (NIUnitTesting)

/**
 * @brief Swizzle any methods used for unit testing.
 *
 * Required for certain unit test methods to work.
 *
 * Call this method again to undo the swizzling.
 */
+ (void)swizzleMethodsForUnitTesting;

/**
 * @brief Set the fake date to be used.
 *
 * This should be called before swizzling, otherwise you'll end up using the previous fake date
 * to create the new fake date causing unexpected results.
 *
 * Example use:
 *
 * @htmlonly
 * <pre>
 * [NSDate setFakeDate:[NSDate dateWithTimeIntervalSinceNow:2]];
 * [NSDate swizzleMethodsForUnitTesting];
 * // All calls to [NSDate date] will now return the fake date.
 * [NSDate swizzleMethodsForUnitTesting];
 * // All calls to [NSDate date] will again return the system's current date.
 * </pre>
 * @endhtmlonly
 */
+ (void)setFakeDate:(NSDate *)date;

@end
