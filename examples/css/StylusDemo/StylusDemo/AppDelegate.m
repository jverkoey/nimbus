//
//  AppDelegate.m
//  StylusDemo
//
//  Created by Daniel Barden on 11/2/11.
//  Copyright (c) 2011 None. All rights reserved.
//

#import "AppDelegate.h"
#import "NimbusCore.h"

#import "ViewController.h"
#import "NimbusCSS.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize chameleonObserver = _chameleonObserver;
@synthesize stylesheetCache = _stylesheetCache;

- (void)dealloc
{
    NI_RELEASE_SAFELY(_window);
    NI_RELEASE_SAFELY(_viewController);
    NI_RELEASE_SAFELY(_chameleonObserver);
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
    
    NSString* pathPrefix = NIPathForBundleResource(nil, @"css");
    NSString* host = @"http://localhost:8888/";
    
    _stylesheetCache = [[NIStylesheetCache alloc] initWithPathPrefix:pathPrefix];
    
    _chameleonObserver = [[NIChameleonObserver alloc] initWithStylesheetCache:_stylesheetCache
                                                                         host:host];
    [_chameleonObserver watchSkinChanges];
    
    ViewController* mainController =
    [[[ViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    _rootViewController = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    [self.window addSubview:_rootViewController.view];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
