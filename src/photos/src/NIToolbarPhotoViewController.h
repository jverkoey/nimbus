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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPhotoAlbumScrollView.h"
#import "NIPhotoScrubberView.h"

@class NIPhotoAlbumScrollView;

/**
 * A simple photo album view controller implementation with a toolbar.
 *
 * @ingroup NimbusPhotos
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
 *  toolbarIsTranslucent = YES;
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
 *  toolbarIsTranslucent = NO;
 *  chromeCanBeHidden = NO;
 *  photoAlbumView.zoomingIsEnabled = NO;
 * @endcode
 */
@interface NIToolbarPhotoViewController : UIViewController <NIPhotoAlbumScrollViewDelegate, NIPhotoScrubberViewDelegate>

#pragma mark Configuring Functionality

@property (nonatomic, assign, getter=isToolbarTranslucent) BOOL toolbarIsTranslucent; // default: yes
@property (nonatomic, assign) BOOL hidesChromeWhenScrolling; // default: yes
@property (nonatomic, assign) BOOL chromeCanBeHidden; // default: yes
@property (nonatomic, assign) BOOL animateMovingToNextAndPreviousPhotos; // default: no
@property (nonatomic, assign, getter=isScrubberEnabled) BOOL scrubberIsEnabled; // default: ipad yes - iphone no

#pragma mark Views

@property (nonatomic, readonly, strong) UIToolbar* toolbar;
@property (nonatomic, readonly, strong) NIPhotoAlbumScrollView* photoAlbumView;
@property (nonatomic, readonly, strong) NIPhotoScrubberView* photoScrubberView;
- (void)refreshChromeState;

#pragma mark Toolbar Buttons

@property (nonatomic, readonly, strong) UIBarButtonItem* nextButton;
@property (nonatomic, readonly, strong) UIBarButtonItem* previousButton;

#pragma mark Subclassing

- (void)setChromeVisibility:(BOOL)isVisible animated:(BOOL)animated;
- (void)setChromeTitle;

@end

/** @name Configuring Functionality */

/**
 * Whether the toolbar is translucent and shows photos beneath it or not.
 *
 * If this is enabled, the toolbar will be translucent and the photo view will
 * take up the entire view controller's bounds.
 *
 * If this is disabled, the photo will only occupy the remaining space above the
 * toolbar. The toolbar will also not be hidden when the chrome is dismissed. This is by design
 * because dismissing the toolbar when photos can't be displayed beneath it would leave
 * an empty space below the album.
 *
 * By default this is YES.
 *
 * @fn NIToolbarPhotoViewController::toolbarIsTranslucent
 */

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
 * @attention This will be set to NO if toolbarCanBeHidden is set to NO.
 *
 * @fn NIToolbarPhotoViewController::hidesChromeWhenScrolling
 */

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
 * @attention Setting this to NO will also disable hidesToolbarWhenScrolling.
 *
 * @fn NIToolbarPhotoViewController::chromeCanBeHidden
 */

/**
 * Whether to animate moving to a next or previous photo when the user taps the button.
 *
 * By default this is NO.
 *
 * @fn NIToolbarPhotoViewController::animateMovingToNextAndPreviousPhotos
 */

/**
 * Whether to show a scrubber in the toolbar instead of next/previous buttons.
 *
 * By default this is YES on the iPad and NO on the iPhone.
 *
 * @fn NIToolbarPhotoViewController::scrubberIsEnabled
 */


/** @name Views */

/**
 * The toolbar view.
 *
 * @fn NIToolbarPhotoViewController::toolbar
 */

/**
 * The photo album view.
 *
 * @fn NIToolbarPhotoViewController::photoAlbumView
 */

/**
 * The photo scrubber view.
 *
 * @fn NIToolbarPhotoViewController::photoScrubberView
 */


/** @name Toolbar Buttons */

/**
 * The 'next' button.
 *
 * @fn NIToolbarPhotoViewController::nextButton
 */

/**
 * The 'previous' button.
 *
 * @fn NIToolbarPhotoViewController::previousButton
 */
