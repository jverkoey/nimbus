//
// Copyright 2011-2012 Jeff Verkoeyen
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
#import "NimbusPagingScrollView.h"

/**
 * A single page in a launcher view.
 *
 * This is a recyclable page view that can be used with NIPagingScrollView.
 *
 * Each launcher page contains a set of views. The page lays out each of the views in a grid based
 * on the given display attributes.
 *
 * Views will be laid out from left to right and then from top to bottom.
 *
 *      @ingroup NimbusLauncher
 */
@interface NILauncherPageView : NIPageView

@property (nonatomic, readwrite, retain) NIViewRecycler* viewRecycler;

- (void)addRecyclableView:(UIView<NIRecyclableView> *)view;
@property (nonatomic, readonly, retain) NSArray* recyclableViews;

@property (nonatomic, readwrite, assign) UIEdgeInsets contentInset;
@property (nonatomic, readwrite, assign) CGSize viewSize;
@property (nonatomic, readwrite, assign) CGSize viewMargins;

@end

/** @name Recyclable Views */

/**
 * A shared view recycler for this page's recyclable views.
 *
 * When this page view is preparing for reuse it will add each of its button views to the recycler.
 * This recycler should be the same recycler used by all pages in the launcher view.
 *
 *      @fn NILauncherPageView::viewRecycler
 */

/**
 * Add a recyclable view to this page.
 *
 *      @param view A recyclable view.
 *      @fn NILauncherPageView::addRecyclableView:
 */

/**
 * All of the recyclable views that have been added to this page.
 *
 *      @returns An array of recyclable views in the same order in which they were added.
 *      @fn NILauncherPageView::recyclableViews
 */

/** @name Configuring Display Attributes */

/**
 * The distance that the recyclable views are inset from the enclosing view.
 *
 * Use this property to add to the area around the content. The unit of size is points.
 * The default value is UIEdgeInsetsZero.
 *
 *      @fn NILauncherPageView::contentInset
 */

/**
 * The size of each recyclable view.
 *
 * The unit of size is points. The default value is CGSizeZero.
 *
 *      @fn NILauncherPageView::viewSize
 */

/**
 * The recommended horizontal and vertical distance between each recyclable view.
 *
 * This property is only a recommended value because the page view does its best to distribute the
 * views in a way that visually balances them.
 *
 * Width is the horizontal distance between each view. Height is the vertical distance between each
 * view. The unit of size is points. The default value is CGSizeZero.
 *
 *      @fn NILauncherPageView::viewMargins
 */
