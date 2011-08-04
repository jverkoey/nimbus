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
 * @ingroup Launcher-User-Interface
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
 *            NILauncherItemDetails implements the NSCoding protocol.
 */
@interface NILauncherViewController : UIViewController <
  NILauncherDelegate,
  NILauncherDataSource
> {
@private
  NILauncherView* _launcherView;

  NSMutableArray* _pages; // Array< Array<NILauncherItemDetails *> >
}

/**
 * Access to the internal launcher view.
 *
 * This is exposed primarily for subclasses of this view controller to be able to access the
 * launcher view.
 *
 * You may also use this property from outside of the controller to configure certain aspects of
 * the launcher view.
 */
@property (nonatomic, readonly, retain) NILauncherView* launcherView;

/**
 * An array of arrays of NILauncherItemDetails.
 *
 * These pages are used to populate the launcher view via the NILauncherDataSource protocol.
 *
 * @note This is an NSArray - not an NSMutableArray - because you should not directly modify
 *       the contents of the pages after they have been stored in this view controller.
 *       If you need to modify the pages after assigning them here, you should assign
 *       a new set of pages.
 */
@property (nonatomic, readwrite, copy) NSArray* pages;


/**
 * @name Subclassing
 * @{
 *
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */
#pragma mark Subclassing

/**
 * The launcher button view class.
 *
 * Must be a subclass of UIButton.
 *
 * Provided here for subclasses to use as a convenience for changing the launcher button class.
 *
 * Defaults to NILauncherButton.
 */
- (Class)launcherButtonClass;

/**@}*/

@end


/**
 * A simple launcher button that shows an image and text.
 *
 * @ingroup Launcher-User-Interface
 *
 * Shows the icon centered in the top portion of the button with the text taking up one
 * line at the bottom.
 *
 * @image html NILauncherButtonExample1.png "Example of an NILauncherButton"
 */
@interface NILauncherButton : UIButton {
@private
  UIEdgeInsets _padding;
}

/**
 * The padding for the button.
 *
 * This padding is applied on all edges of the button.
 *
 * Defaults to 5px of padding on all sides.
 */
@property (nonatomic, readwrite, assign) UIEdgeInsets padding;

@end


/**
 * A convenience class for managing the data used to create an NILauncherButton.
 *
 * @ingroup Launcher-User-Interface
 *
 * In your own implementation of a launcher controller you do not need to use this object;
 * it is a trivial convenience object for containing the basic information required to display
 * an NILauncherButton. You may choose to forego the use of a container object altogether and
 * populate your launcher buttons from a data store, or perhaps from a downloaded JSON file.
 */
@interface NILauncherItemDetails : NSObject <NSCoding> {
@private
  NSString* _title;
  NSString* _imagePath;
}

/**
 * The title for the launcher button.
 */
@property (nonatomic, readwrite, copy) NSString* title;

/**
 * The path to the launcher image.
 */
@property (nonatomic, readwrite, copy) NSString* imagePath;

/**
 * Convenience method for creating a launcher item details object.
 *
 *      @param title       The title for the launcher button.
 *      @param imagePath   The path to the launcher image.
 */
+ (id)itemDetailsWithTitle:(NSString *)title imagePath:(NSString *)imagePath;

/**
 * The designated initializer.
 *
 *      @param title       The title for the launcher button.
 *      @param imagePath   The path to the launcher image.
 */
- (id)initWithTitle:(NSString *)title imagePath:(NSString *)imagePath;

@end
