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
  
  NIBadgeView *badge1 = [[[NIBadgeView alloc] initWithFrame:CGRectZero] autorelease];
  badge1.text = @"2";
  [badge1 sizeToFit];
  [self.view addSubview:badge1];
  
  NIBadgeView *badge2 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(0, badge1.frame.size.height, 
                                       50, 25)] 
                         autorelease];
  badge2.text = @"56";
  [self.view addSubview:badge2];
  
  NIBadgeView *badge3 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(0, badge2.frame.origin.y + badge2.frame.size.height,
                                       0, 0)] 
                         autorelease];
  badge3.text = @"99+";
  badge3.tintColor = [UIColor blueColor];
  [badge3 sizeToFit];
  [self.view addSubview:badge3];
  
  NIBadgeView *badge4 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(0, badge3.frame.origin.y + badge3.frame.size.height,                                                                  
                                       0, 0)] 
                         autorelease];
  badge4.text = @"nimbus";
  badge4.font = [UIFont boldSystemFontOfSize:22];
  [badge4 sizeToFit];
  [self.view addSubview:badge4];
}

@end
