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
 * @defgroup NimbusNetworkControllers Nimbus Network Controllers
 * @{
 *
 * <div id="github" feature="networkcontrollers"></div>
 *
 * View controllers that display loading states while they load information from the network or
 * disk.
 *
 * Whether you are loading data from the disk or from the network, it is important to present
 * the fact that information is loading to your user. This ensures that your application feels
 * responsive and also comforts the user by letting them know that your application is working
 * on something.
 *
 * The Nimbus network controllers are designed to provide functionality for the most common states
 * used when loading resources asynchronously. These states include:
 *
 * - Fresh load: when no data exists and we are loading new data.
 * - Refresh load: when data exists and we are reloading new data.
 * - Error: the previous request failed.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NINetworkTableViewController.h"

/**@}*/
