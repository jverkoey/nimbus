//
// Copyright 2011-2014 NimbusKit
// Originally created by Roger Chapman
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

/**
 * @defgroup NimbusBadge Nimbus Badge
 * @{
 *
 * <div id="github" feature="badge"></div>
 *
 * This Nimbus badge view is a UIView that draws a customizable notification badge-like view.
 *
 * @image html badge-iphone-example1.png "Screenshot of a Nimbus badge on the iPhone"
 *
 * <h2>Minimum Requirements</h2>
 *
 * Required frameworks:
 *
 * - Foundation.framework
 * - UIKit.framework
 *
 * Minimum Operating System: <b>iOS 4.0</b>
 *
 * Source located in <code>src/badge/src</code>
 *
@code
#import "NimbusBadge.h"
@endcode
 *
 * <h2>Basic Use</h2>
 *
 * The badge view works much like UILabel. Once you've assigned text and configured the attributes
 * you should call sizeToFit to have the badge determine its ideal size.
 *
@code
NIBadgeView* badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
badgeView.text = @"7";
[badgeView sizeToFit];
[self.view addSubview:badgeView];
@endcode
 *
 * @}
 */

#import <Foundation/Foundation.h>

#import "NimbusCore.h"
#import "NIBadgeView.h"