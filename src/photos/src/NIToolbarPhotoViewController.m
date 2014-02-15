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

#import "NIToolbarPhotoViewController.h"

#import "NIPhotoAlbumScrollView.h"

#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@implementation NIToolbarPhotoViewController {
  // Views
  UIToolbar*              _toolbar;
  NIPhotoAlbumScrollView* _photoAlbumView;

  // Scrubber View
  NIPhotoScrubberView* _photoScrubberView;

  // Toolbar Buttons
  UIBarButtonItem* _nextButton;
  UIBarButtonItem* _previousButton;

  // Gestures
  UITapGestureRecognizer* _tapGesture;

  // State
  BOOL _isAnimatingChrome;
  BOOL _isChromeHidden;
  BOOL _prefersStatusBarHidden;

  // Configuration
  BOOL _toolbarIsTranslucent;
  BOOL _hidesChromeWhenScrolling;
  BOOL _chromeCanBeHidden;
  BOOL _animateMovingToNextAndPreviousPhotos;
  BOOL _scrubberIsEnabled;
}


- (void)shutdown_NIToolbarPhotoViewController {
  _toolbar = nil;
  _photoAlbumView = nil;
  _nextButton = nil;
  _previousButton = nil;
  _photoScrubberView = nil;
  _tapGesture = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    // Default Configuration Settings
    self.toolbarIsTranslucent = YES;
    self.hidesChromeWhenScrolling = YES;
    self.chromeCanBeHidden = YES;
    self.animateMovingToNextAndPreviousPhotos = NO;
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
      self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // The scrubber is better use of the extra real estate on the iPad.
    // If you ask me, though, the scrubber works pretty well on the iPhone too. It's up
    // to you if you want to use it in your own implementations.
    self.scrubberIsEnabled = NIIsPad();

    // Allow the photos to display beneath the status bar.
    self.wantsFullScreenLayout = YES;
  }
  return self;
}

- (void)addTapGestureToView {
  if ([self isViewLoaded]) {
    if (nil == _tapGesture) {
      _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
      [self.photoAlbumView addGestureRecognizer:_tapGesture];
    }
  }

  _tapGesture.enabled = YES;
}

- (void)updateToolbarItems {
  UIBarItem* flexibleSpace =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                 target: nil
                                                 action: nil];

  if ([self isScrubberEnabled]) {
    _nextButton = nil;
    _previousButton = nil;

    if (nil == _photoScrubberView) {
      CGRect scrubberFrame = CGRectMake(0, 0,
                                        self.toolbar.bounds.size.width,
                                        self.toolbar.bounds.size.height);
      _photoScrubberView = [[NIPhotoScrubberView alloc] initWithFrame:scrubberFrame];
      _photoScrubberView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                             | UIViewAutoresizingFlexibleHeight);
      _photoScrubberView.delegate = self;
    }

    UIBarButtonItem* scrubberItem =
    [[UIBarButtonItem alloc] initWithCustomView:self.photoScrubberView];
    self.toolbar.items = [NSArray arrayWithObjects:
                          flexibleSpace, scrubberItem, flexibleSpace,
                          nil];

    [_photoScrubberView setSelectedPhotoIndex:self.photoAlbumView.centerPageIndex];
    
  } else {
    _photoScrubberView = nil;

    if (nil == _nextButton) {
      UIImage* nextIcon = [UIImage imageWithContentsOfFile:
                           NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/next.png")];

      // We weren't able to find the next or previous icons in your application's resources.
      // Ensure that you've dragged the NimbusPhotos.bundle from src/photos/resources into your
      // application with the "Create Folder References" option selected. You can verify that
      // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
      // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
      // copied in the Copy Bundle Resources phase.
      NIDASSERT(nil != nextIcon);

      _nextButton = [[UIBarButtonItem alloc] initWithImage: nextIcon
                                                     style: UIBarButtonItemStylePlain
                                                    target: self
                                                    action: @selector(didTapNextButton)];
      
    }

    if (nil == _previousButton) {
      UIImage* previousIcon = [UIImage imageWithContentsOfFile:
                               NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/previous.png")];

      // We weren't able to find the next or previous icons in your application's resources.
      // Ensure that you've dragged the NimbusPhotos.bundle from src/photos/resources into your
      // application with the "Create Folder References" option selected. You can verify that
      // you've done this correctly by expanding the NimbusPhotos.bundle file in your project
      // and verifying that the 'gfx' directory is blue. Also verify that the bundle is being
      // copied in the Copy Bundle Resources phase.
      NIDASSERT(nil != previousIcon);

      _previousButton = [[UIBarButtonItem alloc] initWithImage: previousIcon
                                                         style: UIBarButtonItemStylePlain
                                                        target: self
                                                        action: @selector(didTapPreviousButton)];
    }

    self.toolbar.items = [NSArray arrayWithObjects:
                          flexibleSpace, self.previousButton,
                          flexibleSpace, self.nextButton,
                          flexibleSpace,
                          nil];
  }

}

- (void)loadView {
  [super loadView];

  self.view.backgroundColor = [UIColor blackColor];

  CGRect bounds = self.view.bounds;

  // Toolbar Setup

  CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
  CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                   bounds.size.width, toolbarHeight);

  _toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
  _toolbar.barStyle = UIBarStyleBlack;
  _toolbar.translucent = self.toolbarIsTranslucent;
  _toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleTopMargin);

  [self updateToolbarItems];

  // Photo Album View Setup

  CGRect photoAlbumFrame = bounds;
  if (!self.toolbarIsTranslucent) {
    photoAlbumFrame = NIRectContract(bounds, 0, toolbarHeight);
  }
  _photoAlbumView = [[NIPhotoAlbumScrollView alloc] initWithFrame:photoAlbumFrame];
  _photoAlbumView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
  _photoAlbumView.delegate = self;

  [self.view addSubview:_photoAlbumView];
  [self.view addSubview:_toolbar];

  if (self.hidesChromeWhenScrolling || self.chromeCanBeHidden) {
    [self addTapGestureToView];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [[UIApplication sharedApplication] setStatusBarStyle: (NIIsPad()
                                                         ? UIStatusBarStyleBlackOpaque
                                                         : UIStatusBarStyleBlackTranslucent)
                                              animated: animated];

  UINavigationBar* navBar = self.navigationController.navigationBar;
  navBar.barStyle = UIBarStyleBlack;
  navBar.translucent = self.toolbarIsTranslucent;

  _previousButton.enabled = [self.photoAlbumView hasPrevious];
  _nextButton.enabled = [self.photoAlbumView hasNext];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}
#endif


- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.photoAlbumView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  [self.photoAlbumView willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                                        duration: duration];

  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                          duration:duration];

  CGRect toolbarFrame = self.toolbar.frame;
  toolbarFrame.size.height = NIToolbarHeightForOrientation(toInterfaceOrientation);
  toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
  self.toolbar.frame = toolbarFrame;

  if (!self.toolbarIsTranslucent) {
    CGRect photoAlbumFrame = self.photoAlbumView.frame;
    photoAlbumFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
    self.photoAlbumView.frame = photoAlbumFrame;
  }
}

- (UIView *)rotatingFooterView {
  return self.toolbar.hidden ? nil : self.toolbar;
}

- (void)didHideChrome {
  _isAnimatingChrome = NO;
  if (self.toolbarIsTranslucent) {
    self.toolbar.hidden = YES;
  }

  [self.navigationController setNavigationBarHidden:YES animated:NO];
  _isChromeHidden = YES;
}

- (void)didShowChrome {
  _isAnimatingChrome = NO;

  _isChromeHidden = NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
  return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
  return _prefersStatusBarHidden;
}

- (void)setChromeVisibility:(BOOL)isVisible animated:(BOOL)animated {
  if (_isAnimatingChrome
      || (!isVisible && _isChromeHidden)
      || (isVisible && !_isChromeHidden)
      || !self.chromeCanBeHidden) {
    // Nothing to do here.
    return;
  }

  CGRect toolbarFrame = self.toolbar.frame;
  CGRect bounds = self.view.bounds;

  if (self.toolbarIsTranslucent) {
    // Reset the toolbar's initial position.
    if (!isVisible) {
      toolbarFrame.origin.y = bounds.size.height - toolbarFrame.size.height;

    } else {
      // Ensure that the toolbar is visible through the animation.
      self.toolbar.hidden = NO;

      toolbarFrame.origin.y = bounds.size.height;
    }
    self.toolbar.frame = toolbarFrame;
  }

  // Show/hide the system chrome.
  BOOL isStatusBarAppearanceSupported = [self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
  if (!isStatusBarAppearanceSupported) {
    [[UIApplication sharedApplication] setStatusBarHidden:!isVisible
                                            withAnimation:(animated
                                                           ? UIStatusBarAnimationSlide
                                                           : UIStatusBarAnimationNone)];
  }

  if (self.toolbarIsTranslucent) {
    // Place the toolbar at its final location.
    if (isVisible) {
      // Slide up.
      toolbarFrame.origin.y = bounds.size.height - toolbarFrame.size.height;

    } else {
      // Slide down.
      toolbarFrame.origin.y = bounds.size.height;
    }
  }

  // If there is a navigation bar, place it at its final location.
  CGRect navigationBarFrame = self.navigationController.navigationBar.frame;

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:(isVisible
                                         ? @selector(didShowChrome)
                                         : @selector(didHideChrome))];

    // Ensure that the animation matches the status bar's.
    [UIView setAnimationDuration:NIStatusBarAnimationDuration()];
    [UIView setAnimationCurve:NIStatusBarAnimationCurve()];
  }

  if (isStatusBarAppearanceSupported) {
    _prefersStatusBarHidden = !isVisible;
    [self setNeedsStatusBarAppearanceUpdate];
  }

  if (nil != self.navigationController.navigationBar) {
    if (isVisible) {
      [UIView setAnimationsEnabled:NO];
      [self.navigationController setNavigationBarHidden:NO animated:NO];
      navigationBarFrame.origin.y = 0;
      self.navigationController.navigationBar.frame = navigationBarFrame;
      self.navigationController.navigationBar.alpha = 0;
      [UIView setAnimationsEnabled:YES];

      navigationBarFrame.origin.y = NIStatusBarHeight();

    } else {
      navigationBarFrame.origin.y = 0;
    }
  }

  if (self.toolbarIsTranslucent) {
    self.toolbar.frame = toolbarFrame;
  }
  if (nil != self.navigationController.navigationBar) {
    self.navigationController.navigationBar.frame = navigationBarFrame;
    self.navigationController.navigationBar.alpha = (isVisible ? 1 : 0);
  }

  if (animated) {
    _isAnimatingChrome = YES;
    [UIView commitAnimations];

  } else if (!isVisible) {
    [self didHideChrome];

  } else if (isVisible) {
    [self didShowChrome];
  }
}

- (void)toggleChromeVisibility {
  [self setChromeVisibility:(_isChromeHidden || _isAnimatingChrome) animated:YES];
}

#pragma mark - UIGestureRecognizer


- (void)didTap {
  SEL selector = @selector(toggleChromeVisibility);
  if (self.photoAlbumView.zoomingIsEnabled) {
    // Cancel any previous delayed performs so that we don't stack them.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];

    // We need to delay taking action on the first tap in case a second tap comes in, causing
    // a double-tap gesture to be recognized and the photo to be zoomed.
    [self performSelector: selector
               withObject: nil
               afterDelay: 0.3];

  } else {
    // When zooming is disabled, double-tap-to-zoom is also disabled so we don't have to
    // be as careful; just toggle the chrome immediately.
    [self toggleChromeVisibility];
  }
}

- (void)refreshChromeState {
  self.previousButton.enabled = [self.photoAlbumView hasPrevious];
  self.nextButton.enabled = [self.photoAlbumView hasNext];

  [self setChromeTitle];
}

- (void)setChromeTitle {
  self.title = [NSString stringWithFormat:@"%d of %d",
                (self.photoAlbumView.centerPageIndex + 1),
                self.photoAlbumView.numberOfPages];
}

#pragma mark - NIPhotoAlbumScrollViewDelegate


- (void)pagingScrollViewDidScroll:(NIPagingScrollView *)pagingScrollView {
  if (self.hidesChromeWhenScrolling) {
    [self setChromeVisibility:NO animated:YES];
  }
}

- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                   didZoomIn: (BOOL)didZoomIn {
  // This delegate method is called after a double-tap gesture, so cancel any pending
  // single-tap gestures.
  [NSObject cancelPreviousPerformRequestsWithTarget: self
                                           selector: @selector(toggleChromeVisibility)
                                             object: nil];
}

- (void)pagingScrollViewDidChangePages:(NIPagingScrollView *)pagingScrollView {
  // We animate the scrubber when the chrome won't disappear as a nice touch.
  // We don't bother animating if the chrome disappears when scrolling because the user
  // will barely see the animation happen.
  [self.photoScrubberView setSelectedPhotoIndex: [pagingScrollView centerPageIndex]
                                       animated: !self.hidesChromeWhenScrolling];

  [self refreshChromeState];
}

#pragma mark - NIPhotoScrubberViewDelegate


- (void)photoScrubberViewDidChangeSelection:(NIPhotoScrubberView *)photoScrubberView {
  [self.photoAlbumView moveToPageAtIndex:photoScrubberView.selectedPhotoIndex animated:NO];

  [self refreshChromeState];
}

#pragma mark - Actions


- (void)didTapNextButton {
  [self.photoAlbumView moveToNextAnimated:self.animateMovingToNextAndPreviousPhotos];
  
  [self refreshChromeState];
}

- (void)didTapPreviousButton {
  [self.photoAlbumView moveToPreviousAnimated:self.animateMovingToNextAndPreviousPhotos];

  [self refreshChromeState];
}

#pragma mark - Public


- (void)settoolbarIsTranslucent:(BOOL)enabled {
  _toolbarIsTranslucent = enabled;

  self.toolbar.translucent = enabled;
}

- (void)setHidesChromeWhenScrolling:(BOOL)hidesToolbar {
  _hidesChromeWhenScrolling = hidesToolbar;

  if (hidesToolbar) {
    [self addTapGestureToView];

  } else {
    [_tapGesture setEnabled:_chromeCanBeHidden];
  }
}

- (void)setChromeCanBeHidden:(BOOL)canBeHidden {
  _chromeCanBeHidden = canBeHidden;

  if (canBeHidden) {
    [self addTapGestureToView];

  } else {
    self.hidesChromeWhenScrolling = NO;

    if ([self isViewLoaded]) {
      // Ensure that the chrome is visible.
      [self setChromeVisibility:YES animated:NO];
    }
  }
}

- (void)setScrubberIsEnabled:(BOOL)enabled {
  if (_scrubberIsEnabled != enabled) {
    _scrubberIsEnabled = enabled;

    if ([self isViewLoaded]) {
      [self updateToolbarItems];
    }
  }
}

@end
