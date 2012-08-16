//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "NILauncherView.h"

/**
 * The NILauncherViewController class creates a controller object that manages a launcher view.
 * It implements the following behavior:
 *
 * - It creates an unconfigured NILauncherView object with the correct dimensions and autoresize
 *   mask. You can access this view through the launcherView property.
 * - NILauncherViewController sets the data source and the delegate of the launcher view to self.
 * - When the launcher view is about to appear the first time it’s loaded, the launcher-view
 *   controller reloads the launcher view’s data.
 *
 * @image html NILauncherViewControllerExample1.png "Example of an NILauncherViewController."
 *
 *      @ingroup NimbusLauncher
 */
@interface NILauncherViewController : UIViewController <NILauncherDelegate, NILauncherDataSource>

@property (nonatomic, readwrite, retain) NILauncherView* launcherView;

@end

/** @name Accessing the Launcher View */

/**
 * Returns the launcher view managed by the controller object.
 *
 *      @fn NILauncherViewController::launcherView
 */
