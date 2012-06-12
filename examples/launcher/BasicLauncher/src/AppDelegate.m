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

#import "AppDelegate.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

@synthesize window = _window;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

  // Create a stock launcher view controller and populate it with stock data.
  // In a real-world setting, you would probably create your own view controller that
  // inherits from NILauncherViewController or implements the necessary protocols. Within
  // this controller you'd create the necessary information to create the launcher buttons.

  NILauncherViewController* launcherController =
    [[NILauncherViewController alloc] initWithNibName:nil bundle:nil];
  launcherController.title = @"Basic Launcher Demo";

  NSString* imagePath = NIPathForBundleResource([NSBundle mainBundle], @"nimbus64x64.png");

  NSArray* pages = [NSArray arrayWithObjects:
                    [NSArray arrayWithObjects:
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 1"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 2"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 3"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 4"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 5"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 6"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 7"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 8"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 9"
                                                       imagePath: imagePath],
                     nil],
                    [NSArray arrayWithObjects:
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 10"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 11"
                                                       imagePath: imagePath],
                     nil],
                    [NSArray arrayWithObjects:
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 12"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 13"
                                                       imagePath: imagePath],
                     nil],
                    [NSArray arrayWithObjects:
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 14"
                                                       imagePath: imagePath],
                     [NILauncherItemDetails itemDetailsWithTitle: @"Item 15"
                                                       imagePath: imagePath],
                     nil],
                    nil];
  [launcherController setPages:pages];

  _rootController = [[UINavigationController alloc] initWithRootViewController:launcherController];
  _rootController.view.frame = self.window.bounds;

  [self.window addSubview:_rootController.view];

  [self.window makeKeyAndVisible];

  return YES;
}


@end
