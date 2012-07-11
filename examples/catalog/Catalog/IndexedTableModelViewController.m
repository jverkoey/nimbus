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

#import "IndexedTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of creating a NITableViewModel with an indexed group of objects.
//
// You will find the following Nimbus features used:
//
// [models]
// NITableViewModel
// NICellFactory
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
//

@interface IndexedTableModelViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end

@implementation IndexedTableModelViewController

@synthesize model = _model;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Indexed Model";
    
    // When using sectioned indexes we create our model with sectioned objects. Each section header
    // is generally the alphabetic letter that the contents of that section are grouped by. This
    // may be alphabetic by last name or first name, or by some other arbitrary sorting algorithm.
    // Whatever the algorithm may be, you should ensure that the groups are sorted in a way that
    // matches the index sorting algorithm.
    //
    // In this example we use a static list of names that are sorted by last name and
    // NITableViewModelSectionIndexAlphabetical as the index type.
    NSArray* tableContents =
    [NSArray arrayWithObjects:
     @"A",
     [NITitleCellObject objectWithTitle:@"Jon Abrams"],
     [NITitleCellObject objectWithTitle:@"Crystal Arbor"],
     [NITitleCellObject objectWithTitle:@"Mike Axiom"],
     
     @"B",
     [NITitleCellObject objectWithTitle:@"Joey Bannister"],
     [NITitleCellObject objectWithTitle:@"Ray Bowl"],
     [NITitleCellObject objectWithTitle:@"Jane Byte"],
     
     @"C",
     [NITitleCellObject objectWithTitle:@"JJ Cranilly"],
     
     @"K",
     [NITitleCellObject objectWithTitle:@"Jake Klark"],
     [NITitleCellObject objectWithTitle:@"Viktor Krum"],
     [NITitleCellObject objectWithTitle:@"Abraham Kyle"],
     
     @"L",
     [NITitleCellObject objectWithTitle:@"Mr Larry"],
     [NITitleCellObject objectWithTitle:@"Mo Lundlum"],
     
     @"N",
     [NITitleCellObject objectWithTitle:@"Carl Nolly"],
     [NITitleCellObject objectWithTitle:@"Jeremy Nym"],
     
     @"O",
     [NITitleCellObject objectWithTitle:@"Number 1 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 2 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 3 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 4 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 5 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 6 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 7 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 8 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 9 Otter"],
     [NITitleCellObject objectWithTitle:@"Number 10 Otter"],
     
     @"X",
     [NITitleCellObject objectWithTitle:@"Charles Xavier"],
     nil];

    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];

    // NITableViewModelSectionIndexAlphabetical generates an index that shows the entire alphabetic
    // range from A-Z. When the user taps any of these letters the model will jump to the closest
    // section for the tapped letter.
    //
    // Experiment:
    // Try changing the index type to NITableViewModelSectionIndexDynamic. You should notice that
    // the index is now generated from the section headers. In nearly every case you will want to
    // use the alphabetical index.
    [_model setSectionIndexType:NITableViewModelSectionIndexAlphabetical
                    showsSearch:NO
                   showsSummary:NO];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.dataSource = _model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

@end
