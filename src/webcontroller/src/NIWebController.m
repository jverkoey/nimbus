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

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

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

@property (nonatomic, readwrite, retain) NSURL* loadingURL;

@property (nonatomic, readwrite, retain) NSURLRequest* loadRequest;
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
- (void)dealloc {
  _actionSheet.delegate = nil;
  _webView.delegate = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRequest:(NSURLRequest *)request {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.hidesBottomBarWhenPushed = YES;
    [self openRequest:request];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)URL {
  return [self initWithRequest:[NSURLRequest requestWithURL:URL]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithRequest:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapBackButton {
  [self.webView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapForwardButton {
  [self.webView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapRefreshButton {
  [self.webView reload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapStopButton {
  [self.webView stopLoading];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapShareButton {
  // Dismiss the action menu if the user taps the action button again on the iPad.
  if ([self.actionSheet isVisible]) {
    // It shouldn't be possible to tap the share action button again on anything but the iPad.
    NIDASSERT(NIIsPad());

    [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:YES];

    // We remove the action sheet here just in case the delegate isn't properly implemented.
    self.actionSheet.delegate = nil;
    self.actionSheet = nil;
    self.actionSheetURL = nil;

    // Don't show the menu again.
    return;
  }

  // Remember the URL at this point
  self.actionSheetURL = [self.URL copy];

  if (nil == self.actionSheet) {
    self.actionSheet =
    [[UIActionSheet alloc] initWithTitle:[self.actionSheetURL absoluteString]
                                delegate:self
                       cancelButtonTitle:nil
                  destructiveButtonTitle:nil
                       otherButtonTitles:nil];

    // Let -shouldPresentActionSheet: setup the action sheet
    if (![self shouldPresentActionSheet:self.actionSheet]) {
      // A subclass decided to handle the action in another way
      self.actionSheet = nil;
      self.actionSheetURL = nil;
      return;
    }
    // Add "Cancel" button except for iPads
    if (!NIIsPad()) {
      [self.actionSheet setCancelButtonIndex:[self.actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")]];
    }
  }

  if (NIIsPad()) {
    [self.actionSheet showFromBarButtonItem:self.actionButton animated:YES];
  } else {
    [self.actionSheet showInView:self.view];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateToolbarWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (!self.toolbarHidden) {
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.size.height = NIToolbarHeightForOrientation(interfaceOrientation);
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    self.toolbar.frame = toolbarFrame;

    CGRect webViewFrame = self.webView.frame;
    webViewFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
    self.webView.frame = webViewFrame;

  } else {
    self.webView.frame = self.view.bounds;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateWebViewFrame {
  if (self.toolbarHidden) {
    self.webView.frame = self.view.bounds;
    
  } else {
    self.webView.frame = NIRectContract(self.view.bounds, 0, self.toolbar.frame.size.height);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  CGRect bounds = self.view.bounds;

  CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
  CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                   bounds.size.width, toolbarHeight);

  self.toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
  self.toolbar.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                               | UIViewAutoresizingFlexibleWidth);
  self.toolbar.tintColor = self.toolbarTintColor;
  self.toolbar.hidden = self.toolbarHidden;

  UIActivityIndicatorView* spinner =
  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
    UIActivityIndicatorViewStyleWhite];
  [spinner startAnimating];
  self.activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

  UIImage* backIcon = [UIImage imageWithContentsOfFile:
                      NIPathForBundleResource(nil, @"NimbusWebController.bundle/gfx/backIcon.png")];
  // We weren't able to find the forward or back icons in your application's resources.
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
  //into your application with the "Create Folder References" option selected. You can verify that
  // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
  // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
  // copied in the Copy Bundle Resources phase.
  NIDASSERT(nil != backIcon);

  self.backButton =
  [[UIBarButtonItem alloc] initWithImage:backIcon
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(didTapBackButton)];
  self.backButton.tag = 2;
  self.backButton.enabled = NO;

  UIImage* forwardIcon = [UIImage imageWithContentsOfFile:
                  NIPathForBundleResource(nil, @"NimbusWebController.bundle/gfx/forwardIcon.png")];
  // We weren't able to find the forward or back icons in your application's resources.
  // Ensure that you've dragged the NimbusWebController.bundle from src/webcontroller/resources
  // into your application with the "Create Folder References" option selected. You can verify that
  // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
  // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
  // copied in the Copy Bundle Resources phase.
  NIDASSERT(nil != forwardIcon);

  self.forwardButton =
  [[UIBarButtonItem alloc] initWithImage:forwardIcon
                                   style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(didTapForwardButton)];
  self.forwardButton.tag = 1;
  self.forwardButton.enabled = NO;
  self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                    UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefreshButton)];
  self.refreshButton.tag = 3;
  self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                 UIBarButtonSystemItemStop target:self action:@selector(didTapStopButton)];
  self.stopButton.tag = 3;
  self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                   UIBarButtonSystemItemAction target:self action:@selector(didTapShareButton)];

  UIBarItem* flexibleSpace =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                 target: nil
                                                 action: nil];

  self.toolbar.items = [NSArray arrayWithObjects:
                    self.backButton,
                    flexibleSpace,
                    self.forwardButton,
                    flexibleSpace,
                    self.refreshButton,
                    flexibleSpace,
                    self.actionButton,
                    nil];
  [self.view addSubview:self.toolbar];

  self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
  [self updateWebViewFrame];
  self.webView.delegate = self;
  self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleHeight);
  self.webView.scalesPageToFit = YES;

  if ([UIColor respondsToSelector:@selector(underPageBackgroundColor)]) {
    self.webView.backgroundColor = [UIColor underPageBackgroundColor];
  }

  [self.view addSubview:self.webView];

  if (nil != self.loadRequest) {
    [self.webView loadRequest:self.loadRequest];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];

  self.actionSheet.delegate = nil;
  self.webView.delegate = nil;

  self.actionSheet = nil;
  self.webView = nil;
  self.toolbar = nil;
  self.backButton = nil;
  self.forwardButton = nil;
  self.refreshButton = nil;
  self.stopButton = nil;
  self.actionButton = nil;
  self.activityItem = nil;
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
  self.loadingURL = [request.mainDocumentURL copy];
  self.backButton.enabled = [self.webView canGoBack];
  self.forwardButton.enabled = [self.webView canGoForward];
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
  self.title = NSLocalizedString(@"Loading...", @"");
  if (!self.navigationItem.rightBarButtonItem) {
    [self.navigationItem setRightBarButtonItem:self.activityItem animated:YES];
  }

  NSInteger buttonIndex = 0;
  for (UIBarButtonItem* button in self.toolbar.items) {
    if (button.tag == 3) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
      [newItems replaceObjectAtIndex:buttonIndex withObject:self.stopButton];
      self.toolbar.items = newItems;
      break;
    }
    ++buttonIndex;
  }
  self.backButton.enabled = [self.webView canGoBack];
  self.forwardButton.enabled = [self.webView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
  self.loadingURL = nil;
  self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  if (self.navigationItem.rightBarButtonItem == self.activityItem) {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
  }

  NSInteger buttonIndex = 0;
  for (UIBarButtonItem* button in self.toolbar.items) {
    if (button.tag == 3) {
      NSMutableArray* newItems = [NSMutableArray arrayWithArray:self.toolbar.items];
      [newItems replaceObjectAtIndex:buttonIndex withObject:self.refreshButton];
      self.toolbar.items = newItems;
      break;
    }
    ++buttonIndex;
  }

  self.backButton.enabled = [self.webView canGoBack];
  self.forwardButton.enabled = [self.webView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
  self.loadingURL = nil;
  [self webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (actionSheet == self.actionSheet) {
    if (buttonIndex == 0) {
      [[UIApplication sharedApplication] openURL:self.actionSheetURL];
    } else if (buttonIndex == 1) {
      [[UIPasteboard generalPasteboard] setURL:self.actionSheetURL];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (actionSheet == self.actionSheet) {
    self.actionSheet.delegate = nil;
    self.actionSheet = nil;
    self.actionSheetURL = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)URL {
  return self.loadingURL ? self.loadingURL : self.webView.request.mainDocumentURL;
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
      [self.webView loadRequest:request];

    } else {
      [self.webView stopLoading];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarHidden:(BOOL)hidden {
  _toolbarHidden = hidden;
  if ([self isViewLoaded]) {
    self.toolbar.hidden = hidden;
    [self updateWebViewFrame];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarTintColor:(UIColor*)color {
  if (color != _toolbarTintColor) {
    _toolbarTintColor = color;
  }

  if ([self isViewLoaded]) {
    self.toolbar.tintColor = color;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet {
  if (actionSheet == self.actionSheet) {
    [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
    [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Copy URL", @"")];
  }
  return YES;
}


@end
