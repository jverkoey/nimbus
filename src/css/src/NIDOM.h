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

@class NIStylesheet;

/**
 * A leight-weight DOM-like object to which you attach views and stylesheets.
 *
 *      @ingroup NimbusCSS
 *
 * To be clear: this is not an HTML DOM, but its intent is the same. NIDOM is designed
 * to simplify the view <=> stylesheet relationship. Add a view to the DOM and it will
 * automatically apply any applicable styles from the attached stylesheet. If the stylesheet
 * changes you can refresh the DOM and all registered views will be updated accordingly.
 *
 *
 * <h2>Example Use</h2>
 *
 * NIDOM is most useful when you create a single NIDOM per view controller.
 *
@code
NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"root/root.css"];
// Create a NIDOM object in your view controller.
_dom = [[NIDOM alloc] initWithStylesheet:stylesheet];
@endcode
 *
 * You then register views in the DOM during loadView or viewDidLoad.
 *
@code
// Registers a view by itself such that only "UILabel" rulesets will apply.
[_dom registerView:_label];

// Register a view with a specific CSS class. Any rulesets with the ".background" scope will
// apply to this view.
[_dom registerView:self.view withCSSClass:@"background"];
@endcode
 *
 * Once the view controller unloads its view you must unregister all of the views from your DOM.
 *
@code
- (void)viewDidUnload {
  [_dom unregisterAllViews];
}
@endcode
 */
@interface NIDOM : NSObject {
@private
  NIStylesheet* _stylesheet;
  NSMutableSet* _registeredViews;
  NSMutableDictionary* _viewToSelectorsMap;
}

// Designated initializer.

- (id)initWithStylesheet:(NIStylesheet *)stylesheet;

+ (id)domWithStylesheet:(NIStylesheet *)stylesheet;
+ (id)domWithStylesheetWithPathPrefix:(NSString *)pathPrefix paths:(NSString *)path, ...;

- (void)registerView:(UIView *)view;
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass;
- (void)unregisterView:(UIView *)view;
- (void)unregisterAllViews;
- (void)refresh;

@end

/** @name Creating NIDOMs */

/**
 * Initializes a newly allocated DOM with the given stylesheet.
 *
 *      @fn NIDOM::initWithStylesheet:
 */

/**
 * Returns an autoreleased DOM initialized with the given stylesheet.
 *
 *      @fn NIDOM::domWithStylesheet:
 */

/**
 * Returns an autoreleased DOM initialized with a nil-terminated list of file paths.
 *
 *      @fn NIDOM::domWithStylesheetWithPathPrefix:paths:
 */


/** @name Registering Views */

/**
 * Registers the given view with the DOM.
 *
 * The view's class will be used as the CSS selector when applying styles from the stylesheet.
 *
 *      @fn NIDOM::registerView:
 */

/**
 * Registers the given view with the DOM.
 *
 * The view's class as well as the given CSS class string will be used as the CSS selectors
 * when applying styles from the stylesheet.
 *
 *      @fn NIDOM::registerView:withCSSClass:
 */

/**
 * Removes the given view from from the DOM.
 *
 * Once a view has been removed from the DOM it will not be restyled when the DOM is refreshed.
 *
 *      @fn NIDOM::unregisterView:
 */

/**
 * Removes all views from from the DOM.
 *
 *      @fn NIDOM::unregisterAllViews
 */


/** @name Re-Applying All Styles */

/**
 * Reapplies the stylesheet to all views.
 *
 * This only needs to be called if the stylesheet has changed.
 *
 *      @fn NIDOM::refresh
 */
