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

/**
 * Nimbus' Core library contains many often used utilities.
 *
 * @defgroup NimbusCore Nimbus Core
 * @{
 *
 * The Nimbus Core sets the foundation for all of Nimbus' other libraries. By establishing a
 * strong base of helpful utility methods and debugging tools, the rest of the libraries can
 * benefit from this code reuse and decreased time spent re-inventing the wheel.
 *
 * In your own projects, consider familiarizing yourself with Nimbus by first adding the
 * Core and feeling your way around. For existing projects this is especially recommended
 * because it allows you to gradually introduce concepts found within Nimbus.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef NIMBUS_STATIC_LIBRARY
// For when you're setting this library as a dependency in your project.
#import "NimbusCore/NIDataStructures.h"
#import "NimbusCore/NIDebuggingTools.h"
#import "NimbusCore/NIDeviceOrientation.h"
#import "NimbusCore/NIFoundationMethods.h"
#import "NimbusCore/NIInMemoryCache.h"
#import "NimbusCore/NINonEmptyCollectionTesting.h"
#import "NimbusCore/NINonRetainingCollections.h"
#import "NimbusCore/NIPaths.h"
#import "NimbusCore/NIPreprocessorMacros.h"
#import "NimbusCore/NIRuntimeClassModifications.h"
#import "NimbusCore/NISDKAvailability.h"

#else
// For when you're directly including this library in your project.
#import "NIDataStructures.h"
#import "NIDebuggingTools.h"
#import "NIDeviceOrientation.h"
#import "NIFoundationMethods.h"
#import "NIInMemoryCache.h"
#import "NINonEmptyCollectionTesting.h"
#import "NINonRetainingCollections.h"
#import "NIPaths.h"
#import "NIPreprocessorMacros.h"
#import "NIRuntimeClassModifications.h"
#import "NISDKAvailability.h"
#endif

/**@}*/
