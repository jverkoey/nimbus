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

#import "ImagesAttributedLabelViewController.h"

#import "NimbusAttributedLabel.h"

//
// What's going on in this file:
//
// This controller shows how to add inline images to NIAttributedLabel.
//
// You will find the following Nimbus features used:
//
// [attributedlabel]
// NIAttributedLabel
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// CoreText.framework
// QuartzCore.framework
//

@interface ImagesAttributedLabelViewController ()
@end

@implementation ImagesAttributedLabelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Images";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NIAttributedLabel* label = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];

  // When we assign the text we do not include any markup for the images.
  label.text = @"This is Nimbus:He's a red panda.\nThis is a star:";

  label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  label.lineBreakMode = UILineBreakModeWordWrap;
  label.numberOfLines = 0;
  label.font = [UIFont systemFontOfSize:20];
  label.textColor = [UIColor blackColor];
  label.frame = CGRectInset(self.view.bounds, 20, 20);

  // We want to insert an image directly after the string "Nimbus:" in the above string, so find its
  // range and then use NSMaxRange to get the last index.
  NSRange range = [label.text rangeOfString:@"Nimbus:"];

  // When we insert an image we have the option to provide margins and vertical text alignment.
  //
  // Experiment:
  // Try changing the values of the margins and seeing the effects it has.
  //
  [label insertImage:[UIImage imageNamed:@"Icon"]
             atIndex:NSMaxRange(range)
             margins:UIEdgeInsetsMake(5, 5, 5, 5)];

  // We're going to add an image to the end of the string, so we pass the length of the string.
  // Why not length - 1? Because the image gets inserted at the given index, so if we passed
  // length - 1 the image would be immediately before the last character.
  //
  // Experiment:
  // Try changing the index to other arbitrary values and seeing how it affects the way the text is
  // drawn.
  //
  [label insertImage:[UIImage imageNamed:@"star"]
             atIndex:label.text.length
             margins:UIEdgeInsetsMake(5, 5, 5, 5)];

  [self.view addSubview:label];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
