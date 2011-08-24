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

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
  return [super initWithNibName:@"RootView" bundle:nibBundleOrNil];
}

- (void)dealloc {
  NI_RELEASE_SAFELY(label1);
  NI_RELEASE_SAFELY(label2);
  [super dealloc];
}

-(void)viewDidLoad {
  
  self.title = @"NIAttributedLabel";

  label2.textAlignment = UITextAlignmentJustify;
}

@end
