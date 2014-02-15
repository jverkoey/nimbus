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

/**
 * @defgroup NimbusPhotos Nimbus Photos
 * @{
 *
 * <div id="github" feature="photos"></div>
 *
 * Photo viewers are a common, non-trivial feature in many types of iOS apps ranging from
 * simple photo viewers to apps that fetch photos from an API. The Nimbus photo album viewer
 * is designed to consume minimal amounts of memory and encourage the use of threads to provide
 * a high quality user experience that doesn't include any blocking of the UI while images
 * are loaded from disk or the network. The photo viewer pre-caches images in an album to either
 * side of the current image so that the user will ideally always have a high-quality
 * photo experience.
 *
 * <h2>Adding the Photos Feature to Your Application</h2>
 *
 * The Nimbus Photos feature uses a small number of custom photos that are stored in the
 * NimbusPhotos bundle. You must add this bundle to your application, ensuring that you select
 * the "Create Folder References" option and that the bundle is copied in the
 * "Copy Bundle Resources" phase.
 *
 * The bundle can be found at <code>src/photos/resources/NimbusPhotos.bundle</code>.
 *
 *
 * <h2>Feature Breakdown</h2>
 *
 * NIPhotoAlbumScrollView - A paged scroll view that implements a data source similar to that
 * of UITableView. This scroll view consumes minimal amounts of memory and is built to be fast
 * and responsive.
 *
 * NIPhotoScrollView - A single page within the NIPhotoAlbumScrollView. This view implements
 * the zooming and rotation functionality for a photo.
 *
 * NIPhotoScrubberView - A scrubber view for skimming through a set of photos. This view
 * made its debut by Apple on the iPad in Photos.app. Nimbus' implementation of this view
 * is built to be responsive and consume little memory.
 *
 * NIToolbarPhotoViewController - A skeleton implementation of a view controller that includes
 * multiple configurable properties. This controller will show a scrubber on the iPad and
 * next/previous arrows on the iPhone. It also provides support for hiding and showing the
 * app's chrome. If you wish to use this controller you must simply implement the data source
 * for the photo album. NetworkPhotoAlbum in the examples/photos directory demos building
 * a data source that fetches its information from the network.
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
 * The view controller NIToolbarPhotoViewController is provided as a basic implementation of
 * functionality that is expected from a photo viewer. This includes: a toolbar with next and
 * previous arrows; auto-rotation support; and toggling the chrome.
 *
 * <h3>NIPhotoAlbumScrollView</h3>
 *
 * NIPhotoAlbumScrollView is the meat of the Nimbus photo viewer's functionality. Contained
 * within this view are pages of NIPhotoScrollView views. In your view controller you are
 * expected to implement the NIPhotoAlbumScrollViewDataSource in order to provide the photo
 * album view with the necessary information for presenting an album.
 *
 *
 * <h2>Example Applications</h2>
 *
 * <h3>Network Photo Albums</h3>
 *
 * <a href="https://github.com/jverkoey/nimbus/tree/master/examples/photos/NetworkPhotoAlbums">View the README on GitHub</a>
 *
 * This sample application demos the use of the multiple photo APIs to fetch photos from public
 * photo album and display them in high-definition on the iPad and iPhone.
 *
 * The following APIs are currently demoed:
 *
 * - Facebook Graph API
 * - Dribbble Shots
 *
 * Sample location: <code>examples/photos/NetworkPhotoAlbums</code>
 *
 *
 * <h2>Screenshots</h2>
 *
 * @image html photos-iphone-example1.png "Screenshot of a basic photo album on the iPhone."
 *
 * Image source: <a href="http://www.flickr.com/photos/janekm/360669001/">flickr.com/photos/janekm/360669001</a>
 */

/**@}*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPhotoAlbumScrollView.h"
#import "NIPhotoAlbumScrollViewDataSource.h"
#import "NIPhotoAlbumScrollViewDelegate.h"
#import "NIPhotoScrollView.h"
#import "NIPhotoScrollViewDelegate.h"
#import "NIPhotoScrollViewPhotoSize.h"
#import "NIPhotoScrubberView.h"
#import "NIToolbarPhotoViewController.h"

#import "NimbusPagingScrollView.h"
#import "NimbusCore.h"
