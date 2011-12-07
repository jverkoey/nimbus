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

/**
 * For recycling views in scroll views.
 *
 * @ingroup NimbusCore
 * @defgroup Core-View-Recycling View Recyling
 * @{
 *
 * View recycling is an important aspect of iOS memory management and performance when building
 * scroll view. When you use UITableView you use view recycling via the table cell dequeue
 * mechanism. NIViewRecycler implements this recycling functionality, allowing you to implement
 * recycling mechanisms in your own views and controllers.
 *
 *
 * <h2>Example Use</h2>
 *
 * Imagine building a UITableView. We'll assume that a viewRecycler object exists in the view.
 *
 * Views are usually recycled once they are no longer on screen, so within a did scroll event
 * we might have code like the following:
 *
@code
for (UIView<NIRecyclableView>* view in visibleViews) {
  if (![self isVisible:view]) {
    [viewRecycler recycleView:view];
    [view removeFromSuperview];
  }
}
@endcode
 *
 * This will take the views that are no longer visible and add them to the recycler. At a later
 * point in that same did scroll code we will check if there are any new views that are visible.
 * This is when we try to dequeue a recycled view from the recycler.
 *
@code
UIView<NIRecyclableView>* view = [viewRecycler dequeueReusableViewWithIdentifier:reuseIdentifier];
if (nil == view) {
  // Allocate a new view that conforms to the NIRecyclableView protocol.
  view = [[[...]] autorelease];
}
[self addSubview:view];
@endcode
 *
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
- (void)removeAllViews;

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
 * Dequeues a reusable view from the recycled views pool if one exists, otherwise returns nil.
 *
 *      @fn NIViewRecycler::dequeueReusableViewWithIdentifier:
 *      @param reuseIdentifier  Often the name of the class of view you wish to fetch.
 */

/**
 * Adds a given view to the recycled views pool.
 *
 *      @fn NIViewRecycler::recycleView:
 *      @param view   The view to recycle. The reuse identifier will be retrieved from the view
 *                    via the NIRecyclableView protocol.
 */

/**
 * Removes all of the views from the recycled views pool.
 *
 *      @fn NIViewRecycler::removeAllViews
 */
