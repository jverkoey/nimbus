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

#import "NILauncherView.h"

/**
 * A view controller that displays a launcher view and implements its protocols.
 *
 * @ingroup NimbusLauncher
 *
 * This view controller may be used in production, though you'll likely want to subclass it
 * and internalize the loading of the pages. You can also simply use this controller as an
 * example and write a completely new view controller or add the launcher view to an existing
 * view controller if that suits your situation better.
 *
 *
 * By default this controller implements the numberOfRowsPerPageInLauncherView and
 * numberOfColumnsPerPageInLauncherView methods of the launcher data source. The following
 * values are given depending on the device:
 *
 * @htmlonly
 * <pre>
 * iPhone:
 *   Portrait: 3x3 (row by column)
 *   Landscape: 5x2
 * iPad:
 *   4x5
 * </pre>
 * @endhtmlonly
 *
 * You may choose to allow the launcher to determine the number of icons to be shown on its
 * own. If you choose to do so, make these methods return NILauncherViewDynamic.
 *
 *
 * By default this controller does not allow the launcher to be shown in landscape mode on the
 * iPhone or iPod touches. This is due largely to the complex nature of handling the different
 * number of icons that can be displayed in each orientation. For example, on the iPhone
 * in portrait with the default grid definitions as noted above, you can see 9
 * icons, whereas in landscape you can see 10. There are things you can do to make this
 * work, of course, but barring an elegant solution I've elected to disable this
 * functionality by default in this controller.
 *
 *
 * @image html NILauncherViewControllerExample1.png "Example of an NILauncherViewController as seen in the BasicLauncher demo application."
 *
 *
 *      @todo Implement a reusable means of storing and loading launcher state information.
 *            This can probably be easily accomplished using simple keyed archiving because
 *            NILauncherItem implements the NSCoding protocol.
 */
@interface NILauncherViewController : UIViewController <NILauncherDelegate, NILauncherDataSource>
@property (nonatomic, readwrite, retain) NILauncherView* launcherView;
@end

/**
 * Access to the internal launcher view.
 *
 * This is exposed primarily for subclasses of this view controller to be able to access the
 * launcher view.
 *
 * You may also use this property from outside of the controller to configure certain aspects of
 * the launcher view.
 *
 *      @fn NILauncherViewController::launcherView
 */
