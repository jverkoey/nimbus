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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPreprocessorMacros.h" /* for NI_WEAK */

/**
 * A simple web view controller implementation with a toolbar.
 *
 * <h2>Subclassing</h2>
 *
 * This view controller implements UIWebViewDelegate. If you want to
 * implement methods of this delegate then you should take care to call the super implementation
 * if necessary. The following UIViewWebDelegate methods have implementations in this class:
 *
 * @code
 * - webView:shouldStartLoadWithRequest:navigationType:
 * - webViewDidStartLoad:
 * - webViewDidFinishLoad:
 * - webView:didFailLoadWithError:
 * @endcode
 *
 * This view controller also implements UIActionSheetDelegate. If you want to implement methods of
 * this delegate then you should take care to call the super implementation if necessary. The
 * following UIActionSheetDelegate methods have implementations in this class:
 *
 * @code
 * - actionSheet:clickedButtonAtIndex:
 * - actionSheet:didDismissWithButtonIndex:
 * @endcode
 *
 * In addition to the above methods of the UIActionSheetDelegate, this view controller also provides
 * the following method, which is invoked prior to presenting the internal action sheet to the user
 * and allows subclasses to customize the action sheet or even reject to display it (and provide their
 * own handling instead):
 *
 * @code
 * - shouldPresentActionSheet:
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
 *
 *      @ingroup NimbusWebController
 */
@interface NIWebController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

// Designated initializer.
- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithURL:(NSURL *)URL;

- (NSURL *)URL;

- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;
- (void)openHTMLString:(NSString*)htmlString baseURL:(NSURL*)baseUrl;

@property (nonatomic, readwrite, assign, getter = isToolbarHidden) BOOL toolbarHidden;
@property (nonatomic, readwrite, NI_WEAK) UIColor* toolbarTintColor;

// Subclassing
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet;
@property (nonatomic, readwrite, NI_STRONG) NSURL* actionSheetURL;

@end

/** @name Creating a Web Controller */

/**
 * Initializes a newly allocated web controller with a given request.
 *
 * Once the controller is presented it will begin loading the given request.
 *
 * This is the designated initializer.
 *
 *      @fn NIWebController::initWithRequest:
 */

/**
 * Initializes a newly allocated web controller with a given URL to request.
 *
 * Once the controller is presented it will begin loading the given URL.
 *
 *      @fn NIWebController::initWithURL:
 */

/** @name Accessing the Request Attributes */

/**
 * The current web view URL.
 *
 * If the web view is currently loading a URL then the loading URL is returned.
 * Otherwise this will be the last URL that was loaded.
 *
 *      @fn NIWebController::URL:
 */

/** @name Loading a Request */

/**
 * Loads a request with the given URL in the web view.
 *
 *      @fn NIWebController::openURL:
 */

/**
 * Load the given request using UIWebView's loadRequest:.
 *
 *      @param request  A URL request identifying the location of the content to load.
 *
 *      @fn NIWebController::openRequest:
 */

/**
 * Load the given request using UIWebView's loadHTMLString:baseURL:.
 *
 *      @param htmlString  The content for the main page.
 *      @param baseUrl  The base URL for the content.
 *
 *      @fn NIWebController::openHTMLString:baseURL:
 */

/** @name Accessing the Toolbar */

/**
 * The visibility of the toolbar.
 *
 * If the toolbar is hidden then the web view will take up the controller's entire view.
 *
 *      @fn NIWebController::toolbarHidden
 */

/**
 * The tint color of the toolbar.
 *
 *      @fn NIWebController::toolbarTintColor
 */

/** @name Subclassing the Web Controller */

/**
 * This message is called in response to the user clicking the action toolbar button.
 *
 * You can provide your own implementation in your subclass and customize the actionSheet
 * that is shown to the user or even cancel the presentation of the @c actionSheet by
 * returning NO from your implementation.
 *
 *      @param actionSheet The UIActionSheet that will be presented to the user.
 *      @return YES to present the actionSheet, NO if you want to perform a custom action.
 *      @fn NIWebController::shouldPresentActionSheet:
 */
