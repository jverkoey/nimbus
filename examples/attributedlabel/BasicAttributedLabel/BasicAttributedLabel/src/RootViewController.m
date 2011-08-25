//
//  RootViewController.m
//  BasicAttributedLabel
//
//  Created by Roger Chapman on 23/08/2011.
//  Copyright 2011 Storm ID Ltd. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController
@synthesize label1;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  return [super initWithNibName:@"RootView" bundle:nibBundleOrNil];
}

- (void)dealloc {
  NI_RELEASE_SAFELY(label1);
  [super dealloc];
}

-(void)viewDidLoad {
  
  label1.text = @"This Label should be green";
}
@end
