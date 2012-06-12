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

// View Controllers
#import "RootViewController.h"


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

  // Try experimenting with the maximum number of concurrent operations here.
  // By making it one, we force the network operations to happen serially. This can be
  // useful for avoiding thrashing of the disk and network.
  // Watch how the app works with a max of 1 versus not defining a max at all and allowing the
  // device to spin off as many threads as it wants to.
  //
  // Spoiler alert! When the max is 1, the first image loads and then all of the others load
  //                relatively instantly from the disk.
  //                When the max is unset, all of the images take a bit longer to load.

  [[Nimbus networkOperationQueue] setMaxConcurrentOperationCount:1];


  // Try experimenting with this value to see how the total number of pixels is affected.
  //[[Nimbus imageMemoryCache] setMaxNumberOfPixels:94*94];

  _rootController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
  [self.window addSubview:_rootController.view];

  [self.window makeKeyAndVisible];

  return YES;
}


@end
