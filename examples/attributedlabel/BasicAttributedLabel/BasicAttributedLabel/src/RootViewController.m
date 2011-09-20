//
// Copyright 2011 Roger Chapman
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

#import "LabelEntry.h"
#import "MashupViewController.h"
#import "UnderlineViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc {
  NI_RELEASE_SAFELY(_model);
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidLoad {
  
  self.title = @"NIAttributedLabel Demo";
  self.navigationItem.backBarButtonItem = 
  [[[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                    style:UIBarButtonItemStylePlain 
                                   target:nil 
                                   action:nil] autorelease];
  
  NSArray* tableContents =
  [NSArray arrayWithObjects:
   @"",
   [LabelEntry entryWithTitle:@"Mashup" controllerClass:[MashupViewController class]], 
   @"",
   [LabelEntry entryWithTitle:@"Underline" controllerClass:[UnderlineViewController class]], nil];
  
  _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                   delegate:(id)[NICellFactory class]];
  self.tableView.dataSource = _model;
  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {  
  LabelEntry* entry = [_model objectAtIndexPath:indexPath];
  Class cls = [entry controllerClass];
  UIViewController* controller = [[[cls alloc] initWithNibName:nil bundle:nil] autorelease];
  [self.navigationController pushViewController:controller animated:YES];
}


@end
