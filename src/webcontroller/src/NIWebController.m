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

#import "NIWebController.h"

#import "NimbusCore.h"

@interface NIWebController()
@property (nonatomic, readwrite, retain) UIWebView* webView;
@property (nonatomic, readwrite, retain) UIToolbar* toolbar;
@property (nonatomic, readwrite, retain) UIActionSheet* actionSheet;

@property (nonatomic, readwrite, retain) UIBarButtonItem* backButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem* forwardButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem* refreshButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem* stopButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem* actionButton;
@property (nonatomic, readwrite, retain) UIBarButtonItem* activityItem;

@property (nonatomic, readwrite, retain) NSURL* actionSheetURL;
@property (nonatomic, readwrite, retain) NSURL* loadingURL;

@property (nonatomic, readwrite, retain) NSURLRequest* loadRequest;
@property (nonatomic, readwrite, assign) BOOL toolbarHidden;
@property (nonatomic, readwrite, retain) UIColor* toolbarTintColor;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIWebController

@synthesize webView = _webView;
@synthesize toolbar = _toolbar;
@synthesize actionSheet = _actionSheet;
@synthesize backButton = _backButton;
@synthesize forwardButton = _forwardButton;
@synthesize refreshButton = _refreshButton;
@synthesize stopButton = _stopButton;
@synthesize actionButton = _actionButton;
@synthesize activityItem = _activityItem;
@synthesize actionSheetURL = _actionSheetURL;
@synthesize loadingURL = _loadingURL;
@synthesize loadRequest = _loadRequest;
@synthesize toolbarHidden = _toolbarHidden;
@synthesize toolbarTintColor = _toolbarTintColor;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)releaseAllSubviews {
  _actionSheet.delegate = nil;
  _webView.delegate = nil;

  NI_RELEASE_SAFELY(_actionSheet);
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
- (void)dealloc {
  NI_RELEASE_SAFELY(_actionSheetURL);
  NI_RELEASE_SAFELY(_loadingURL);
  NI_RELEASE_SAFELY(_loadRequest);
  NI_RELEASE_SAFELY(_toolbarTintColor);
  [self releaseAllSubviews];

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
#pragma mark - Private


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
  // Dismiss the action menu if the user taps the action button again on the iPad.
  if ([_actionSheet isVisible]) {
    // It shouldn't be possible to tap the share action button again on anything but the iPad.
    NIDASSERT(NIIsPad());

    [_actionSheet dismissWithClickedButtonIndex:[_actionSheet cancelButtonIndex] animated:YES];

    // We remove the action sheet here just in case the delegate isn't properly implemented.
    _actionSheet.delegate = nil;
    NI_RELEASE_SAFELY(_actionSheet);
    NI_RELEASE_SAFELY(_actionSheetURL);

    // Don't show the menu again.
    return;
  }

  // Remember the URL at this point
  [_actionSheetURL release];
  _actionSheetURL = [self.URL copy];

  if (nil == _actionSheet) {
    _actionSheet =
    [[UIActionSheet alloc] initWithTitle:[_actionSheetURL absoluteString]
                                delegate:self
                       cancelButtonTitle:nil
                  destructiveButtonTitle:nil
                       otherButtonTitles:nil];
    // Let -shouldPresentActionSheet: setup the action sheet
    if (![self shouldPresentActionSheet:_actionSheet]) {
      // A subclass decided to handle the action in another way
      NI_RELEASE_SAFELY(_actionSheet);
      NI_RELEASE_SAFELY(_actionSheetURL);
      return;
    }
    // Add "Cancel" button except for iPads
    if (!NIIsPad()) {
      [_actionSheet setCancelButtonIndex:[_actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")]];
    }
  }

  if (NIIsPad()) {
    [_actionSheet showFromBarButtonItem:_actionButton animated:YES];
  } else {
    [_actionSheet showInView:self.view];
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWebViewFrame {
  if (self.toolbarHidden) {
    _webView.frame = self.view.bounds;
    
  } else {
    _webView.frame = NIRectContract(self.view.bounds, 0, self.toolbar.frame.size.height);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  CGRect bounds = self.view.bounds;

  CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
  CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                   bounds.size.width, toolbarHeight);

  _toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
  _toolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                               | UIViewAutoresizingFlexibleWidth);
  _toolbar.tintColor = self.toolbarTintColor;
  _toolbar.hidden = self.toolbarHidden;

  UIActivityIndicatorView* spinner =
  [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
    UIActivityIndicatorViewStyleWhite] autorelease];
  [spinner startAnimating];
  _activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

  UIImage* backIcon = [UIImage imageWithContentsOfFile:
                      NIPathForBundleResource(nil, @"NimbusWebController.bundle/gfx/backIcon.png")];
  // We weren't able to find the forward or back icons in your application's resources.
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
  //into your application with the "Create Folder References" option selected. You can verify that
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
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
  // into your application with the "Create Folder References" option selected. You can verify that
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

  _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  [self updateWebViewFrame];
  _webView.delegate = self;
  _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleHeight);
  _webView.scalesPageToFit = YES;

  if ([UIColor respondsToSelector:@selector(underPageBackgroundColor)]) {
    self.webView.backgroundColor = [UIColor underPageBackgroundColor];
  }

  [self.view addSubview:_webView];

  if (nil != self.loadRequest) {
    [self.webView loadRequest:self.loadRequest];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];

  [self releaseAllSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self updateToolbarWithOrientation:self.interfaceOrientation];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
  // If the browser launched the media player, it steals the key window and never gives it
  // back, so this is a way to try and fix that.
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
#pragma mark - UIWebViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
  [_loadingURL release];
  _loadingURL = [request.mainDocumentURL copy];
  _backButton.enabled = [_webView canGoBack];
  _forwardButton.enabled = [_webView canGoForward];
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
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
  NI_RELEASE_SAFELY(_loadingURL);
  [self webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet == _actionSheet) {
    if (buttonIndex == 0) {
      [[UIApplication sharedApplication] openURL:_actionSheetURL];
    } else if (buttonIndex == 1) {
      [[UIPasteboard generalPasteboard] setURL:_actionSheetURL];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (actionSheet == _actionSheet) {
    _actionSheet.delegate = nil;
    NI_RELEASE_SAFELY(_actionSheet);
    NI_RELEASE_SAFELY(_actionSheetURL);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)URL {
  return _loadingURL ? _loadingURL : _webView.request.mainDocumentURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
  [self openRequest:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest *)request {
  self.loadRequest = request;

  if ([self isViewLoaded]) {
    if (nil != request) {
      [_webView loadRequest:request];

    } else {
      [_webView stopLoading];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarHidden:(BOOL)hidden {
  _toolbarHidden = hidden;
  if ([self isViewLoaded]) {
    _toolbar.hidden = hidden;
    [self updateWebViewFrame];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarTintColor:(UIColor*)color {
  if (color != _toolbarTintColor) {
    [_toolbarTintColor release];
    _toolbarTintColor = [color retain];
  }

  if ([self isViewLoaded]) {
    _toolbar.tintColor = color;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet {
  if (actionSheet == _actionSheet) {
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Copy URL", @"")];
  }
  return YES;
}


@end
