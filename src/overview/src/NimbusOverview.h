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

/**
 * @defgroup NimbusOverview Nimbus Overview
 * @{
 *
 * <div id="github" feature="overview"></div>
 *
 * The Overview is a debugging tool for quickly understanding the current state of your
 * application. When added to an application, it will insert a paged
 * scroll view beneath the status bar that contains any number of pages of information.
 * These pages can show anything from graphs of current memory usage to console logs to
 * configuration settings.
 *
 * @image html overview1.png "The Overview added to the network photo album app."
 *
 *
 * <h2>Built-in Overview Pages</h2>
 *
 * The Overview comes with a few basic pages for viewing the device state and console logs.
 *
 *
 * <h3>NIOverviewMemoryPageView</h3>
 *
 * @image html overview-memory1.png "The memory page."
 *
 * This page shows a graph of the relative available memory on the device.
 *
 *
 * <h3>NIOverviewDiskPageView</h3>
 *
 * @image html overview-disk1.png "The disk page."
 *
 * This page shows a graph of the relative available disk space on the device.
 *
 *
 * <h3>NIOverviewConsoleLogPageView</h3>
 *
 * @image html overview-log1.png "The log page."
 *
 * This page shows all messages sent to NSLog since the Overview was initialized.
 *
 *
 * <h3>NIOverviewMaxLogLevelPageView</h3>
 *
 * @image html overview-maxloglevel1.png "The max log level page."
 *
 * This page allows you to modify NIMaxLogLevel while the app is running.
 *
 *
 * <h2>How to Use the Overview</h2>
 *
 * To begin using the Overview you need to add two lines of code to your app and define
 * DEBUG in your applicaton's preprocessor macros Debug target settings.
 *
 * @code
 - (BOOL)              application:(UIApplication *)application
 *    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 *  // Line #1 - Swizzles the necessary methods for making the Overview appear as part of the
 *  // the status bar.
 *  [NIOverview applicationDidFinishLaunching];
 *
 *  // After you create the UIWindow for your application and add the root view controller,
 *  // i.e.:
 *  [self.window addSubview:_rootViewController.view];
 *
 *  // then you add the Overview view to the window.
 *  [NIOverview addOverviewToWindow:self.window];
 * @endcode
 *
 *
 * <h2>Events</h2>
 *
 * Certain events are useful in providing context while debugging an application. When a
 * memory warning is received it can be helpful to see how much memory was released. for example.
 *
 * The Overview visually presents events on Overview graphs as vertical lines. Memory warnings
 * are red.
 *
 * In the screenshot below, you can see when a memory warning occurred and the resulting
 * increase in available memory.
 *
 * @image html overview-memorywarning1.png "A memory warning received on the iPad is shown with a vertical red line."
 *
 * <h2>How the Overview is Displayed</h2>
 *
 * The Overview is displayed by tricking the application into thinking that the status bar is
 * 60 pixels larger than it actually is. If your app respects the status bar frame correctly
 * then the Overview will always be visible above the chrome of your application, directly
 * underneath the status bar. If the status bar is hidden, the Overview will also be hidden.
 *
 *
 * <h2>Creating a Custom Page</h2>
 *
 * You can build your own page by subclassing NIOverviewPageView and adding it to the
 * overview via [[NIOverview @link NIOverview::view view@endlink] @link NIOverviewView::addPageView: addPageView:@endlink].
 */

/**
 * The sensors used to power the Overview.
 *
 *      @defgroup Overview-Sensors Sensors
 */

/**
 * The primary classes you'll use when dealing with the Overview.
 *
 *      @defgroup Overview Overview
 */

/**
 * The Overview logger.
 *
 *      @defgroup Overview-Logger Logger
 */

/**
 * The pages that are shown in the Overview.
 *
 *      @defgroup Overview-Pages Pages
 */

/**@}*/

/**
 * Log entries for the Overview logger.
 *
 * @defgroup Overview-Logger-Entries Log Entries
 * @ingroup Overview-Logger
 */

#import "NimbusCore.h"
#import "NIOverview.h"
