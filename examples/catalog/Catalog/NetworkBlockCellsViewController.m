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

#import "NetworkBlockCellsViewController.h"

#import "NimbusModels.h"
#import "NimbusNetworkImage.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of rendering table view cells with network images using blocks. This demo creates
// a subclass of the NIDrawRectBlockCell and uses NINetworkImageView to download the image.
//
// You will find the following Nimbus features used:
//
// [networkimage]
// NINetworkImageView
//
// [models]
// NITableViewModel
// NICellFactory
// NIDrawRectBlockCell
// NIDrawRectBlockCellObject
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

// This subclass of NIDrawRectBlockCell simply handles the fetching of an image from the network.
// We use a network image view to do this, but we never add the network image view to the view
// hierarchy because we are going to render the image in the cell block.
@interface NetworkDrawRectBlockCell : NIDrawRectBlockCell <NINetworkImageViewDelegate>
@property (nonatomic, readwrite, retain) NINetworkImageView* networkImageView;
@end

@implementation NetworkDrawRectBlockCell

@synthesize networkImageView = _networkImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    _networkImageView = [[NINetworkImageView alloc] init];

    // We implement the delegate so that we know when the image has finished downloading.
    _networkImageView.delegate = self;
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];

  // This resets the networkImageView's .image to the initial image (in this case nil). Oftentimes
  // the initial image will be a local "empty" avatar image that you've provided with your
  // application.
  [self.networkImageView prepareForReuse];
}

- (BOOL)shouldUpdateCellWithObject:(NIDrawRectBlockCellObject *)object {
  [super shouldUpdateCellWithObject:object];

  // Fetch the avatar from the network.
  NSString* gravatarUrl = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=140", object.object];
  // NINetworkImageView is smart enough to know that if we want to display an image at size 70x70
  // on a retina display then it will crop the image to 140x140 and set the image scale to 2.
  CGFloat imageSize = 70;
  
  // We explicitly set the display size of the network image so that when it is downloaded it gets
  // cropped and resized accordingly. In this case we're fetching a 140x140 image from gravatar
  // so there will be little work to do on retina displays, but older devices will need to resize
  // the image to 70x70.
  [self.networkImageView setPathToNetworkImage:gravatarUrl forDisplaySize:CGSizeMake(imageSize, imageSize)];

  return YES;
}

#pragma mark - NINetworkImageViewDelegate

- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image {
  // Once the image has been downloaded we need to redraw the block.
  [self.blockView setNeedsDisplay];
}

@end

@interface NetworkBlockCellsViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;

// We're going to override the default mapping of NIDrawRectBlockCellObject -> NIDrawRectBlockCell
// so that we can display our subclassed version of NIDrawRectBlockCell with network images.
// To do this we must create an instance of NICellFactory which we will be able to customize by
// adding explicit mappings which will be used in preference of the implicit ones denoted by the
// cell objects.
@property (nonatomic, readwrite, retain) NICellFactory* cellFactory;
@end

@implementation NetworkBlockCellsViewController

@synthesize model = _model;
@synthesize cellFactory = _cellFactory;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStylePlain])) {
    self.title = @"Network Block Cells";

    NICellDrawRectBlock drawTextBlock = ^CGFloat(CGRect rect, id object, UITableViewCell *cell) {
      if (cell.isHighlighted || cell.isSelected) {
        [[UIColor clearColor] set];
      } else {
        [[UIColor whiteColor] set];
      }
      UIRectFill(rect);

      NSString* text = object;
      [[UIColor blackColor] set];
      UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
      [text drawAtPoint:CGPointMake(10, 5) withFont:titleFont];

      // We know that we're using a network cell here, so we can safely cast without checking.
      NetworkDrawRectBlockCell* networkCell = (NetworkDrawRectBlockCell *)cell;

      // Grab the image and then draw it on the cell. If there is no image yet then the draw method
      // will do nothing.
      UIImage* image = networkCell.networkImageView.image;
      [image drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - image.size.width - 10, 5)];

      return 0;
    };

    NSMutableArray* tableContents =
    [NSMutableArray arrayWithObjects:
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"f3c8603c353afa79b9f1c77f35efd566"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"c28f6b282ad61bff6aa9aba06c62ad66"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"22f25c7b3f0f15a6854fae62bbd3482f"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"ec5d7ba9c004f79817c76146247e787e"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"832ece085bfe2c7c5b0ed6be62d7e675"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"2ea33a461b2c20894f62958bcd9a4fb2"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"430e340a391ff510825c61fb0f6ffeca"],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"875412d23685f3a6f49fff1b927512cb"],
     nil];

    // Set up our explicit mapping of NIDrawRectBlockCellObject -> NetworkDrawRectBlockCell.
    _cellFactory = [[NICellFactory alloc] init];
    [_cellFactory mapObjectClass:[NIDrawRectBlockCellObject class]
                     toCellClass:[NetworkDrawRectBlockCell class]];

    // Notice that we're passing the _cellFactory instance rather than (id)[NICellFactory class]
    // now.
    _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                delegate:_cellFactory];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.rowHeight = 80;
  self.tableView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
