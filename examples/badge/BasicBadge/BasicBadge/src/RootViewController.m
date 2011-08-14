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
  self.view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
  
  NIBadgeView *badge1 = [[[NIBadgeView alloc] initWithFrame:CGRectMake(20, 10, 0, 0)] autorelease];
  badge1.text = @"2";
  [badge1 sizeToFit];
  [self.view addSubview:badge1];
  
  NIBadgeView *badge2 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(20, badge1.frame.size.height + 20, 
                                       50, 25)] 
                         autorelease];
  badge2.text = @"56";
  [self.view addSubview:badge2];
  
  NIBadgeView *badge3 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(20, badge2.frame.origin.y + badge2.frame.size.height + 20,
                                       0, 0)]  
                         autorelease];
  badge3.text = @"99+";
  badge3.tintColor = [UIColor blueColor];
  [badge3 sizeToFit];
  [self.view addSubview:badge3];
  
  NIBadgeView *badge4 = [[[NIBadgeView alloc] 
                          initWithFrame:
                            CGRectMake(20, badge3.frame.origin.y + badge3.frame.size.height + 20,                                                                  
                                       0, 0)] 
                         autorelease];
  badge4.text = @"nimbus";
  badge4.font = [UIFont boldSystemFontOfSize:22];
  [badge4 sizeToFit];
  [self.view addSubview:badge4];
  
  NIBadgeView *badge5 = [[[NIBadgeView alloc] 
                          initWithFrame:
                          CGRectMake(20, badge4.frame.origin.y + badge4.frame.size.height + 20,
                                     0, 0)] 
                         autorelease];
  badge5.text = @"100";
  badge5.tintColor = [UIColor lightGrayColor];
  badge5.textColor = [UIColor blackColor];
  [badge5 sizeToFit];
  [self.view addSubview:badge5];
}

@end
