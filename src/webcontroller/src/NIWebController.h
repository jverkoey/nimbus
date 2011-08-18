//
// Copyright 2011 Roger Chapman
// Copyright 2011 Benedikt Meurer
//
// Forked from Three20 July 29, 2011 - Copyright 2009-2011 Facebook
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
 * A simple web view controller implementation with a toolbar.
 *
 *      @ingroup NimbusWebController
 *
 *
 * <h2>Subclassing</h2>
 *
 * This view controller implements UIWebViewDelegate. If you want to
 * implement methods of this delegate then you should take care to call the super implementation
 * if necessary. The following methods have implementations in this class:
 *
 * @code
 * - webView:shouldStartLoadWithRequest:navigationType:
 * - webViewDidStartLoad:
 * - webViewDidFinishLoad:
 * - webView:didFailLoadWithError:
 * @endcode
 *
 *
 * <h2>Recommended Configurations</h2>
 *
 * <h3>Default</h3>
 *
 * The default settings will create a toolbar with the default tint color, which is normally
 * light blue on the iPhone and gray on the iPad.
 *
 *
 * <h3>Colored Toolbar</h3>
 *
 * The following settings will change the toolbar tint color (in this case black)
 *
 * @code
 *  [webController setToolbarTintColor:[UIColor blackColor]];
 * @endcode
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NIWebController : UIViewController <
  UIWebViewDelegate,
  UIActionSheetDelegate > {
@protected
  // Views
  UIWebView*        _webView;
  UIToolbar*        _toolbar;
  UIActionSheet*    _actionSheet;
  
  // Toolbar buttons
  UIBarButtonItem*  _backButton;
  UIBarButtonItem*  _forwardButton;
  UIBarButtonItem*  _refreshButton;
  UIBarButtonItem*  _stopButton;
  UIBarButtonItem*  _actionButton;
  UIBarButtonItem*  _activityItem;

  NSURL*            _actionSheetURL;
  NSURL*            _loadingURL;
}

/**
 * The current web view URL.
 *
 * If the web view is currently loading a URL then the loading URL is returned instead.
 */
- (NSURL *)URL;

/**
 * Opens the given URL in the web view.
 */
- (void)openURL:(NSURL*)URL;

/**
 * Load the given request using UIWebView's loadRequest:.
 *
 *      @param request  A URL request identifying the location of the content to load.
 */
- (void)openRequest:(NSURLRequest*)request;

/**
 * Sets the toolbar to the given color.
 */
- (void)setToolbarTintColor:(UIColor*)color;

/**
 * This message is send to the receiver in response to the user clicking the action toolbar button.
 * You can provide your own implementation here and customize the @c actionSheet that is shown the
 * user, or even cancel the presentation of the @c actionSheet at all by returning @c NO from your
 * implementation.
 *
 * @param actionSheet The UIActionSheet that will be presented to the user.
 *
 * @return @c YES to present the @p actionSheet, @c NO if you want to perform a custom action.
 */
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet;

@end
