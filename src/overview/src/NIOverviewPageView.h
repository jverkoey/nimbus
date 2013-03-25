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

#import <UIKit/UIKit.h>

#if defined(DEBUG) || defined(NI_DEBUG)

#import "NIOverviewGraphView.h"

@class NIMemoryCache;

/**
 * A page in the Overview.
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewPageView : UIView {
@private
  NSString* _pageTitle;
  UILabel*  _titleLabel;
}

#pragma mark Creating a Page /** @name Creating a Page */

/**
 * Returns an autoreleased instance of this view.
 */
+ (NIOverviewPageView *)page;


#pragma mark Updating a Page /** @name Updating a Page */

/**
 * Request that this page update its information.
 *
 * Should be implemented by the subclass. The default implementation does nothing.
 */
- (void)update;


#pragma mark Configuring a Page /** @name Configuring a Page */

/**
 * The title of the page.
 */
@property (nonatomic, readwrite, copy) NSString* pageTitle;


/**
 * The following methods are provided to aid in subclassing and are not meant to be
 * used externally.
 */
#pragma mark Subclassing /** @name Subclassing */

/**
 * The title label for this page.
 *
 * By default this label will be placed flush to the bottom middle of the page.
 */
@property (nonatomic, readonly, NI_STRONG) UILabel* titleLabel;

/**
 * Creates a generic label for use in the page.
 */
- (UILabel *)label;

@end


/**
 * A page that renders a graph and two labels.
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewGraphPageView : NIOverviewPageView <
  NIOverviewGraphViewDataSource
> {
@private
  UILabel* _label1;
  UILabel* _label2;
  NIOverviewGraphView* _graphView;
  NSEnumerator* _eventEnumerator;
}

@property (nonatomic, readonly, NI_STRONG) UILabel* label1;
@property (nonatomic, readonly, NI_STRONG) UILabel* label2;
@property (nonatomic, readonly, NI_STRONG) NIOverviewGraphView* graphView;

@end


/**
 * A page that renders a graph showing free memory.
 *
 * @image html overview-memory1.png "The memory page."
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewMemoryPageView : NIOverviewGraphPageView {
@private
  NSEnumerator* _enumerator;
  unsigned long long _minMemory;
}

@end


/**
 * A page that renders a graph showing free disk space.
 *
 * @image html overview-disk1.png "The disk page."
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewDiskPageView : NIOverviewGraphPageView {
@private
  NSEnumerator* _enumerator;
  unsigned long long _minDiskUse;
}

@end


/**
 * A page that shows all of the logs sent to the console.
 *
 * @image html overview-log1.png "The log page."
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewConsoleLogPageView : NIOverviewPageView {
@private
  UIScrollView* _logScrollView;
  UILabel* _logLabel;
}

@end


/**
 * A page that allows you to modify NIMaxLogLevel.
 *
 * @image html overview-maxloglevel1.png "The max log level page."
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewMaxLogLevelPageView : NIOverviewPageView {
@private
  UISlider* _logLevelSlider;
  UILabel* _errorLogLevelLabel;
  UILabel* _warningLogLevelLabel;
  UILabel* _infoLogLevelLabel;
}

@end


/**
 * A page that shows information regarding an in-memory cache.
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewMemoryCachePageView : NIOverviewGraphPageView

/**
 * Returns an autoreleased instance of this page with the given cache.
 */
+ (id)pageWithCache:(NIMemoryCache *)cache;

@property (nonatomic, readwrite, NI_STRONG) NIMemoryCache* cache;
@end


/**
 * A page that adds run-time inspection features.
 *
 *      @ingroup Overview-Pages
 */
@interface NIInspectionOverviewPageView : NIOverviewPageView
@end


#endif
