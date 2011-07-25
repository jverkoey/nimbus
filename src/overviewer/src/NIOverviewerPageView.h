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

@interface NIOverviewerPageView : UIView {
@private
  NSString* _pageTitle;
}

/**
 * Returns an autoreleased instance of this view.
 */
+ (NIOverviewerPageView *)page;

/**
 * Request that this page update its information.
 *
 * Should be implemented by the subclass. The default implementation does nothing.
 */
- (void)update;

/**
 * The title of the page.
 */
@property (nonatomic, readwrite, copy) NSString* pageTitle;

@end

@interface NIOverviewerMemoryPageView : NIOverviewerPageView {
@private
  UILabel* _memoryLabel;
}

@end

#endif