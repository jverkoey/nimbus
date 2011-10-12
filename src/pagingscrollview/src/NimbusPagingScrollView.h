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

/**
 * @defgroup NimbusPagingScrollView Nimbus Paging Scroll View
 * @{
 *
 * The Nimbus paging scroll view is powered by a datasource that allows you to separate the
 * data from the view. This makes it easy to efficiently recycle pages and only create as many
 * pages of content as may be visible at any given point in time. Nimbus' implementation also
 * provides helpful features such as keeping the center page centered when the device changes
 * orientation.
 *
 * Paging scroll views are commonly used in many iOS applications. Nimbus' Photos feature uses
 * this paging scroll view to power its NIPhotoAlbumScrollView.
 *
 * ## Building a Component with NIPagingScrollView
 *
 * NIPagingScrollView works much like a UITableView in that you must implement a data source
 * that provides the views for the scroll view on demand. The page views that you create must
 * conform to the NIPagingScrollViewPage protocol and be a subclass of UIView.
 */

/**@}*/

#import "NimbusCore.h"
#import "NIPagingScrollView.h"
#import "NIPagingScrollViewDataSource.h"
#import "NIPagingScrollViewDelegate.h"
#import "NIPagingScrollViewPage.h"
