//
// Copyright 2011 Roger Chapman
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
