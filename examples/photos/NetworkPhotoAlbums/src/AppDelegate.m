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

#import "FacebookPhotoAlbumViewController.h"
#import "CatalogTableViewController.h"
#import "NimbusOverviewer.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

@synthesize window = _window;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_window release];
  _window = nil;

  NI_RELEASE_SAFELY(_rootViewController);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Application lifecycle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)              application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];

  CatalogTableViewController* catalogVC =
  [[[CatalogTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];

  _rootViewController = [[UINavigationController alloc] initWithRootViewController:catalogVC];
  
  [NIOverviewer applicationDidFinishLaunching];

  [self.window addSubview:_rootViewController.view];
  
  [NIOverviewer addOverviewerToWindow:self.window];
  
  [self.window makeKeyAndVisible];
  
  return YES;
}


@end
