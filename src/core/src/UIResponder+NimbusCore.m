//
// Copyright 2011-2014 NimbusKit
//
// +currentFirstResponder originally written by Jakob Egger, adapted by Jeff Verkoeyen.
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

#import "UIResponder+NimbusCore.h"

#import "NIPreprocessorMacros.h"

// Adapted from http://stackoverflow.com/questions/5029267/is-there-any-way-of-asking-an-ios-view-which-of-its-children-has-first-responder/14135456#14135456

static __weak id sCurrentFirstResponder = nil;

NI_FIX_CATEGORY_BUG(UIResponderNimbusCore)
/**
 * For working with UIResponders.
 */
@implementation UIResponder (NimbusCore)

/**
 * Returns the current first responder by sending an action from the UIApplication.
 *
 * The implementation was adapted from http://stackoverflow.com/questions/5029267/is-there-any-way-of-asking-an-ios-view-which-of-its-children-has-first-responder/14135456#14135456
 */
+ (instancetype)nimbus_currentFirstResponder {
  sCurrentFirstResponder = nil;
  [[UIApplication sharedApplication] sendAction:@selector(nimbus_findFirstResponder:)
                                             to:nil from:nil forEvent:nil];
  return sCurrentFirstResponder;
}

- (void)nimbus_findFirstResponder:(id)sender {
  sCurrentFirstResponder = self;
}

@end
