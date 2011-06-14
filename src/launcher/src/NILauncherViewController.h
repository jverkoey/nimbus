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

#ifdef BASE_PRODUCT_NAME
#import "NimbusLauncher/NILauncherView.h"
#else
#import "NILauncherView.h"
#endif

/**
 * @brief A view controller that displays a launcher view and manages its state.
 * @ingroup Launcher-User-Interface
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
 * @brief Access to the internal launcher view.
 *
 * This is exposed primarily for subclasses of this view controller to be able to access the
 * launcher view.
 *
 * You may also use this property from outside of the controller to configure certain aspects of
 * the launcher view.
 */
@property (nonatomic, readonly, retain) NILauncherView* launcherView;

/**
 * @brief An array of arrays of NILauncherItemDetails.
 *
 * These pages are used to populate the launcher view via the NILauncherDataSource protocol.
 */
@property (nonatomic, readwrite, copy) NSArray* pages;


/**
 * The following methods are provided to aid in subclassing this class and are not meant to be
 * used externally.
 */
#pragma mark Subclassing

/**
 * @brief The launcher button view class.
 *
 * Must be a subclass of UIButton.
 *
 * Provided here for subclasses to use as a convenience for changing the launcher button class.
 *
 * Defaults to NILauncherButton.
 */
- (Class)launcherButtonClass;

@end


/**
 * @brief The individual button view that the user taps.
 * @ingroup Launcher-User-Interface
 *
 * Shows the icon centered in the top portion of the button with the text taking up one
 * line at the bottom.
 */
@interface NILauncherButton : UIButton {
@private
  UIEdgeInsets _padding;
}

/**
 * @brief The padding for the button.
 *
 * This padding is applied on all edges of the button.
 *
 * Defaults to 5px of padding on all sides.
 */
@property (nonatomic, readwrite, assign) UIEdgeInsets padding;

@end


/**
 * @brief A convenience class for managing the data used to create an NILauncherButton.
 * @ingroup Launcher-Presentation-Information
 */
@interface NILauncherItemDetails : NSObject <NSCoding> {
@private
  NSString* _title;
  NSString* _imagePath;
}

/**
 * @brief The title for the launcher button.
 */
@property (nonatomic, readwrite, copy) NSString* title;

/**
 * @brief The path to the launcher image.
 */
@property (nonatomic, readwrite, copy) NSString* imagePath;

/**
 * @brief Convenience method for creating a launcher item details object.
 *
 * @param title       The title for the launcher button.
 * @param imagePath   The path to the launcher image.
 */
+ (id)itemDetailsWithTitle:(NSString *)title imagePath:(NSString *)imagePath;

/**
 * @brief The designated initializer.
 *
 * @param title       The title for the launcher button.
 * @param imagePath   The path to the launcher image.
 */
- (id)initWithTitle:(NSString *)title imagePath:(NSString *)imagePath;

@end
