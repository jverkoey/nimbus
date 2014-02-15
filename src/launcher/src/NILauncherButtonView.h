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
#import "NILauncherView.h"
#import "NILauncherViewModel.h"

/**
 * A launcher button view that displays an image and and a label beneath it.
 *
 * This view shows the icon anchored to the top middle of the view and the label anchored to the
 * bottom middle. By default the label is a single line label with NSLineBreakByTruncatingTail.
 *
 * @image html NILauncherButtonExample1.png "Example of an NILauncherButton"
 *
 * @ingroup NimbusLauncher
 */
@interface NILauncherButtonView : NIRecyclableView <NILauncherButtonView, NILauncherViewObjectView>

@property (nonatomic, strong) UIButton* button;
@property (nonatomic, copy) UILabel* label;

@property (nonatomic, assign) UIEdgeInsets contentInset;

@end

/** @name Accessing Subviews */

/**
 * The button view that should be used to display the launcher icon.
 *
 * @fn NILauncherButtonView::button
 */

/**
 * The label view that should show the title of the launcher item.
 *
 * @fn NILauncherButtonView::label
 */

/** @name Configuring Display Attributes */

/**
 * The distance that the button and label are inset from the enclosing view.
 *
 * The unit of size is points. The default value is 5 points on all sides.
 *
 * @fn NILauncherButtonView::contentInset
 */
