//
// Copyright 2011-2014 NimbusKit
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
 * For creating standard system paths.
 *
 * @ingroup NimbusCore
 * @defgroup Paths Paths
 * @{
 */

/**
 * Create a path with the given bundle and the relative path appended.
 *
 * @param bundle        The bundle to append relativePath to. If nil, [NSBundle mainBundle]
 *                           will be used.
 * @param relativePath  The relative path to append to the bundle's path.
 *
 * @returns The bundle path concatenated with the given relative path.
 */
NSString* NIPathForBundleResource(NSBundle* bundle, NSString* relativePath);

/**
 * Create a path with the documents directory and the relative path appended.
 *
 * @returns The documents path concatenated with the given relative path.
 */
NSString* NIPathForDocumentsResource(NSString* relativePath);

/**
 * Create a path with the Library directory and the relative path appended.
 *
 * @returns The Library path concatenated with the given relative path.
 */
NSString* NIPathForLibraryResource(NSString* relativePath);

/**
 * Create a path with the caches directory and the relative path appended.
 *
 * @returns The caches path concatenated with the given relative path.
 */
NSString* NIPathForCachesResource(NSString* relativePath);

#if defined __cplusplus
};
#endif

/**@}*/// End of Paths ////////////////////////////////////////////////////////////////////////////
