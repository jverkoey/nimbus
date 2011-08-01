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

#import "NIWebController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIWebController

@synthesize delegate = _delegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_loadingURL);
  NI_RELEASE_SAFELY(_actionSheet);
  
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)backAction {
  [_webView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardAction {
  [_webView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshAction {
  [_webView reload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAction {
  [_webView stopLoading];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shareAction {
  if (nil == _actionSheet) {
    // Not sure how we are going to deal with localization at this point
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"Open in Safari", @""),
                    nil];
    if (NIIsPad()) {
      [_actionSheet showFromBarButtonItem:_actionButton animated:YES];
      
    }  else {
      [_actionSheet showInView: self.view];
    }
  } else {
    [_actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    NI_RELEASE_SAFELY(_actionSheet);
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  
  CGRect toolbarFrame = _toolbar.frame;
  toolbarFrame.size.height = NIToolbarHeightForOrientation(interfaceOrientation);
  toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
  _toolbar.frame = toolbarFrame;
  
  CGRect webViewFrame = _webView.frame;
  webViewFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
  _webView.frame = webViewFrame;
}

// Shoud this be moved into a Core Category??
///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)ancestorOrSelf:(UIView*)view withClass:(Class)cls {
  if ([view isKindOfClass:cls]) {
    return view;
    
  } else if (view.superview) {
    return [self ancestorOrSelf:view.superview withClass:cls];
    
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)descendantOrSelf:(UIView*)view withClass:(Class)cls {
  if ([view isKindOfClass:cls])
    return view;
  
  for (UIView* child in view.subviews) {
    UIView* it = [self descendantOrSelf:child withClass:cls];
    if (it)
      return it;
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];
  
  CGRect bounds = self.view.bounds;
  
  CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
  CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                   bounds.size.width, toolbarHeight);
  
  _toolbar = [[[UIToolbar alloc] initWithFrame:toolbarFrame] autorelease];
  _toolbar.autoresizingMask =
  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
  
  UIActivityIndicatorView* spinner =
  [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
    UIActivityIndicatorViewStyleWhite] autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
  
  UIImage* backIcon = [UIImage imageWithContentsOfFile:
                          NIPathForBundleResource(nil, @"NimbusWebController.bundle/gfx/backIcon.png")];
  // We weren't able to find the forward or back icons in your application's resources.
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources into your
  // application with the "Create Folder References" option selected. You can verify that
  // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
  // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
  // copied in the Copy Bundle Resources phase.
  NIDASSERT(nil != backIcon);
  
  _backButton =
  [[UIBarButtonItem alloc] initWithImage:backIcon
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(backAction)];
  _backButton.tag = 2;
  _backButton.enabled = NO;
  
  UIImage* forwardIcon = [UIImage imageWithContentsOfFile:
                       NIPathForBundleResource(nil, @"NimbusWebController.bundle/gfx/forwardIcon.png")];
  // We weren't able to find the forward or back icons in your application's resources.
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources into your
  // application with the "Create Folder References" option selected. You can verify that
  // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
  // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
  // copied in the Copy Bundle Resources phase.
  NIDASSERT(nil != forwardIcon);
  
  _forwardButton =
  [[UIBarButtonItem alloc] initWithImage:forwardIcon
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(forwardAction)];
  _forwardButton.tag = 1;
  _forwardButton.enabled = NO;
  _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                    UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
  _refreshButton.tag = 3;
  _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                 UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
  _stopButton.tag = 3;
  _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                   UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
  
  UIBarItem* flexibleSpace =
  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                 target: nil
                                                 action: nil] autorelease];
  
  _toolbar.items = [NSArray arrayWithObjects:
                    _backButton,
                    flexibleSpace,
                    _forwardButton,
                    flexibleSpace,
                    _refreshButton,
                    flexibleSpace,
                    _actionButton,
                    nil];
  [self.view addSubview:_toolbar];
  
  CGRect webViewFrame = NIRectContract(bounds, 0, toolbarHeight);
  
  _webView = [[UIWebView alloc] initWithFrame:webViewFrame];
  _webView.delegate = self;
  _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
  | UIViewAutoresizingFlexibleHeight;
  _webView.scalesPageToFit = YES;
  [self.view addSubview:_webView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  
  _delegate = nil;
  _webView.delegate = nil;
  
  NI_RELEASE_SAFELY(_webView);
  NI_RELEASE_SAFELY(_toolbar);
  NI_RELEASE_SAFELY(_backButton);
  NI_RELEASE_SAFELY(_forwardButton);
  NI_RELEASE_SAFELY(_refreshButton);
  NI_RELEASE_SAFELY(_stopButton);
  NI_RELEASE_SAFELY(_actionButton);
  NI_RELEASE_SAFELY(_activityItem);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateToolbarWithOrientation:self.interfaceOrientation];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  // If the browser launched the media player, it steals the key window and never gives it
  // back, so this is a way to try and fix that
  [self.view.window makeKeyWindow];
  
  [super viewWillDisappear:animated];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self updateToolbarWithOrientation:toInterfaceOrientation];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIWebViewDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
  if ([_delegate respondsToSelector:
       @selector(webController:webView:shouldStartLoadWithRequest:navigationType:)] &&
      ![_delegate webController:self webView:webView
     shouldStartLoadWithRequest:request navigationType:navigationType]) {
        return NO;
      }
  
  [_loadingURL release];
  _loadingURL = [request.URL retain];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
  if ([_delegate respondsToSelector:@selector(webController:webViewDidStartLoad:)]) {
    [_delegate webController:self webViewDidStartLoad:webView];
  }
  
  self.title = NSLocalizedString(@"Loading...", @"");
  if (!self.navigationItem.rightBarButtonItem) {
    [self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
  }
  
  NSInteger buttonIndex = 0;
  for (UIBarButtonItem* button in _toolbar.items) {
    if (button.tag == 3) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:_toolbar.items];
      [newItems replaceObjectAtIndex:buttonIndex withObject:_stopButton];
      _toolbar.items = newItems;
      break;
    }
    ++buttonIndex;
  }
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
  if ([_delegate respondsToSelector:@selector(webController:webViewDidFinishLoad:)]) {
    [_delegate webController:self webViewDidFinishLoad:webView];
  }
  
  NI_RELEASE_SAFELY(_loadingURL);
  self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if (self.navigationItem.rightBarButtonItem == _activityItem) {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
  }
  
  NSInteger buttonIndex = 0;
  for (UIBarButtonItem* button in _toolbar.items) {
    if (button.tag == 3) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:_toolbar.items];
      [newItems replaceObjectAtIndex:buttonIndex withObject:_refreshButton];
      _toolbar.items = newItems;
      break;
    }
    ++buttonIndex;
  }
  
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  if ([_delegate respondsToSelector:@selector(webController:webView:didFailLoadWithError:)]) {
    [_delegate webController:self webView:webView didFailLoadWithError:error];
  }
  
  NI_RELEASE_SAFELY(_loadingURL);
  [self webViewDidFinishLoad:webView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [[UIApplication sharedApplication] openURL:self.URL];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL*)URL {
  return _loadingURL ? _loadingURL : _webView.request.URL;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
  [self openRequest:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest*)request {
  [self view];
  [_webView loadRequest:request];
}

@end
