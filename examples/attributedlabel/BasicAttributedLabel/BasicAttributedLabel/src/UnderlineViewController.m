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

#import "UnderlineViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UnderlineViewController
@synthesize single;
@synthesize thick;
@synthesize ddouble;
@synthesize dot;
@synthesize dash;
@synthesize dashdot;
@synthesize dashdotdot;
@synthesize doubledashdotdot;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [super initWithNibName:@"UnderlineView" bundle:nibBundleOrNil];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidLoad {
  
  self.title = @"Underlined Text";
  
  single.underlineStyle = kCTUnderlineStyleSingle;
  thick.underlineStyle = kCTUnderlineStyleThick;
  ddouble.underlineStyle = kCTUnderlineStyleDouble;
  
  dot.underlineStyle = kCTUnderlineStyleSingle;
  dot.underlineStyleModifier = kCTUnderlinePatternDot;
  dash.underlineStyle = kCTUnderlineStyleSingle;
  dash.underlineStyleModifier = kCTUnderlinePatternDash;
  dashdot.underlineStyle = kCTUnderlineStyleSingle;
  dashdot.underlineStyleModifier = kCTUnderlinePatternDashDot;
  dashdotdot.underlineStyle = kCTUnderlineStyleSingle;
  dashdotdot.underlineStyleModifier = kCTUnderlinePatternDashDotDot;
  
  doubledashdotdot.underlineStyle = kCTUnderlineStyleDouble;
  doubledashdotdot.underlineStyleModifier = kCTUnderlinePatternDashDotDot;
  
}
@end
