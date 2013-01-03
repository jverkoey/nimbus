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
 * @{
 *
 * <div id="github" feature="css"></div>
 *
 * Nimbus CSS allows you to use cascading stylesheets to theme your native iOS application.
 * Stylesheets provide a number of advantages over Interface Builder and native code.
 *
 * - Diffing CSS files is much easier than diffing Interface Builder's xibs.
 * - CSS allows you to define cascading styles. Change one line and an entire class of views
 *   throughout your application will change.
 * - CSS can be downloaded and swapped out post-App Store submission if you want to make any
 *   minor stylistic changes in production.
 * - On that same note, CSS stylesheets can be swapped at runtime allowing you to easily change
 *   the application's UI when the app state changes. A good example of this is the Rdio app
 *   when you go into offline mode and the app's online components gray out.
 * - Chameleon - modify CSS files and watch the changes affect your app in real time.
 *
 * <h2>How to Create a Stylesheet</h2>
 *
 * Start by creating a .css file. Add it to your project, ensuring that you include it in
 * the copy resources phase. Place all of your CSS files in a subdirectory and add the folder
 * to your project by creating a folder reference. Creating a folder reference will ensure
 * that your subdirectories are maintained when the CSS files are copied to the device.
 *
 * You can then load the stylesheet:
 *
@code
// In this example all of the app's css files are in a "css" folder. The "css" folder would be
// dragged into the Xcode project with the "Create folder reference" option selected.
NSString* pathPrefix = NIPathForBundleResource(nil, @"css");
NIStylesheet* stylesheet = [[[NIStylesheet alloc] init] autorelease];
if ([stylesheet loadFromPath:"common.css"
                  pathPrefix:pathPrefix]) {
  // Successfully loaded <bundlePath>/css/common.css
}
@endcode
 *
 *
 * <h2>Recommended Procedure for Storing Stylesheets</h2>
 *
 * Use a global NIStylesheetCache object to store your stylesheets in memory. Parsing a stylesheet
 * is fast but care should be taken to avoid loading a stylesheet more often than necessary.
 * By no means should you be allocating new stylesheets in tight loops.
 * Using a global NIStylesheetCache will make it easy to ensure that your stylesheets are
 * cached in memory and easily accessible.
 *
 * Another advantage to using a global NIStylesheetCache is that it allows you to easily use
 * Chameleon. Chameleon will post notifications on the stylesheet objects
 * registered in the NIStylesheetCache. Because the observer and you will use the same cache,
 * you can register for notifications on the same stylesheet objects.
 *
 * The above example would look like this if you used a stylesheet cache:
 *
@code
// In your app initialization code, create a global stylesheet cache:
NSString* pathPrefix = NIPathForBundleResource(nil, @"resources/css");
_stylesheetCache = [[NIStylesheetCache alloc] initWithPathPrefix:pathPrefix];
@endcode
 *
@code
// Elsewhere in your app, when you need access to any stylesheet:
NIStylesheetCache* stylesheetCache =
  [(AppDelegate *)[UIApplication sharedApplication].delegate stylesheetCache];
NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"common.css"];
@endcode
 *
 * Reduce the dependencies on your application delegate by defining a global method somewhere:
 *
@code
NIStylesheetCache* StylesheetCache(void);
@endcode
 *
@code
#import "AppDelegate.h"

NIStylesheetCache* StylesheetCache(void) {
  return [(AppDelegate *)[UIApplication sharedApplication].delegate stylesheetCache];
}
@endcode
 *
 *
 * <h2>Using a Stylesheet</h2>
 *
 * The easiest way to apply a stylesheet to a set of views is by using a NIDOM object. Once
 * you attach a stylesheet to an NIDOM object, the stylesheet will be applied to any views you
 * attach to the NIDOM object.
 *
 *
 * <h2>Linking to Other Stylesheets</h2>
 *
 * You can link to one stylesheet from another using @htmlonly @import url('url')@endhtmlonly
 * in the .css file.
 *
 * For example, let's say you have a common CSS file, common.css, and a CSS file for a specific
 * view controller, profile.css. You can import common.css in profile.css by adding the following
 * line:
 *
 * @htmlonly @import url('common.css')@endhtmlonly
 *
 * Files are imported relative to the pathPrefix given to NIStylesheet.
 *
 * <h3>CSS Import Ordering Gotcha</h3>
 *
 * One might expect that placing an @htmlonly @import@endhtmlonly in the middle of a CSS
 * file would import the file at that exact location. This is not currently the case,
 * i.e. the parser does not insert the imported CSS where the @htmlonly @import@endhtmlonly
 * is. Instead, all of the CSS within the imported stylesheet will be processed before
 * the importer's CSS.
 *
 * For example, even if @htmlonly @import url('common.css')@endhtmlonly is placed at
 * the bottom of the profile.css file, common.css will be processed first, followed by profile.css.
 *
 * This is a known limitation and will ideally be fixed in a later release.
 *
 * Relative ordering of @htmlonly @imports@endhtmlonly is respected.
 *
 *
 * <h2>Supported CSS Properties</h2>
 *
@code

UIView {
  border: <dimension> <ignored> <color> {view.layer.borderWidth view.layer.borderColor}
  border-color: <color>       {view.layer.borderColor}
  border-width: <dimension>   {view.layer.borderWidth}
  background-color: <color>   {view.backgroundColor}
  border-radius: <dimension>  {view.layer.cornerRadius}
  opacity: xx.xx              {view.alpha}
}

UILabel {
  color: <color>                  {label.textColor}

  font: <font-size> <font-name>   {label.font}
  font-size: <font-size>          {label.font}
  font-family: <font-name>        {label.font}

  Can not be used in conjunction with font/font-family properties. Use the italic/bold font
  name instead.
  font-style: [italic|normal]     {label.font}
  font-weight: [bold|normal]      {label.font}

  text-align: [left|right|center] {label.textAlignment}

  text-shadow: <color> <x-offset> <y-offset> {label.shadowColor label.shadowOffset}

  -ios-highlighted-color: <color>      {label.highlightedTextColor}
  -ios-line-break-mode: [wrap|character-wrap|clip|head-truncate|tail-truncate|middle-truncate] [label.lineBreakMode]
  -ios-number-of-lines: xx             {label.numberOfLines}
  -ios-minimum-font-size: <font-size>  {label.minimumFontSize}
  -ios-adjusts-font-size: [true|false] {label.adjustsFontSizeToFitWidth}
  -ios-baseline-adjustment: [align-baselines|align-centers|none] {label.baselineAdjustment}
}

UIButton {
  color: <color>        {[button titleColorForState:]}
  text-shadow: <color>  {[button titleShadowColorForState:]}
}

UINavigationBar {
  -ios-tint-color: <color>  {navBar.tintColor}
}
 
 UISearchBar {
 -ios-tint-color: <color>  {searchBar.tintColor}
 }
 
 UIToolbar {
 -ios-tint-color: <color>  {toolbar.tintColor}
 }
@endcode
 *
 *
 * <h2>Chameleon</h2>
 *
 * Chameleon is a web server that serves changes to CSS files in real time.
 *
 * You start Chameleon from the command line using node.js and tell it to watch a specific
 * directory of CSS files for changes. This should ideally be the directory that contains
 * all of your project's CSS files.
 *
 * Note: ensure that when you add the css directory to your project that it is added as a folder
 * reference. This will ensure that the complete folder hierarchy is maintained when the files
 * are copied to the device.
 *
 * To learn more about how to start up a Chameleon server, view the README file within
 * nimbus/src/css/chameleon/. This README will walk you through the necessary steps to build
 * and install node.js.
 *
 * Once you've started the Chameleon server, you simply create a Chameleon observer in your
 * application, give it access to your global stylesheet cache, and then tell it to start
 * watching Chameleon for skin changes. This logic is summed up below:
@code
_chameleonObserver = [[NIChameleonObserver alloc] initWithStylesheetCache:_stylesheetCache
                                                                     host:host];
[_chameleonObserver watchSkinChanges];
@endcode
 *
 * You then simply register for NIStylesheetDidChangeNotification notifications on the stylesheets
 * that you are interested in. You will get a notification when the stylesheet has been modified,
 * at which point if you're using NIDOM you can tell the NIDOM object to refresh itself;
 * this will reapply the stylesheet to all of its attached views.
 */

/**@}*/

#import "NICSSRuleSet.h"
#import "NICSSParser.h"
#import "NIDOM.h"
#import "NIStyleable.h"
#import "NIStylesheet.h"
#import "NIStylesheetCache.h"
#import "NIChameleonObserver.h"

// Styleable UIKit views
#import "UIButton+NIStyleable.h"
#import "UILabel+NIStyleable.h"
#import "UINavigationBar+NIStyleable.h"
#import "UISearchBar+NIStyleable.h"
#import "UIToolbar+NIStyleable.h"
#import "UIView+NIStyleable.h"

// Dependencies
#import "NimbusCore.h"
