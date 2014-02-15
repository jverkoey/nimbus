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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NIStylesheet;

/**
 * A leight-weight DOM-like object to which you attach views and stylesheets.
 *
 * @ingroup NimbusCSS
 *
 * To be clear: this is not an HTML DOM, but its intent is the same. NIDOM is designed
 * to simplify the view <=> stylesheet relationship. Add a view to the DOM and it will
 * automatically apply any applicable styles from the attached stylesheet. If the stylesheet
 * changes you can refresh the DOM and all registered views will be updated accordingly.
 *
 * Because NimbusCSS supports positioning and sizing using percentages and relative units,
 * the order of view registration is important. Generally, you should register superviews
 * first, so that any size calculations on their children can occur after their own
 * size has been determined. It's not feasible (or at least advisable) to try and
 * untangle these dependencies automatically.
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
@interface NIDOM : NSObject

// Designated initializer.

- (id)initWithStylesheet:(NIStylesheet *)stylesheet;

+ (id)domWithStylesheet:(NIStylesheet *)stylesheet;
+ (id)domWithStylesheetWithPathPrefix:(NSString *)pathPrefix paths:(NSString *)path, ...;

+ (id)domWithStylesheet:(NIStylesheet *)stylesheet andParentStyles: (NIStylesheet*) parentStyles;

- (void)registerView:(UIView *)view;
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass;
- (void)registerView:(UIView *)view withCSSClass:(NSString *)cssClass andId: (NSString*) viewId;

- (void)addCssClass: (NSString *) cssClass toView: (UIView*) view;
- (void)removeCssClass: (NSString*) cssClass fromView: (UIView*) view;

- (void)unregisterView:(UIView *)view;
- (void)unregisterAllViews;
- (void)refresh;
- (void)refreshView: (UIView*) view;

-(UIView*)viewById: (NSString*) viewId;

-(NSString*) descriptionForView: (UIView*) view withName: (NSString*) viewName;
-(NSString*) descriptionForAllViews;

@property (nonatomic,unsafe_unretained) id target;
@end

/** @name Creating NIDOMs */

/**
 * Initializes a newly allocated DOM with the given stylesheet.
 *
 * @fn NIDOM::initWithStylesheet:
 */

/**
 * Returns an autoreleased DOM initialized with the given stylesheet.
 *
 * @fn NIDOM::domWithStylesheet:
 */

/**
 * Returns an autoreleased DOM initialized with a nil-terminated list of file paths.
 *
 * @fn NIDOM::domWithStylesheetWithPathPrefix:paths:
 */

/**
 * Returns an autoreleased DOM initialized with the given stylesheet and a "parent" stylesheet
 * that runs first. Doing this rather than compositing stylesheets can save memory and improve
 * performance in the common case where you have a set of global styles and a bunch of view
 * or view controller specific style sheets.
 *
 * @fn NIDOM::domWithStylesheet:andParentStyles:
 */

/** @name Registering Views */

/**
 * Registers the given view with the DOM.
 *
 * The view's class will be used as the CSS selector when applying styles from the stylesheet.
 *
 * @fn NIDOM::registerView:
 */

/**
 * Registers the given view with the DOM.
 *
 * The view's class as well as the given CSS class string will be used as the CSS selectors
 * when applying styles from the stylesheet.
 *
 * @fn NIDOM::registerView:withCSSClass:
 */

/**
 * Removes the given view from from the DOM.
 *
 * Once a view has been removed from the DOM it will not be restyled when the DOM is refreshed.
 *
 * @fn NIDOM::unregisterView:
 */

/**
 * Removes all views from from the DOM.
 *
 * @fn NIDOM::unregisterAllViews
 */


/** @name Re-Applying All Styles */

/**
 * Reapplies the stylesheet to all views. Since there may be positioning involved,
 * you may need to reapply if layout or sizes change.
 *
 * @fn NIDOM::refresh
 */

/**
 * Reapplies the stylesheet to a single view. Since there may be positioning involved,
 * you may need to reapply if layout or sizes change.
 *
 * @fn NIDOM::refreshView:
 */

/**
 * Removes the association of a view with a CSS class. Note that this doesn't
 * "undo" the styles that the CSS class generated, it just stops applying them
 * in the future.
 *
 * @fn NIDOM::removeCssClass:fromView:
 */

/**
 * Create an association of a view with a CSS class and apply relevant styles
 * immediately.
 *
 * @fn NIDOM::addCssClass:toView:
 */

/** @name Dynamic View Construction */

/**
 * Using the [UIView buildSubviews:inDOM:] extension allows you to build view
 * hierarchies from JSON (or anything able to convert to NSDictionary/NSArray
 * of simple types) documents, mostly for prototyping. Those documents can
 * specify selectors, and those selectors need a target. This target property
 * will be the target for all selectors in a given DOM. Truth is it only matters
 * during buildSubviews, so in theory you could set and reset it across multiple
 * build calls if you wanted to.
 *
 * @fn NIDOM::target
 */

/** @name Debugging */

/**
 * Describe what would be done to view given the existing registrations for it. In other words, you
 * must call one of the register view variants first before asking for a description. The current
 * implementations return actual objective-c code, using viewName as the target. This allows you to
 * theoretically replace the CSS infrastructure with generated code, if you choose to. More importantly,
 * it allows you to debug what's happening with view styling.
 *
 * @fn NIDOM::descriptionForView:withName:
 */

/**
 * Call descriptionForView for all registered views, in the order they would be applied during refresh
 *
 * @fn NIDOM::descriptionForAllViews
 */
