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

@protocol NICSSParserDelegate;
@class NICSSRuleset;

/**
 * The notification key for when a stylesheet has changed.
 *
 *      @ingroup NimbusCSS
 *
 * This notification will be sent with the stylesheet as the object. Listeners should add
 * themselves using the stylesheet object that they are interested in.
 *
 * The NSNotification userInfo object will be nil.
 */
extern NSString* const NIStylesheetDidChangeNotification;

/**
 * Loads and caches information regarding a specific stylesheet.
 *
 *      @ingroup NimbusCSS
 *
 * Use this object to load and parse a CSS stylesheet from disk and then apply the stylesheet
 * to views. Rulesets are cached on demand and cleared when a memory warning is received.
 *
 * Stylesheets can be merged using the addStylesheet: method.
 *
 * Cached rulesets are released when a memory warning is received.
 */
@interface NIStylesheet : NSObject {
@private
  NSDictionary* _rawRulesets;
  NSMutableDictionary* _ruleSets;
  NSDictionary* _significantScopeToScopes;
}

@property (nonatomic, readonly, copy) NSSet* dependencies;

- (BOOL)loadFromPath:(NSString *)path
          pathPrefix:(NSString *)pathPrefix
            delegate:(id<NICSSParserDelegate>)delegate;
- (BOOL)loadFromPath:(NSString *)path pathPrefix:(NSString *)path;
- (BOOL)loadFromPath:(NSString *)path;

- (void)addStylesheet:(NIStylesheet *)stylesheet;

- (void)applyStyleToView:(UIView *)view withClassName:(NSString *)className;

- (NICSSRuleset *)rulesetForClassName:(NSString *)className;

@end


/** @name Properties */

/**
 * A set of NSString filenames for the @imports in this stylesheet.
 *
 *      @fn NIStylesheet::dependencies
 */


/** @name Loading Stylesheets */

/**
 * Loads and parses a CSS file from disk.
 *
 *      @fn NIStylesheet::loadFromPath:pathPrefix:delegate:
 *      @param path         The path of the file to be read.
 *      @param pathPrefix   [optional] A prefix path that will be prepended to the given path
 *                          as well as any imported files.
 *      @param delegate     [optional] A delegate that can reprocess paths.
 *      @returns YES if the CSS file was successfully loaded and parsed, NO otherwise.
 */

/**
 *      @fn NIStylesheet::loadFromPath:pathPrefix:
 *      @sa NIStylesheet::loadFromPath:pathPrefix:delegate:
 */

/**
 *      @fn NIStylesheet::loadFromPath:
 *      @sa NIStylesheet::loadFromPath:pathPrefix:delegate:
 */

/** @name Compositing Stylesheets */

/**
 * Merge another stylesheet with this one.
 *
 * All property values in the given stylesheet will overwrite values in this stylesheet.
 * Non-overlapping values will not be modified.
 *
 *      @fn NIStylesheet::addStylesheet:
 */


/** @name Applying Stylesheets to Views */

/**
 * Apply any rulesets that match the className to the given view.
 *
 *      @fn NIStylesheet::applyStyleToView:withClassName:
 *      @param view       The view for which styles should be applied.
 *      @param className  Either the view's class as a string using NSStringFromClass([view class]);
 *                        or a CSS class selector such as ".myClassSelector".
 */

/**
 * Returns an autoreleased ruleset for the given class name.
 *
 *      @fn NIStylesheet::rulesetForClassName:
 *      @param className  Either the view's class as a string using NSStringFromClass([view class]);
 *                        or a CSS class selector such as ".myClassSelector".
 */
