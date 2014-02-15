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

@class NIRadioGroup;
@protocol NICell;

/**
 * A controller that displays the set of options in a radio group.
 *
 * This controller is instantiated and pushed onto the navigation stack when the user taps a radio
 * group cell.
 *
 * @ingroup ModelTools
 */
@interface NIRadioGroupController : UITableViewController

// Designated initializer.
- (id)initWithRadioGroup:(NIRadioGroup *)radioGroup tappedCell:(id<NICell>)tappedCell;

@end

/**
 * Initializes a newly allocated radio group controller with the given radio group and cell.
 *
 * The radio group and cell are strongly referenced for the lifetime of this controller.
 *
 * @fn NIRadioGroupController::initWithRadioGroup:tappedCell:
 */
