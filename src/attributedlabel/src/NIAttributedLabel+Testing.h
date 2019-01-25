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

#import "NIAttributedLabel.h"

/**
 * A category exposing methods that are exercised by unit tests.
 */
@interface NIAttributedLabel (Testing)

/**
 * The text checking result for the link that is currently being touched or nil if no link is
 * being touched.
 */
@property (nonatomic, strong) NSTextCheckingResult *touchedLink;

/**
 * An internal method that is called when the user long presses on a link.
 */
- (void)_longPressTimerDidFire:(NSTimer *)timer;

@end
