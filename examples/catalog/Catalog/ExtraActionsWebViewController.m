//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "ExtraActionsWebViewController.h"

@implementation ExtraActionsWebViewController

- (BOOL)shouldPresentActionSheet:(UIActionSheet *)actionSheet {
  // We call super here to populate the action sheet with the default actions.
  [super shouldPresentActionSheet:actionSheet];

  // Add our custom action.
  [actionSheet addButtonWithTitle:@"Latest Docs"];

  // Returning YES means that we want to allow this action sheet to appear.
  // If we return NO then the action sheet would not appear and we'd be expected to have shown our
  // own action sheet or dialog in some way.
  return YES;
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
  if (buttonIndex == 2) {
    [self openURL:[NSURL URLWithString:@"http://latest.docs.nimbuskit.info/"]];
  }
}

@end
