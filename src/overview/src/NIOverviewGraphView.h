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

@protocol NIOverviewGraphViewDataSource;

/**
 * A graph view.
 *
 *      @ingroup Overview-Pages
 */
@interface NIOverviewGraphView : UIView {
@private
  __unsafe_unretained id<NIOverviewGraphViewDataSource> _dataSource;
}

/**
 * The data source for this graph view.
 */
@property (nonatomic, readwrite, assign) id<NIOverviewGraphViewDataSource> dataSource;

@end

/**
 * The data source for NIOverviewGraphView.
 *
 *      @ingroup Overview-Pages
 */
@protocol NIOverviewGraphViewDataSource <NSObject>

@required

/**
 * Fetches the total range of all x values for this graph.
 */
- (CGFloat)graphViewXRange:(NIOverviewGraphView *)graphView;

/**
 * Fetches the total range of all y values for this graph.
 */
- (CGFloat)graphViewYRange:(NIOverviewGraphView *)graphView;

/**
 * The data source should reset its iterator for fetching points in the graph.
 */
- (void)resetPointIterator;

/**
 * Fetches the next point in the graph to plot.
 */
- (BOOL)nextPointInGraphView: (NIOverviewGraphView *)graphView
                       point: (CGPoint *)point;

/**
 * The data source should reset its iterator for fetching events in the graph.
 */
- (void)resetEventIterator;

/**
 * Fetches the next event in the graph to plot.
 */
- (BOOL)nextEventInGraphView: (NIOverviewGraphView *)graphView
                      xValue: (CGFloat *)xValue
                       color: (UIColor **)color;

@end
