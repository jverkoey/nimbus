//
// Copyright 2011 Jeff Verkoeyen
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

#import "AppDelegate.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_dom);
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    NIChameleonObserver* chameleonObserver =
    [(AppDelegate *)[UIApplication sharedApplication].delegate chameleonObserver];
    NIStylesheet* stylesheet = [chameleonObserver stylesheetForFilename:@"root/root.css"];
    _dom = [[NIDOM alloc] initWithStylesheet:stylesheet];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(chameleonSkinDidChange)
                                                 name:NIChameleonSkinDidChangeNotification
                                               object:stylesheet];
    self.title = @"Nimbus CSS Demo";
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _testLabel = [[UILabel alloc] init];
  _testLabel.text = @"Chameleon + Nimbus";
  [_testLabel sizeToFit];
  _testLabel.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, 100);
  [self.view addSubview:_testLabel];

  [_dom registerView:self.view];
  [_dom registerView:self.navigationController.navigationBar];
  [_dom registerView:_testLabel];
  [_dom registerView:_testLabel withCSSClass:@"myClass"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [_dom unregisterView:self.view];
  [_dom unregisterView:self.navigationController.navigationBar];
  [_dom unregisterView:_testLabel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)chameleonSkinDidChange {
  [_dom refresh];
}

@end
