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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @defgroup NimbusProcessors Nimbus Processors
 * @{
 *
 * Processors are for performing complex data manipulation on separate threads.
 *
 * Processing data is a potential bottleneck source for any application that manipulates data.
 * Older iPhone and iPod touch models get the worst of this with their slower processors
 * and smaller amounts of ram. As such, it's very important to attempt to push off any
 * data processing from the main UI thread. Nimbus processors provide a consistent means
 * of processing data in a defered way using threads.
 */

/**
 * @defgroup Network-Processors Network Processors
 *
 * Processors designed specifically for network access. These processors will process their
 * data after the data has been successfully downloaded, but before the request returns
 * the data to the main thread. This allows data to be processed after it has been downloaded
 * but before the UI has to deal with it.
 */

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusProcessors/NIProcessorHTTPRequest.h"
#import "NimbusProcessors/NIProcessorDelegate.h"
#else
#import "NIProcessorHTTPRequest.h"
#import "NIProcessorDelegate.h"
#endif

/**@}*/
