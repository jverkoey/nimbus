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

#ifdef DEBUG

#import "NIOverviewerGraphView.h"

@interface NIOverviewerPageView : UIView {
@private
  NSString* _pageTitle;
  UILabel*  _titleLabel;
}

/**
 * Returns an autoreleased instance of this view.
 */
+ (NIOverviewerPageView *)page;

@property (nonatomic, readonly, retain) UILabel* titleLabel;

/**
 * Request that this page update its information.
 *
 * Should be implemented by the subclass. The default implementation does nothing.
 */
- (void)update;

- (UILabel *)label;

/**
 * The title of the page.
 */
@property (nonatomic, readwrite, copy) NSString* pageTitle;

@end

@interface NIOverviewerGraphPageView : NIOverviewerPageView {
@private
  UILabel* _label1;
  UILabel* _label2;
  NIOverviewerGraphView* _graphView;
}

@property (nonatomic, readonly, retain) UILabel* label1;
@property (nonatomic, readonly, retain) UILabel* label2;
@property (nonatomic, readonly, retain) NIOverviewerGraphView* graphView;

@end

@interface NIOverviewerMemoryPageView : NIOverviewerGraphPageView <
  NIOverviewerGraphViewDataSource
> {
@private
  NSEnumerator* _enumerator;
  unsigned long long _minMemory;
}

@end

@interface NIOverviewerDiskPageView : NIOverviewerGraphPageView <
  NIOverviewerGraphViewDataSource
> {
@private
  NSEnumerator* _enumerator;
  unsigned long long _minDiskUse;
}

@end

@interface NIOverviewerConsoleLogPageView : NIOverviewerPageView {
@private
  UIScrollView* _logScrollView;
  UILabel* _logLabel;
}

@end

#endif