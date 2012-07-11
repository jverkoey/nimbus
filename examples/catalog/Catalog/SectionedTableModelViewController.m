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

#import "SectionedTableModelViewController.h"

#import "NimbusModels.h"
#import "NimbusCore.h"

//
// What's going on in this file:
//
// This is a demo of creating a NITableViewModel with a sectioned group of objects.
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

@interface SectionedTableModelViewController ()
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end

@implementation SectionedTableModelViewController

@synthesize model = _model;

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"Sectioned Model";

    NSArray* tableContents =
    [NSArray arrayWithObjects:
     // If the table contents starts with an object instead of a string then the first section
     // will not have a section header.
     //
     // Experiment:
     // Try uncommenting the following line to add a section header to the first section.
     //
     // @"Section Header",
     [NITitleCellObject objectWithTitle:@"First section"],

     // Each time an NSString is encountered in the table contents a new section will begin. All
     // proceeding objects will be part of this section until another NSString is encountered.
     @"Section with rows",
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITitleCellObject objectWithTitle:@"Row"],
     [NITitleCellObject objectWithTitle:@"Row"],

     // It is also possible to create sections without any rows by following one NSString with
     // another NSString.
     @"Section without any rows",

     // This NSString will close off the previous section.
     @"Another section",
     [NITitleCellObject objectWithTitle:@"Row"],

     // To start a new group without providing a section header you use an empty string.
     @"",
     [NITitleCellObject objectWithTitle:@"This section has no header"],
     [NITitleCellObject objectWithTitle:@"Row"],
     nil];

    // We want to treat the table contents as a sectioned array, so we use
    // initWithSectionedArray:delegate: here.
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:(id)[NICellFactory class]];
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
