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
@synthesize stylesheetCache = _stylesheetCache;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

  NSString* pathPrefix = NIPathForBundleResource(nil, @"css");
  NSString* host = @"http://localhost:8888/";
  
  _stylesheetCache = [[NIStylesheetCache alloc] initWithPathPrefix:pathPrefix];
  
  _chameleonObserver = [[NIChameleonObserver alloc] initWithStylesheetCache:_stylesheetCache
                                                                       host:host];
  [_chameleonObserver watchSkinChanges];

  RootViewController* mainController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
  
  _rootController = [[UINavigationController alloc] initWithRootViewController:mainController];
  self.window.rootViewController = _rootController;

  [self.window makeKeyAndVisible];
  
  return YES;
}


@end
