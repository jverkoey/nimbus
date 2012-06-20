//
// Copyright 2012 Jeff Verkoeyen
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

#import "NIRadioGroupController.h"

#import "NICellFactory.h"
#import "NIRadioGroup.h"
#import "NITableViewModel.h"

#import "NIDebuggingTools.h"
#import "NIDeviceOrientation.h"

@interface NIRadioGroupController ()
@property (nonatomic, readonly, retain) NIRadioGroup* radioGroup;
@property (nonatomic, readonly, retain) id<NICell> tappedCell;
@property (nonatomic, readonly, retain) NITableViewModel* model;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIRadioGroupController

@synthesize radioGroup = _radioGroup;
@synthesize tappedCell = _tappedCell;
@synthesize model = _model;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_radioGroup removeForwarding:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRadioGroup:(NIRadioGroup *)radioGroup tappedCell:(id<NICell>)tappedCell {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    // A valid radio group must be provided.
    NIDASSERT(nil != radioGroup);
    _radioGroup = radioGroup;
    _tappedCell = tappedCell;

    _model = [[NITableViewModel alloc] initWithListArray:_radioGroup.allObjects
                                                delegate:(id)[NICellFactory class]];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  // Use the initWithRadioGroup initializer.
  NIDASSERT(NO);
  return [self initWithRadioGroup:nil tappedCell:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.radioGroup forwardingTo:self.tableView.delegate];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [self.radioGroup removeForwarding:self];

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tappedCell shouldUpdateCellWithObject:self.radioGroup];
}

@end
