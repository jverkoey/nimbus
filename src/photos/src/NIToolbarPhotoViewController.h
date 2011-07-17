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
#else
#import "NIPhotoAlbumScrollView.h"
#endif

@class NIPhotoAlbumScrollView;

@interface NIToolbarPhotoViewController : UIViewController <
  NIPhotoAlbumScrollViewDelegate
> {
@private
  // Views
  UIToolbar*              _toolbar;
  NIPhotoAlbumScrollView* _photoAlbumView;

  // Toolbar buttons
  UIBarButtonItem* _nextButton;
  UIBarButtonItem* _previousButton;
  UIBarButtonItem* _playButton;

  // Gestures
  UITapGestureRecognizer* _tapGesture;

  // Configuration
  BOOL _showPhotoAlbumBeneathToolbar;
  BOOL _hidesToolbarWhenScrolling;
  BOOL _toolbarCanBeHidden;
  BOOL _animateMovingToNextAndPreviousPhotos;
}

#pragma mark Configuring Functionality

/**
 * Whether to show the photo album view beneath the toolbar or not.
 *
 * If this is enabled, the toolbar will be translucent and the photo view will
 * take up the entire view controller's bounds with the toolbar shown on top.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL showPhotoAlbumBeneathToolbar;

/**
 * Whether or not to hide the toolbar when the user begins interacting with the photo.
 *
 * This will be NO if toolbarCanBeHidden is NO.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL hidesToolbarWhenScrolling;

/**
 * Whether or not to allow hiding the toolbar.
 *
 * Setting this to NO will also disable hidesToolbarWhenScrolling.
 *
 * By default this is YES.
 */
@property (nonatomic, readwrite, assign) BOOL toolbarCanBeHidden;

/**
 * Whether to animate moving to a next or previous photo when the user taps the button.
 *
 * By default this is NO.
 */
@property (nonatomic, readwrite, assign) BOOL animateMovingToNextAndPreviousPhotos;


#pragma mark Views

/**
 * The toolbar view.
 */
@property (nonatomic, readonly, retain) UIToolbar* toolbar;

/**
 * The photo album view.
 */
@property (nonatomic, readonly, retain) NIPhotoAlbumScrollView* photoAlbumView;

@end
