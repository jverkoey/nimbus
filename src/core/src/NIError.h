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
#import <UIKit/UIKit.h>

/**
 * For defining various error types used throughout the Nimbus framework.
 *
 * @ingroup NimbusCore
 * @defgroup Errors Errors
 * @{
 */

/** The Nimbus error domain. */
extern NSString* const NINimbusErrorDomain;

/** The key used for images in the error's userInfo. */
extern NSString* const NIImageErrorKey;

/** NSError codes in NINimbusErrorDomain. */
typedef enum {
  /** The image is too small to be used. */
  NIImageTooSmall = 1,
} NINimbusErrorDomainCode;


/**@}*/// End of Errors ///////////////////////////////////////////////////////////////////////////

/**
 * <h3>Example</h3>
 *
 * @code
 * error = [NSError errorWithDomain: NINimbusErrorDomain
 *                             code: NIImageTooSmall
 *                         userInfo: [NSDictionary dictionaryWithObject: image
 *                                                               forKey: NIImageErrorKey]];
 * @endcode
 *
 * @enum NINimbusErrorDomainCode
 */
