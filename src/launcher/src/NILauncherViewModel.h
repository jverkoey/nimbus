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

#import "NILauncherView.h"

@protocol NILauncherViewObject;
@protocol NILauncherViewModelDelegate;

/**
 * A launcher view model that complies to the NILauncherDataSource protocol.
 *
 * This model object allows you to keep all of your launcher view data together in one object.
 * It also conforms to the NSCoding protocol, allowing you to read and write your model to disk
 * so that you can store the state of your launcher.
 *
 * @ingroup NimbusLauncherModel
 */
@interface NILauncherViewModel : NSObject <NILauncherDataSource, NSCoding>

// Designated initializer.
- (id)initWithArrayOfPages:(NSArray *)pages delegate:(id<NILauncherViewModelDelegate>)delegate;

- (void)appendPage:(NSArray *)page;
- (void)appendObject:(id<NILauncherViewObject>)object toPage:(NSInteger)pageIndex;

- (id<NILauncherViewObject>)objectAtIndex:(NSInteger)index pageIndex:(NSInteger)pageIndex;

@property (nonatomic, weak) id<NILauncherViewModelDelegate> delegate;

@end

/**
 * The delegate for NILauncherViewModel.
 *
 * This delegate allows you to configure the launcher button views before they are displayed.
 *
 * @ingroup NimbusLauncherModel
 */
@protocol NILauncherViewModelDelegate <NSObject>
@required

/**
 * Tells the delegate to configure a button view in a given page.
 *
 * @param launcherViewModel The launcher-view model requesting this configuration.
 * @param buttonView The button view that should be configured.
 * @param launcherView The launcher-view object that will displaly this button view.
 * @param pageIndex The index of the page where this button view will be displayed.
 * @param buttonIndex The index of the button in the page.
 * @param object The object that will likely be used to configure this button view.
 */
- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object;

@end

/**
 * The minimal amount of information required to configure a button view.
 *
 * @ingroup NimbusLauncherModel
 */
@protocol NILauncherViewObject <NSObject>
@required

/** @name Accessing the Object Attributes */

/**
 * The title that will be displayed on the launcher view button.
 */
@property (nonatomic, copy) NSString* title;

/**
 * The image that will be displayed on the launcher view button.
 */
@property (nonatomic, strong) UIImage* image;

/**
 * The class of button view that should be used to display this object.
 *
 * This class must conform to the NILauncherButtonView protocol.
 */
- (Class)buttonViewClass;

@end

/**
 * A protocol that a launcher button view can implement to allow itself to be configured.
 *
 * @ingroup NimbusLauncherModel
 */
@protocol NILauncherViewObjectView <NSObject>
@required

/** @name Updating a Launcher Button View */

/**
 * Informs the receiver that a new object should be used to configure the view.
 */
- (void)shouldUpdateViewWithObject:(id)object;

@end

/** @name Creating Launcher View Models */

/**
 * Initializes a newly allocated launcher view model with an array of pages and a given delegate.
 *
 * This is the designated initializer.
 *
 * @param pages An array of arrays of objects that conform to the NILauncherViewObject protocol.
 * @param delegate An object that conforms to the NILauncherViewModelDelegate protocol.
 * @returns An initialized launcher view model.
 * @fn NILauncherViewModel::initWithArrayOfPages:delegate:
 */

/** @name Accessing Objects */

/**
 * Appends a page of launcher view objects.
 *
 * @param page An array of launcher view objects to add.
 * @fn NILauncherViewModel::appendPage:
 */

/**
 * Appends a launcher view object to a given page.
 *
 * @param object The object to add to the page.
 * @param pageIndex The index of the page to add this object to.
 * @fn NILauncherViewModel::appendObject:toPage:
 */

/**
 * Returns the object at the given index in the page at the given page index.
 *
 * Throws an assertion if the object index or page index are out of bounds.
 *
 * @param index The index within the page of the object to return.
 * @param pageIndex The index of the page to retrieve the object from.
 * @returns An object from a specific page.
 * @fn NILauncherViewModel::objectAtIndex:pageIndex:
 */

/** @name Managing the Delegate */

/**
 * The delegate for this launcher view model.
 */
