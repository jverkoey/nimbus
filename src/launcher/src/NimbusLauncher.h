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
 * Nimbus' Launcher view and related components.
 * @defgroup NimbusLauncher Nimbus Launcher
 * @{
 *
 * A launcher view is best exemplified in Apple's home screen interface. It consists of a set
 * of pages that each contain a set of buttons that the user may tap to access a consistent,
 * focused aspect of the application or operating system. The user may swipe the screen to the
 * left or right or tap the pager control at the bottom of the screen to change pages. A launcher
 * also allows its buttons to be repositioned using a tap and hold gesture (though this has not
 * been implemented yet in Nimbus' launcher, see the <a href="todo.html">todo list</a> for
 * more details).
 *
 * @image html NILauncherViewControllerExample1.png "Example of an NILauncherViewController as seen in the BasicLauncher demo application."
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 * The views and data containers used to display a launcher user interface.
 *
 * @defgroup Launcher-User-Interface User Interface
 *
 * The Nimbus launcher is composed primarily of the NILauncherView and its
 * @link Launcher-Protocols protocols@endlink. The
 * NILauncherViewController, NILauncherButton, and NILauncherItemDetails objects are all
 * auxiliary objects and exist purely to provide an example implementation of the
 * launcher view.
 *
 * <h3>Hacking Notes</h3>
 * As mentioned above, the meat of the launcher is contained in NILauncherView. If you want
 * to customize anything about it, start by subclassing NILauncherView. The launcher view is
 * built to mimic the design of UITableView in its use of a delegate and data source. This
 * design decision is a conscious one because it allows us to maintain the data for the launcher
 * view outside of the view itself. This allows the launcher view to be "dumb" and separates the
 * data used to populate the launcher from the presentation. When we inevitably receive a low
 * memory warning on a view controller that's off screen, we can discard the launcher view and
 * be confident that we won't lose any state information.
 */

/**
 * The delegate and data source protocols that allow the user interface to be simple.
 *
 * @defgroup Launcher-Protocols Protocols
 *
 * The launcher is related in spirit to UITableView in its use of protocols to remove much
 * of the heavy data and user interaction logic from the view itself. The NILauncherDelegate
 * protocol defines a small set of methods used for notifications of user interactions and
 * state changes. The NILauncherDataSource protocol defines the set of optional and
 * required methods for populating the launcher with data.
 */

// Dependencies
#import "NimbusCore.h"

#import "NILauncherViewController.h"
#import "NILauncherView.h"

/**@}*/
