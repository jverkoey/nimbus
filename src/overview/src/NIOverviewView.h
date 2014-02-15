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

#if defined(DEBUG) || defined(NI_DEBUG)

@class NIOverviewPageView;

/**
 * The root scrolling page view of the Overview.
 *
 * @ingroup Overview
 */
@interface NIOverviewView : UIView

/**
 * Whether the view has a translucent background or not.
 */
@property (nonatomic, assign) BOOL translucent;

/**
 * Whether the view can be draggable vertically or not.
 */
@property (nonatomic, assign) BOOL enableDraggingVertically;

/**
 * Prepends a new page to the Overview.
 */
- (void)prependPageView:(NIOverviewPageView *)page;

/**
 * Adds a new page to the Overview.
 */
- (void)addPageView:(NIOverviewPageView *)page;

/**
 * Removes a page from the Overview.
 */
- (void)removePageView:(NIOverviewPageView *)page;

/**
 * Update all of the views.
 */
- (void)updatePages;

- (void)flashScrollIndicators;

@end

#endif
