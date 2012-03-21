//
// Copyright 2012 Jeff Verkoeyen
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

// Controllers
#import "CatalogTableViewController.h"

@interface AppDelegate()
@property (nonatomic, readwrite, retain) UIViewController* rootController;
@end

@implementation AppDelegate

@synthesize rootController = _rootController;
@synthesize window = _window;

- (void)dealloc {
  [_rootController release];
  [_window release];
  [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  self.window.backgroundColor = [UIColor whiteColor];

  CatalogTableViewController* catalogController = [[[CatalogTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
  UINavigationController* navController = [[[UINavigationController alloc] initWithRootViewController:catalogController] autorelease];
  self.rootController = navController;

  [self.window addSubview:self.rootController.view];
  [self.window makeKeyAndVisible];
  return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  [NIOpenAuthenticator application:application
                           openURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation];
  return YES;
}

@end
