//
//  RootViewController.m
//  BasicBadge
//
//  Created by Roger Chapman on 03/08/2011.
//  Copyright 2011 Storm ID Ltd. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

-(void)viewDidLoad {
  
  self.title = @"Nimbus Badge";
  self.view.backgroundColor = [UIColor whiteColor];
  
  NIBadgeView *badge1 = [[[NIBadgeView alloc] initWithText:@"2"] autorelease];
  [self.view addSubview:badge1];
  
  NIBadgeView *badge2 = [[[NIBadgeView alloc] initWithText:@"56"] autorelease];
  badge2.frame = 
    CGRectMake(0, badge1.frame.size.height, 
               badge2.frame.size.width, badge2.frame.size.height);
  [self.view addSubview:badge2];
  
  NIBadgeView *badge3 = [[[NIBadgeView alloc] initWithText:@"99+" 
                                                 tintColor:[UIColor blueColor]] autorelease];
  badge3.frame = 
    CGRectMake(0, badge2.frame.origin.y + badge2.frame.size.height, 
               badge3.frame.size.width, badge3.frame.size.height);
  [self.view addSubview:badge3];
  
  NIBadgeView *badge4 = [[[NIBadgeView alloc] initWithText:@"nimbus" 
                                                      font:[UIFont boldSystemFontOfSize:22]
                                                 tintColor:[UIColor blueColor]] autorelease];
  badge4.frame = 
    CGRectMake(0, badge3.frame.origin.y + badge3.frame.size.height, 
               badge4.frame.size.width, badge4.frame.size.height);
  [self.view addSubview:badge4];
}

@end
