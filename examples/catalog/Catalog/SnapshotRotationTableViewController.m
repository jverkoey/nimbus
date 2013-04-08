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

#import "SnapshotRotationTableViewController.h"

#import "NimbusModels.h"
#import "NimbusNetworkImage.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This controller demos how to use the snapshot rotation feature of Nimbus' core. This feature only
// works on iOS 6 and higher. This controller is a UIViewController but it adds a UITableView in
// order to demo snapshot rotation for table views.
//
// Snapshot rotation is the act of taking two snapshots of a view controller's initial and final
// states, respectively, and then cross-fading between them during the rotation. This is
// specifically useful for block rendered cells because otherwise the cells get stretched awkwardly
// during the rotation.
//
// Note: to see snapshot rotations you should enable Slow Animations via the "Debug" menu of the
// simulator.
//
// You will find the following Nimbus features used:
//
// [core]
// NISnapshotRotation
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

// NISnapshotRotation requires that we implement the NISnapshotRotationDelegate protocol for its
// delegate.
@interface SnapshotRotationTableViewController () <UITableViewDelegate, NISnapshotRotationDelegate>

// UITableViewController's self.view == self.tableView, but for snapshot rotation to work we must
// ensure that the container view is not equivalent to the rotating view. To solve this we simply
// don't subclass UITableViewController and instead implement the basic UITableViewController
// functionality ourselves.
@property (nonatomic, readwrite, retain) UITableView* tableView;

// In order to implement snapshot rotations we must create a snapshot rotation object and keep it
// around at least for the duration of the rotation. In this example we create the snapshot rotation
// object during initialization and just keep it around forever. If you wanted to save memory you
// could create the rotation object when a rotation is about to begin and then release it when the
// rotation completes.
@property (nonatomic, readwrite, retain) NISnapshotRotation* snapshotRotation;

@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@end

@implementation SnapshotRotationTableViewController

@synthesize tableView = _tableView;
@synthesize snapshotRotation = _snapshotRotation;
@synthesize model = _model;
@synthesize actions = _actions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.title = @"Snapshot Rotation";

    // We must provide the snapshot rotation object a delegate so that it knows which view to
    // snapshot rotate.
    // Note here that we're creating a NITableViewSnapshotRotation version of NISnapshotRotation.
    // This subclass of NISnapshotRotation handles UITableViews specifically by creating a resizing
    // snapshot that cuts off along a vertical line between the contentView and the accessoryView.
    // The standard NISnapshotRotation object, on the other hand, will simply snapshot the entire
    // rotating view without a vertical divider.
    _snapshotRotation = [[NITableViewSnapshotRotation alloc] initWithDelegate:self];

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
      CGFloat titleWidth = rect.size.width - 20;

      // We're drawing variable height cells in this example to show how the table view smoothly
      // animates between the two very different states of the table view.
      CGSize size = [text sizeWithFont:titleFont constrainedToSize:CGSizeMake(titleWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
      if (nil != cell) {
        [text drawInRect:CGRectMake(10, 5, size.width, size.height) withFont:titleFont lineBreakMode:NSLineBreakByWordWrapping];
      }

      return size.height + 10;
    };

    NSMutableArray* tableContents =
    [NSMutableArray arrayWithObjects:
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a short label."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a short label."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a short label."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a short label."],
     [NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:@"This is a cell with a large amount of text that is going to wrap over multiple lines."],
     nil];

    _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                delegate:(id)[NICellFactory class]];

    // We give every cell an action that pushes to the same controller purely so that we can show
    // how the accessory indicators react to snapshot rotations.
    //
    // Experiment: try changing the action type to attachDetailAction to see what snapshot rotation
    // looks like with larger accessory types.
    _actions = [[NITableViewActions alloc] initWithTarget:self];
    [_actions attachToClass:[NIDrawRectBlockCellObject class]
            navigationBlock:NIPushControllerAction([self class])];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // This is standard UITableView instantiation. It's effectively what UITableViewController does
  // in loadView, except we're adding the table view to self.view rather than assigning it to
  // self.view.
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  [self.view addSubview:self.tableView];

  self.tableView.delegate = [self.actions forwardingTo:self];
  self.tableView.dataSource = _model;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  // When the controller first appears we want to ensure that the table view shows its data.
  // The self.view here ensures that we load the table view first.
  if (self.view && self.tableView.numberOfSections == 0) {
    [self.tableView reloadData];
  }

  // When this controller appears we want to deselect whatever cell was previously selected. This
  // logic also comes for free with UITableViewController, so we make sure to include it here as
  // well.
  NSIndexPath* selectedRow = self.tableView.indexPathForSelectedRow;
  if (nil != selectedRow) {
    [self.tableView deselectRowAtIndexPath:selectedRow animated:animated];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

// The following three methods MUST all be forwarded to the snapshot rotation object in order for
// it to function correctly.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self.snapshotRotation willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
  [self.snapshotRotation willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [self.snapshotRotation didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  // We ask each block to calculate its size in order to create variable-height block cells.
  NIDrawRectBlockCellObject *object = [self.model objectAtIndexPath:indexPath];
  return object.block(self.tableView.bounds, object.object, nil);
}

// The following implementation of NISnapshotRotationDelegate is why we need to ensure that
// self.view != self.tableView. Essentially what's going on in the background is NISnapshotRotation
// takes a snapshot of the rotating view in its initial and final rotation state, removes the
// rotating view from the hierarchy and crossfades between the two images. Once the animation
// completes we add the rotating view back to the container.
#pragma mark - NISnapshotRotationDelegate

- (UIView *)containerViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation {
  return self.view;
}

- (UIView *)rotatingViewForSnapshotRotation:(NISnapshotRotation *)snapshotRotation {
  return self.tableView;
}

@end
