//
// Copyright 2011-2014 Jeff Verkoeyen
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
#import "UIView+NIStyleable.h"
#import "NIUserInterfaceString.h"
#import "NIFoundationMethods.h"
#import "NITextField.h"

#import "AppDelegate.h"

@implementation RootViewController
{
  BOOL animationToggle;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    NIStylesheetCache* stylesheetCache =
    [(AppDelegate *)[UIApplication sharedApplication].delegate stylesheetCache];
    NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"css/root/root.css"];
    NIStylesheet* common = [stylesheetCache stylesheetWithPath:@"css/common.css"];
    _dom = [NIDOM domWithStylesheet:stylesheet andParentStyles:common];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stylesheetDidChange)
                                                 name:NIStylesheetDidChangeNotification
                                               object:stylesheet];
    self.title = @"Nimbus CSS Demo";
  }
  return self;
}

- (void)loadView {
  [super loadView];

  [_dom registerView:self.view withCSSClass:@"background"];
  [self.view buildSubviews:@[
   _backgroundView = [[UIView alloc] init], @".noticeBox",
   @[
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge],
      [[UILabel alloc] init], @".titleLabel"
   ],
   [[UILabel alloc] init], @".rightMiddleLabel", NILocalizedStringWithDefault(@"RightLabel", @"Right Middle Label"),
   [[UILabel alloc] init], @".bottomLabel", NILocalizedStringWithDefault(@"BottomLabel", @"Bottom Left Label"),
   _button = [UIButton buttonWithType:UIButtonTypeCustom], NIInvocationWithInstanceTarget(self,@selector(buttonPress)), NILocalizedStringWithDefault(@"TestButton", @"Test Button"), @"#TestButton",
   [[NITextField alloc] init], @".textField"
   ]
   inDOM:_dom];
  
  for (int i = 1; i <= 7; i++) {
    UIView *box = [[UIView alloc] init];
    [self.view addSubview:box];
    [_dom registerView:box withCSSClass:@"colorBox" andId:[NSString stringWithFormat:@"box%d",i]];
  }
  [_activityIndicator startAnimating];
  
  NSLog(@"%@", [_dom descriptionForAllViews]);
}

-(void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [_dom refresh];
}

- (void)viewDidUnload {
  [_dom unregisterAllViews];
  
  _activityIndicator = nil;
  _backgroundView = nil;
  _testLabel = nil;
}

-(void)buttonPress
{
  animationToggle = !animationToggle;
  [_dom removeCssClass:animationToggle?@"noticeBox":@"noticeBoxEndpoint" fromView: _backgroundView];
  [UIView animateWithDuration:.5 animations:^{
    [_dom addCssClass:animationToggle?@"noticeBoxEndpoint":@"noticeBox" toView:_backgroundView];
  }];
}

- (void)stylesheetDidChange {
  [_dom refresh];
}

@end
