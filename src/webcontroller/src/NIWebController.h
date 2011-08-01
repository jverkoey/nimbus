//
// Copyright 2011 Roger Chapman
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

    NSURL*            _loadingURL;
}
/**
 * The current web view URL. If the web view is currently loading a URL, then the 
 * loading URL is returned instead.
 */
@property (nonatomic, readonly) NSURL*  URL;

/**
 * Navigate to the given URL.
 */
- (void)openURL:(NSURL*)URL;

/**
 * Load the given request using UIWebView's loadRequest:.
 *
 * @param request  A URL request identifying the location of the content to load.
 */
- (void)openRequest:(NSURLRequest*)request;

/**
 * Sets the toolbar to the given color
 *
 */
- (void)setToolbarTintColor:(UIColor*)color;

@end
