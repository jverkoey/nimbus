//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "InterfaceBuilderBadgeViewController.h"
#import "NimbusBadge.h"

@interface InterfaceBuilderBadgeViewController ()
@property (nonatomic, readwrite, retain) IBOutlet NIBadgeView* badgeView;
@property (nonatomic, readwrite, retain) IBOutlet NIBadgeView* badgeView2;
@end

@implementation InterfaceBuilderBadgeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:@"BadgeMashup" bundle:nibBundleOrNil])) {
    self.title = @"Interface Builder";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.badgeView sizeToFit];
  [self.badgeView2 sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
