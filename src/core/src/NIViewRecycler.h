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
 * For recycling views.
 *
 * @ingroup NimbusCore
 * @defgroup Core-View-Recycling View Recyling
 * @{
 *
 * View recycling is an important aspect of iOS memory management and performance. If you've
 * ever built a UITableView then you have dabbled with view recycling via the table cell dequeue
 * mechanism. NIViewRecycler implements similar functionality and allows you to implement
 * a recycling mechanism within your own views and controllers.
 */

@protocol NIRecyclableView;

/**
 * An object for efficiently reusing views by recycling and dequeuing them from a pool of views.
 *
 * This sort of object is what UITableView and NIPagingScrollView use to recycle their views.
 */
@interface NIViewRecycler : NSObject {
@private
  NSMutableDictionary* _reuseIdentifiersToRecycledViews;
}

- (UIView<NIRecyclableView> *)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier;

- (void)recycleView:(UIView<NIRecyclableView> *)view;

@end

/**
 * The protocol for a recyclable view.
 */
@protocol NIRecyclableView <NSObject>

@optional

/**
 * The identifier used to categorize views into buckets for reuse.
 *
 * Views will be reused when a new view is requested with a matching identifier.
 *
 * If the reuseIdentifier is nil then the class name will be used.
 */
@property (nonatomic, readwrite, copy) NSString* reuseIdentifier;

/**
 * Called immediately after the view has been dequeued from the recycled view pool.
 */
- (void)prepareForReuse;

@end

/**@}*/ // End of View Recyling

/**
 * Dequeues a reusable view from the recycled pages pool if one exists, otherwise returns nil.
 *
 *      @fn NIViewRecycler::dequeueReusableViewWithIdentifier:
 *      @param reuseIdentifier  Often the name of the class of view you wish to fetch.
 */

/**
 * Adds a given view to the recycle pages pool.
 *
 *      @fn NIViewRecycler::recycleView:
 *      @param view   The view to recycle. The reuse identifier will be retrieved from the view
 *                    via the NIRecyclableView protocol.
 */
