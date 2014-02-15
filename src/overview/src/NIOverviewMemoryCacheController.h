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

#import <UIKit/UIKit.h>

@class NIMemoryCache;

/**
 * A view controller that displays the contents of an in-memory cache.
 *
 * Requires the [models] feature.
 *
 * This controller provides useful debugging insights into the contents of an in-memory cache.
 * It presents a simple summary of the contents of the cache, followed by a listing of each
 * object in the cache.
 *
 * When the cache is a NIImageMemoryCache, the pixel information will also be displayed in the
 * summary and each of the images will be displayed.
 *
 * @ingroup Overview
 */
@interface NIOverviewMemoryCacheController : UITableViewController

// Designated initializer.
- (id)initWithMemoryCache:(NIMemoryCache *)cache;

@end

/**
 * Initializes a newly allocated cache controller with the given cache object.
 *
 * @fn NIOverviewImageCacheController::initWithMemoryCache:
 */
