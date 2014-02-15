//
// Copyright 2011-2014 NimbusKit
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

#import "BlockCellsViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of rendering table view cells with blocks.
//
// You will find the following Nimbus features used:
//
// [models]
// NITableViewModel
// NIDrawRectBlockCellObject
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface BlockCellsViewController ()
@property (nonatomic, retain) NITableViewModel* model;
@end

@implementation BlockCellsViewController


- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStylePlain])) {
    self.title = @"Block Cells";

    // We load the image outside of the block so that we spend as little time in the block as
    // possible.
    UIImage* image = [UIImage imageNamed:@"Icon"];

    // We create a single block that can render a table view cell given an object.
    NICellDrawRectBlock drawTextBlock = ^CGFloat(CGRect rect, id object, UITableViewCell *cell) {
      // If the cell is tapped or selected we want to draw the text on top of the selection
      // background. This requires that the content's background be clear.
      if (cell.isHighlighted || cell.isSelected) {
        [[UIColor clearColor] set];
      } else {
        [[UIColor whiteColor] set];
      }

      // Fill in the content rect.
      UIRectFill(rect);

      // Draw the object that was given to this block. In this case it will always be an NSString.
      NSString* text = object;
      [[UIColor blackColor] set];
      UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
      [text drawAtPoint:CGPointMake(10, 5) withFont:titleFont];

      // Draw a static subtitle below the title.
      [[UIColor grayColor] set];
      [@"Subtitle" drawAtPoint:CGPointMake(10, 5 + titleFont.lineHeight) withFont:[UIFont systemFontOfSize:12]];

      // Draw the Nimbus application icon on the right edge of the cell.
      [image drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - image.size.width - 10, 5)];

      // We can optionally return the height of the cell if we want to support variable-height
      // custom-drawn cells.
      return 0;
    };

    // Create 1000 cells that are individually named so that we can show how quickly we can scroll
    // through the cells.
    NSMutableArray* tableContents = [NSMutableArray array];
    for (NSInteger ix = 0; ix < 1000; ++ix) {
      [tableContents addObject:
       [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:
        [NSString stringWithFormat:@"This is cell #%d", ix]]];
    }

    _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Experiment:
  // Try playing around with the row height.
  self.tableView.rowHeight = 70;

  self.tableView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
