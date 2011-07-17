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

#import "NIToolbarPhotoViewController.h"

#import "NIPhotoAlbumScrollView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIToolbarPhotoViewController

@synthesize showPhotoAlbumBeneathToolbar = _showPhotoAlbumBeneathToolbar;
@synthesize hidesToolbarWhenScrolling = _hidesToolbarWhenScrolling;
@synthesize toolbarCanBeHidden = _toolbarCanBeHidden;
@synthesize animateMovingToNextAndPreviousPhotos = _animateMovingToNextAndPreviousPhotos;
@synthesize toolbar = _toolbar;
@synthesize photoAlbumView = _photoAlbumView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.showPhotoAlbumBeneathToolbar = YES;
    self.hidesToolbarWhenScrolling = YES;
    self.toolbarCanBeHidden = YES;
    self.animateMovingToNextAndPreviousPhotos = NO;

    // Allow the photos to display beneath the status bar.
    self.wantsFullScreenLayout = YES;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTapGestureToView {
  if ([self isViewLoaded]
      && nil != NIUITapGestureRecognizerClass()
      && [self.photoAlbumView respondsToSelector:@selector(addGestureRecognizer:)]) {
    if (nil == _tapGesture) {
      _tapGesture =
      [[NIUITapGestureRecognizerClass() alloc] initWithTarget: self
                                                       action: @selector(didTap)];
    }

    [self.photoAlbumView addGestureRecognizer:_tapGesture];
  }

  [_tapGesture setEnabled:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  CGRect bounds = self.view.bounds;

  CGFloat toolbarHeight = NIToolbarHeightForOrientation(NIInterfaceOrientation());
  CGRect toolbarFrame = CGRectMake(0, bounds.size.height - toolbarHeight,
                                   bounds.size.width, toolbarHeight);

  _toolbar = [[[UIToolbar alloc] initWithFrame:toolbarFrame] autorelease];
  _toolbar.barStyle = UIBarStyleBlack;
  _toolbar.translucent = self.showPhotoAlbumBeneathToolbar;
  _toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                               | UIViewAutoresizingFlexibleTopMargin);

  UIImage* nextIcon = [UIImage imageWithContentsOfFile:
                       NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/next.png")];
  UIImage* previousIcon = [UIImage imageWithContentsOfFile:
                           NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/previous.png")];

  _nextButton = [[UIBarButtonItem alloc] initWithImage: nextIcon
                                                 style: UIBarButtonItemStylePlain
                                                target: self
                                                action: @selector(didTapNextButton)];

  _previousButton = [[UIBarButtonItem alloc] initWithImage: previousIcon
                                                     style: UIBarButtonItemStylePlain
                                                    target: self
                                                    action: @selector(didTapPreviousButton)];

  _playButton =
  [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemPlay
                                                target: self
                                                action: @selector(didTapPlayButton)];

  UIBarItem* flexibleSpace =
  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                 target: nil
                                                 action: nil] autorelease];

  _toolbar.items = [NSArray arrayWithObjects:
                    flexibleSpace, _previousButton,
                    flexibleSpace, _nextButton,
                    flexibleSpace,
                    nil];

  CGRect photoAlbumFrame = bounds;
  if (!self.showPhotoAlbumBeneathToolbar) {
    photoAlbumFrame = NIRectContract(bounds, 0, toolbarHeight);
  }
  _photoAlbumView = [[[NIPhotoAlbumScrollView alloc] initWithFrame:photoAlbumFrame] autorelease];
  _photoAlbumView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleHeight);
  _photoAlbumView.delegate = self;

  [self.view addSubview:_photoAlbumView];
  [self.view addSubview:_toolbar];

  if (self.hidesToolbarWhenScrolling) {
    [self addTapGestureToView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  // We don't have to release the views here because self.view is the only thing retaining them.
  _photoAlbumView = nil;
  _toolbar = nil;

  NI_RELEASE_SAFELY(_nextButton);
  NI_RELEASE_SAFELY(_previousButton);
  NI_RELEASE_SAFELY(_playButton);

  NI_RELEASE_SAFELY(_tapGesture);

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent
                                              animated: animated];

  _previousButton.enabled = [self.photoAlbumView hasPrevious];
  _nextButton.enabled = [self.photoAlbumView hasNext];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                duration: (NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.photoAlbumView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                          duration:duration];

  CGRect toolbarFrame = self.toolbar.frame;
  toolbarFrame.size.height = NIToolbarHeightForOrientation(toInterfaceOrientation);
  toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
  self.toolbar.frame = toolbarFrame;

  if (!self.showPhotoAlbumBeneathToolbar) {
    CGRect photoAlbumFrame = self.photoAlbumView.frame;
    photoAlbumFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
    self.photoAlbumView.frame = photoAlbumFrame;
  }

  [self.photoAlbumView willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                                        duration: duration];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didFadeOutToolbar {
  self.toolbar.hidden = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarVisibility:(BOOL)isVisible animated:(BOOL)animated {
  if (!isVisible && 0 == self.toolbar.alpha
      || isVisible && 1 == self.toolbar.alpha
      || !self.toolbarCanBeHidden) {
    // Nothing to do here.
    return;
  }

  if (isVisible) {
    self.toolbar.hidden = NO;
  }

  if (animated) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];

    if (!isVisible) {
      [UIView setAnimationDidStopSelector:@selector(didFadeOutToolbar)];
    }
  }

  self.toolbar.alpha = isVisible ? 1 : 0;

  if (animated) {
    [UIView commitAnimations];

  } else if (!isVisible) {
    [self didFadeOutToolbar];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)toggleToolbar {
  [self setToolbarVisibility:(self.toolbar.alpha < 1) animated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIGestureRecognizer


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTap {
  SEL selector = @selector(toggleToolbar);
  if (self.photoAlbumView.zoomingIsEnabled) {
    // We need to delay taking action on the first tap in case a second tap comes in, causing
    // a double-tap gesture to be recognized and the photo to be zoomed.
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];

    [self performSelector: selector
               withObject: nil
               afterDelay: 0.3];

  } else {
    // If zooming isn't allow then we just toggle the toolbar immediately.
    [self toggleToolbar];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIPhotoAlbumScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollViewDidScroll:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
  if (self.hidesToolbarWhenScrolling) {
    [self setToolbarVisibility:NO animated:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollView: (NIPhotoAlbumScrollView *)photoAlbumScrollView
                   didZoomIn: (BOOL)didZoomIn {
  [NSObject cancelPreviousPerformRequestsWithTarget: self
                                           selector: @selector(toggleToolbar)
                                             object: nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)photoAlbumScrollViewDidChangePages:(NIPhotoAlbumScrollView *)photoAlbumScrollView {
  _previousButton.enabled = [photoAlbumScrollView hasPrevious];
  _nextButton.enabled = [photoAlbumScrollView hasNext];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Actions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapNextButton {
  [self.photoAlbumView moveToNextAnimated:self.animateMovingToNextAndPreviousPhotos];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapPreviousButton {
  [self.photoAlbumView moveToPreviousAnimated:self.animateMovingToNextAndPreviousPhotos];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTapPlayButton {

}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHidesToolbarWhenScrolling:(BOOL)hidesToolbar {
  _hidesToolbarWhenScrolling = hidesToolbar;

  if (hidesToolbar) {
    [self addTapGestureToView];

  } else {
    [_tapGesture setEnabled:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setToolbarCanBeHidden:(BOOL)canBeHidden {
  _toolbarCanBeHidden = canBeHidden;

  if (!canBeHidden) {
    self.hidesToolbarWhenScrolling = NO;

    // Ensure that the toolbar is visible.
    self.toolbar.hidden = NO;
    self.toolbar.alpha = 1;
  }
}


@end
