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
 * @defgroup NimbusCSS Nimbus CSS
 *
 * Nimbus CSS allows you to use cascading stylesheets to theme your native iOS application.
 * Stylesheets provide a number of advantages over Interface Builder and native code.
 *
 * - Tracking changes in style with CSS is much easier than with Interface Builder.
 * - CSS allows you to define cascading styles, so changing one line can change an entire
 *   class of views throughout your application.
 * - CSS can be downloaded and swapped out post-App Store submission if you want to make any
 *   minor stylistic changes.
 * - On that same note, CSS stylesheets can be swapped at runtime allowing you to easily change
 *   the application's UI when the app state changes. A good example of this is the Rdio app
 *   when you go into offline mode and the app's online components gray out.
 *
 * <h2>Creating a Stylesheet</h2>
 *
 * 
 *
 * <h2>Linking to Other Stylesheets</h2>
 *
 * You can link to one stylesheet from another using @import url('<url>').
 *
 * For example, let's say you have a common CSS file, common.css, and a CSS file for a specific
 * view controller, profile.css. You can import common.css in profile.css by adding the following
 * line:
 *
 * @import url('common.css')
 *
 * <h3>Notes about CSS Imports</h3>
 *
 * One might expect that placing an @import in the middle of a CSS file would import
 * the file at that exact location. This is not currently the case, i.e. the parser does not
 * insert the imported CSS where the @import is. Instead, all of the CSS within the
 * imported stylesheet will be processed before the importer's CSS.
 *
 * For example, even if @import url('common.css') is placed at the bottom of the profile.css file,
 * common.css will be processed first, followed by profile.css.
 *
 * This is a known limitation and will ideally be fixed in a later release.
 *
 * Relative ordering of @imports is respected.
 *
 *
 * <h2>Supported CSS Properties</h2>
 */

#import "NICSSRuleSet.h"
#import "NICSSParser.h"
#import "NIDOM.h"
#import "NIStyleable.h"
#import "NIStylesheet.h"
#import "NIChameleonObserver.h"

// Styled views
#import "UILabel+NIStyleable.h"
#import "UIView+NIStyleable.h"
#import "UINavigationBar+NIStyleable.h"

// Dependencies
#import "NimbusCore.h"
