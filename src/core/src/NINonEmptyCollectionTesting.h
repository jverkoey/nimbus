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
 * For testing whether a collection is of a certain type and is non-empty.
 *
 * @ingroup NimbusCore
 * @defgroup Non-Empty-Collection-Testing Non-Empty Collection Testing
 * @{
 *
 * Simply calling -count on an object may not yield the expected results when enumerating it if
 * certain assumptions are also made about the object's type. For example, if a JSON response
 * returns a dictionary when you expected an array, casting the result to an NSArray and
 * calling count will yield a positive value, but objectAtIndex: will crash the application.
 * These methods provide a safer check for non-emptiness of collections.
 */

/**
 * Tests if an object is a non-nil array which is not empty.
 */
BOOL NIIsArrayWithObjects(id object);

/**
 * Tests if an object is a non-nil set which is not empty.
 */
BOOL NIIsSetWithObjects(id object);

/**
 * Tests if an object is a non-nil string which is not empty.
 */
BOOL NIIsStringWithAnyText(id object);

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Non-Empty Collection Testing /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
