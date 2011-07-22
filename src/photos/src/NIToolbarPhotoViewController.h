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
#import <UIKit/UIKit.h>

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusPhotos/NIPhotoAlbumScrollView.h"
#import "NimbusPhotos/NIPhotoScrubberView.h"
#else
#import "NIPhotoAlbumScrollView.h"
#import "NIPhotoScrubberView.h"
#endif

@class NIPhotoAlbumScrollView;

/**
 * A simple photo album view controller implementation with a toolbar.
 *
 *      @ingroup Photos-Controllers
 *
 * This controller does not implement the photo album data source, it simply implements
 * some of the most common UI elements that are associated with a photo viewer.
 *
 * For an example of implementing the data source, see the photos examples in the
 * examples directory.
 *
 * <h2>Implementing Delegate Methods</h2>
 *
 * This view controller already implements NIPhotoAlbumScrollViewDelegate. If you want to
 * implement methods of this delegate you should take care to call the super implementation
 * if necessary. The following methods have implementations in this class:
 *
 * - photoAlbumScrollViewDidScroll:
 * - photoAlbumScrollView:didZoomIn:
 * - photoAlbumScrollViewDidChangePages:
 *
 *
 * <h2>Recommended Configurations</h2>
 *
 * <h3>Default: Zooming enabled with translucent toolbar</h3>
 *
 * The default settings are good for showing a photo album that takes up the entire screen.
 * The photos will be visible beneath the toolbar because it is translucent. The chrome will
 * be hidden whenever the user starts interacting with the photos.
 *
 * @code
 *  showPhotoAlbumBeneathToolbar = YES;
 *  hidesChromeWhenScrolling = YES;
 *  chromeCanBeHidden = YES;
 * @endcode
 *
 * <h3>Zooming disabled with opaque toolbar</h3>
 *
 * The following settings are good for viewing photo albums when you want to keep the chrome
 * visible at all times without zooming enabled.
 *
 * @code
 *  showPhotoAlbumBeneathToolbar = NO;
 *  chromeCanBeHidden = NO;
 *  photoAlbumView.zoomingIsEnabled = NO;
 * @endcode
 */
@interface NIToolbarPhotoViewController : UIViewController <
  NIPhotoAlbumScrollViewDelegate,
  NIPhotoScrubberViewDelegate > {
@private
  // Views
  UIToolbar*              _toolbar;
  NIPhotoAlbumScrollView* _photoAlbumView;

  // Toolbar Buttons
  UIBarButtonItem* _nextButton;
  UIBarButtonItem* _previousButton;

  // Scrubber View
  NIPhotoScrubberView* _photoScrubberView;

  // Gestures
  UITapGestureRecognizer* _tapGesture;

  // State
  BOOL _isAnimatingChrome;

  // Configuration
  BOOL _showPhotoAlbumBeneathToolbar;
  BOOL _hidesChromeWhenScrolling;
  BOOL _chromeCanBeHidden;
  BOOL _animateMovingToNextAndPreviousPhotos;
  BOOL _scrubberIsEnabled;
}

#pragma mark Configuring Functionality /** @name Configuring Functionality */

/**
 * Whether to show the photo album view beneath the toolbar or not.
 *
 * If this is enabled, the toolbar will be translucent and the photo view will
 * take up the entire view controller's bounds with the toolbar shown on top.
 *
 * If this is disabled, the photo will only occupy the remaining space above the
 * toolbar.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL showPhotoAlbumBeneathToolbar;

/**
 * Whether or not to hide the chrome when the user begins interacting with the photo.
 *
 * If this is enabled, then the chrome will be hidden when the user starts swiping from
 * one photo to another.
 *
 * The chrome is the toolbar and the system status bar.
 *
 * By default this is YES.
 *
 *      @attention This will be set to NO if toolbarCanBeHidden is set to NO.
 */
@property (nonatomic, readwrite, assign) BOOL hidesChromeWhenScrolling;

/**
 * Whether or not to allow hiding the chrome.
 *
 * If this is enabled then the user will be able to single-tap to dismiss or show the
 * toolbar.
 *
 * The chrome is the toolbar and the system status bar.
 *
 * If this is disabled then the chrome will always be visible.
 *
 * By default this is YES.
 *
 *      @attention Setting this to NO will also disable hidesToolbarWhenScrolling.
 */
@property (nonatomic, readwrite, assign) BOOL chromeCanBeHidden;

/**
 * Whether to animate moving to a next or previous photo when the user taps the button.
 *
 * By default this is NO.
 */
@property (nonatomic, readwrite, assign) BOOL animateMovingToNextAndPreviousPhotos;

/**
 * Whether to show a scrubber in the toolbar instead of next/previous buttons.
 *
 * By default this is YES on the iPad and NO on the iPhone.
 */
@property (nonatomic, readwrite, assign, getter=isScrubberEnabled) BOOL scrubberIsEnabled;


#pragma mark Views /** @name Views */

/**
 * The toolbar view.
 */
@property (nonatomic, readonly, retain) UIToolbar* toolbar;

/**
 * The photo album view.
 */
@property (nonatomic, readonly, retain) NIPhotoAlbumScrollView* photoAlbumView;

/**
 * The photo scrubber view.
 */
@property (nonatomic, readonly, retain) NIPhotoScrubberView* photoScrubberView;


#pragma mark Toolbar Buttons /** @name Toolbar Buttons */

/**
 * The 'next' button.
 */
@property (nonatomic, readonly, retain) UIBarButtonItem* nextButton;

/**
 * The 'previous' button.
 */
@property (nonatomic, readonly, retain) UIBarButtonItem* previousButton;


@end
