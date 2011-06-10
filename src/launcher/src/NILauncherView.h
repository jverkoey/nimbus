//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

@class NILauncherButtonPresInfo;
@class NILauncherButton;

@protocol NILauncherDelegate;
@protocol NILauncherDataSource;

/**
 * @brief A launcher view that simulates iOS' home screen launcher functionality.
 * @ingroup Launcher-User-Interface
 */
@interface NILauncherView : UIView {
@private
  // Views
  UIScrollView*   _scrollView;
  UIPageControl*  _pager;

  // Display Information
  NSInteger       _columnCount;
  NSInteger       _rowCount;

  // Protocols
  id<NILauncherDelegate>    _delegate;
  id<NILauncherDataSource>  _dataSource;
}

/**
 * @brief The launcher view notifies the delegate of any user interaction or state changes.
 */
@property (nonatomic, assign) id<NILauncherDelegate> delegate;

@end


/**
 * @brief The launcher delegate used to inform of state changes and user interactions.
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItem:(NILauncherButtonPresInfo *)item;

@end


/**
 * @brief The launcher data source used to populate the view.
 * @ingroup Launcher-Protocols
 */
@protocol NILauncherDataSource

- (void)launcherView:(NILauncherView *)launcher didSelectItem:(NILauncherButtonPresInfo *)item;

@end

/**
 * @brief The presentation information for an individual item.
 * @ingroup Launcher-Presentation-Information
 */
@interface NILauncherButtonPresInfo : NSObject {

}

@end

/**
 * @brief The individual button view that the user taps.
 * @ingroup Launcher-User-Interface
 */
@interface NILauncherButton : UIButton {

}

@end
