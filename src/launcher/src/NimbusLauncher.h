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
 * @brief Nimbus' Launcher control and related components.
 * @defgroup NimbusLauncher Nimbus Launcher
 * @{
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * @brief Launcher user interface.
 * @defgroup Launcher-User-Interface Launcher User Interface
 */

/**
 * @brief Launcher protocols.
 * @defgroup Launcher-Protocols Launcher Protocols
 */

/**
 * @brief Launcher presentation information.
 * @defgroup Launcher-Presentation-Information Launcher Presentation Information
 */

#ifdef BASE_PRODUCT_NAME
#import "NimbusLauncher/NILauncherViewController.h"
#import "NimbusLauncher/NILauncherView.h"
#else
#import "NILauncherViewController.h"
#import "NILauncherView.h"
#endif


/**@}*/
