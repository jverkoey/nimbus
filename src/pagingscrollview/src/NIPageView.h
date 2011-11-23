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

#import "NIPagingScrollViewPage.h"

#import <UIKit/UIKit.h>

/**
 * A skeleton implementation of a page view.
 *
 * This view simply implements the required properties of NIPagingScrollViewPage.
 *
 *      @ingroup NimbusPagingScrollView
 */
@interface NIPageView : UIView <NIPagingScrollViewPage> {
@private
  NSInteger _pageIndex;
  NSString* _reuseIdentifier;
}

@property (nonatomic, readwrite, assign) NSInteger pageIndex;
@property (nonatomic, readwrite, copy) NSString* reuseIdentifier;

@end

/**
 * The page index.
 *
 *      @fn NIPageView::pageIndex
 */

/**
 * The reuse identifier.
 *
 *      @fn NIPageView::reuseIdentifier
 */
