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
 * @defgroup NimbusCore Nimbus Core
 *
 * <div id="github" feature="core"></div>
 *
 * Nimbus' Core defines the foundation upon which all other Nimbus features are built.
 * Within the core you will find common elements used to build iOS applications
 * including in-memory caches, path manipulation, and SDK availability. These features form
 * the foundation upon which all other Nimbus libraries are built.
 *
 * <h2>How Features are Added to the Core</h2>
 *
 * As a general rule of thumb, if something is used between multiple independent libraries or
 * applications with little variation, it likely qualifies to be added to the Core.
 *
 * <h3>Exceptions</h3>
 *
 * Standalone user interface components are <i>rarely</i> acceptable features to add to the Core.
 * For example: photo viewers, pull to refresh, launchers, attributed labels.
 *
 * Nimbus is not UIKit: we don't have the privilege of being an assumed cost on every iOS
 * device. Developers must carefully weigh whether it is worth adding a Nimbus feature - along
 * with its dependencies - over building the feature themselves or using another library. This
 * means that an incredible amount of care must be placed into deciding what gets added to the
 * Core.
 *
 * <h2>How Features are Removed from the Core</h2>
 *
 * It is inevitable that certain aspects of the Core will grow and develop over time. If a
 * feature gets to the point where the value of being a separate library is greater than the
 * overhead of managing such a library, then the feature should be considered for removal
 * from the Core.
 *
 * Great care must be taken to ensure that Nimbus doesn't become a framework composed of
 * hundreds of miniscule libraries.
 * 
 * <h2>Common autoresizing masks</h2>
 * 
 * Nimbus provides the following macros: UIViewAutoresizingFlexibleMargins,
 * UIViewAutoresizingFlexibleDimensions, UIViewAutoresizingNavigationBar, and
 * UIViewAutoresizingToolbarBar.
 * 
@code
// Create a view that fills its superview's bounds.
UIView* contentView = [[UIView alloc] initWithFrame:self.view.bounds];
contentView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
[self.view addSubview:contentView];

// Create a view that is always centered in the superview's bounds.
UIView* centeredView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
centeredView.autoresizingMask = UIViewAutoresizingFlexibleMargins;
// Center the view within the superview however you choose.
[self.view addSubview:centeredView];

// Create a navigation bar that stays fixed to the top.
UINavigationBar* navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
[navBar sizeToFit];
navBar.autoresizingMask = UIViewAutoresizingNavigationBar;
[self.view addSubview:navBar];

// Create a toolbar that stays fixed to the bottom.
UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
[toolBar sizeToFit];
toolBar.autoresizingMask = UIViewAutoresizingToolbarBar;
[self.view addSubview:toolBar];
@endcode
 * 
 * <h3>Why they exist</h3>
 * 
 * Using the existing UIViewAutoresizing flags can be tedious for common flags.
 * 
 * For example, to make a view have flexible margins you would need to write four flags:
 * 
@code
view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin
                         | UIViewAutoresizingFlexibleTopMargin
                         | UIViewAutoresizingFlexibleRightMargin
                         | UIViewAutoresizingFlexibleBottomMargin);
@endcode
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NICommonMetrics.h"
#import "NIDataStructures.h"
#import "NIDebuggingTools.h"
#import "NIDeviceOrientation.h"
#import "NIError.h"
#import "NIFoundationMethods.h"
#import "NIInMemoryCache.h"
#import "NINavigationAppearance.h"
#import "NINetworkActivity.h"
#import "NINonEmptyCollectionTesting.h"
#import "NINonRetainingCollections.h"
#import "NIOperations.h"
#import "NIPaths.h"
#import "NIPreprocessorMacros.h"
#import "NIRuntimeClassModifications.h"
#import "NISDKAvailability.h"
#import "NISnapshotRotation.h"
#import "NIState.h"
#import "NIViewRecycler.h"
