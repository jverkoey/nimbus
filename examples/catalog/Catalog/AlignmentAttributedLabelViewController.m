//
// Copyright 2011-2014 NimbusKit
// Contributed by Jeroen Trappers
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

#import "AlignmentAttributedLabelViewController.h"
#import "NIAttributedLabel.h"

@interface AlignmentAttributedLabelViewController ()

@property (weak, nonatomic) IBOutlet NIAttributedLabel *topLeft;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *top;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *topRight;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *left;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *center;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *right;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottom;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottomRight;
@property (weak, nonatomic) IBOutlet NIAttributedLabel *bottomLeft;

@end

@implementation AlignmentAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Alignment";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.

  // iOS 7-only.
  if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
    self.edgesForExtendedLayout = UIRectEdgeNone;
  }

  self.topLeft.verticalTextAlignment = NIVerticalTextAlignmentTop;
  self.top.verticalTextAlignment = NIVerticalTextAlignmentTop;
  self.topRight.verticalTextAlignment = NIVerticalTextAlignmentTop;

  self.left.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
  self.center.verticalTextAlignment = NIVerticalTextAlignmentMiddle;
  self.right.verticalTextAlignment = NIVerticalTextAlignmentMiddle;

  self.bottomLeft.verticalTextAlignment = NIVerticalTextAlignmentBottom;
  self.bottom.verticalTextAlignment = NIVerticalTextAlignmentBottom;
  self.bottomRight.verticalTextAlignment = NIVerticalTextAlignmentBottom;
}

@end
