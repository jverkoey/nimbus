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

/**
 * @defgroup NimbusPhotos Nimbus Photos
 * @{
 *
 * Photo viewers are a common, non-trivial feature in many types of iOS apps ranging from
 * simple photo viewers to apps that fetch photos from an API. The Nimbus photo album viewer
 * is designed to consume minimal amounts of memory and encourage the use of threads to provide
 * a high quality user experience that doesn't include any blocking of the UI while images
 * are loaded from disk or the network. The photo viewer pre-caches images in an album to either
 * side of the current image so that the user will ideally always have a high-quality
 * photo experience.
 *
 *
 * <h2>Architecture</h2>
 *
 * The architectural design of the photo album view takes inspiration from UITableView. Images
 * are requested only when they might become visible and are released when they become
 * inaccessible again. Each page of the photo album view is a recycled NIPhotoScrollView.
 * These page views handle zooming and panning within a given photo. The photo album view
 * NIPhotoAlbumScrollView contains a paging scroll view of these page views and provides
 * interfaces for maintaining the orientation during rotations.
 *
 * The view controller NIToolbarPhotoViewcontroller is provided as a basic implementation of
 * functionality that is expected from a photo viewer. This includes: a toolbar with next and
 * previous arrows; auto-rotation support; and toggling the chrome.
 *
 *
 * <h2>Examples</h2>
 *
 * @image html photos-iphone-example1.png "Screenshot of the BasicPhotoAlbum application on the iPhone."
 *
 * Image source: <a href="http://www.flickr.com/photos/janekm/360669001/">flickr.com/photos/janekm/360669001</a>
 */

/**
 * The views and protocols used to display and interact with photos.
 *
 * NIPhotoAlbumScrollView is the meat of the Nimbus photo viewer's functionality. Contained
 * within this view are pages of NIPhotoScrollView views. In your view controller you are
 * expected to implement the NIPhotoAlbumScrollViewDataSource in order to provide the photo
 * album view with the necessary information for presenting an album.
 *
 * @defgroup Photos-Views Photo Views
 */

/**
 * Basic photo album view controller implementations.
 *
 * @defgroup Photos-Controllers Photo View Controllers
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusCore/NimbusCore.h"
#import "NimbusPhotos/NIPhotoViewController.h"
#import "NimbusPhotos/NIPhotoAlbumScrollView.h"
#import "NimbusPhotos/NIPhotoScrollView.h"
#else
#import "NimbusCore.h"
#import "NIToolbarPhotoViewController.h"
#import "NIPhotoAlbumScrollView.h"
#import "NIPhotoScrollView.h"
#endif

/**@}*/
