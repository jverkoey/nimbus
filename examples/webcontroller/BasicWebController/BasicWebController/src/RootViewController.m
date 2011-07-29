//
//  RootViewController.m
//  BasicWebController
//
//  Created by Roger Chapman on 29/07/2011.
//  Copyright 2011 Storm ID Ltd. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

-(void)viewDidLoad {
  [self openURL:[NSURL URLWithString:@"http://www.google.com"]];
}

@end
