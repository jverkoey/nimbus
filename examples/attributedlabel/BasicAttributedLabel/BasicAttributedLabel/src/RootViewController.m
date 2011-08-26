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
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  return [super initWithNibName:@"RootView" bundle:nibBundleOrNil];
}

- (void)dealloc {
  NI_RELEASE_SAFELY(label1);
  NI_RELEASE_SAFELY(label2);
  NI_RELEASE_SAFELY(label3);
  NI_RELEASE_SAFELY(label4);
  [super dealloc];
}

-(void)viewDidLoad {
  
  self.title = @"Attributed Label Demo";
  
  label1.underlineStyle = kCTUnderlineStyleDouble;
  label1.underlineStyleModifier = kCTUnderlinePatternDot;

  label2.textAlignment = UITextAlignmentJustify;
  label2.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:16];
  
  label3.autoDetectLinks = YES;
  //label3.linkColor = [UIColor purpleColor];
  //label3.linkHighlightColor = [UIColor orangeColor];
  
  label4.textAlignment = UITextAlignmentJustify;
  [label4 setTextColor:[UIColor orangeColor] 
                 range:[label4.text rangeOfString:@"Nimbus"]];
  [label4 setTextColor:[UIColor redColor] 
                 range:[label4.text rangeOfString:@"accelerates"]];
  [label4 setFont:[UIFont boldSystemFontOfSize:22] range:[label4.text rangeOfString:@"iOS"]];
  [label4 setUnderlineStyle:kCTUnderlineStyleSingle modifier:kCTUnderlinePatternDash range:[label4.text rangeOfString:@"documentation"]];
  [label4 setFont:[UIFont fontWithName:@"MarkerFelt-Wide" size:17] range:[label4.text rangeOfString:@"Nimbus" options: NSBackwardsSearch]];
  
}

-(void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectLink:(NSURL *)url {
  
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Link Selected" message:url.relativeString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
  
  [alert show];
  NI_RELEASE_SAFELY(alert);
  
}
@end
