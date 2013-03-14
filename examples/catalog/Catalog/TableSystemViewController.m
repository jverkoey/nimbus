//
// Copyright 2013 Jared Egan
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

#import "TableSystemViewController.h"
#import "NimbusModels.h"
#import "NimbusCore.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TableSystemViewController() <NITableViewSystemDelegate,
UIScrollViewDelegate>

@property (nonatomic, strong) NITableViewSystem *tableSystem;
@property (nonatomic, strong) UILabel *scrollInfoLabel;
@property (nonatomic, strong) NISubtitleCellObject *scrollInfoTableObject;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TableSystemViewController

#pragma mark -
#pragma mark Init
////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  self = [super init];
	if (self) {
    self.title = @"TableViewSystem";
	}
	
	return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {

}

#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
  [super viewDidLoad];

  // Table View
  self.tableSystem = [NITableViewSystem tableSystemWithFrame:self.view.bounds
                                                       style:UITableViewStyleGrouped
                                                    delegate:self];
  [self.view addSubview:self.tableSystem.tableView];

  // Table datasource
  NSMutableArray *tableContents = [NSMutableArray array];

  [tableContents addObject:[NITitleCellObject objectWithTitle:@"Row 1"]];
  [tableContents addObject:[NITitleCellObject objectWithTitle:@"Row 2"]];

  self.scrollInfoTableObject = [NISubtitleCellObject objectWithTitle:@"Row 3" subtitle:@"Subtitle"];

  [tableContents addObject:self.scrollInfoTableObject];

  [self.tableSystem setDataSourceWithListArray:tableContents];

  // Scroll info label (to demonstrate UIScrollViewDelegate messages
  self.scrollInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 44)];
  self.scrollInfoLabel.textAlignment = NSTextAlignmentCenter;
  self.scrollInfoLabel.backgroundColor = [UIColor clearColor];
  [self.view addSubview:self.scrollInfoLabel];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  self.tableSystem.tableView.frame = self.view.bounds;
  self.scrollInfoLabel.frame = CGRectMake(self.scrollInfoLabel.frame.origin.x,
                                          self.view.bounds.size.height - self.scrollInfoLabel.frame.size.height - 10,
                                          self.scrollInfoLabel.frame.size.width,
                                          self.scrollInfoLabel.frame.size.height);
}

#pragma mark -
#pragma mark NITableViewSystemDelegate
- (void)tableSystem:(NITableViewSystem *)tableSystem didSelectObject:(id)object
        atIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Object was selected: %@ at indexPath: %@", object, indexPath);
  
}

- (void)tableSystem:(NITableViewSystem *)tableSystem didAssignCell:(id)object toTableItem:(id)tableItem
        atIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

  self.scrollInfoLabel.text = [NSString stringWithFormat:@"Scroll view offset: %f, %f", scrollView.contentOffset.x, scrollView.contentOffset.y];
}

@end


