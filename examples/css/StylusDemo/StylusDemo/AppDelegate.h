//
//  AppDelegate.h
//  StylusDemo
//
//  Created by Daniel Barden on 11/2/11.
//  Copyright (c) 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "NIChameleonObserver.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIViewController *_rootViewController;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) ViewController *viewController;

@property (nonatomic, retain) NIChameleonObserver *chameleonObserver;

@property (nonatomic, retain) NIStylesheetCache *stylesheetCache;
@end
