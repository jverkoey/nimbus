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

#import "NINetworkTableViewController.h"

#import "NimbusCore+Additions.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NINetworkTableViewController()
@property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorStyle;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@end


@implementation NINetworkTableViewController



- (void)dealloc {
  _tableView.delegate = nil;
  _tableView.dataSource = nil;
}

- (id)initWithStyle:(UITableViewStyle)style activityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle {
  if ((self = [super initWithNibName:nil bundle:nil])) {
    self.tableViewStyle = style;
    self.activityIndicatorStyle = activityIndicatorStyle;
    self.clearsSelectionOnViewWillAppear = YES;
  }
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  return [self initWithStyle:UITableViewStylePlain
      activityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void)loadView {
  [super loadView];

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.tableViewStyle];
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.view addSubview:self.tableView];

  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorStyle];
  self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleMargins;
  [self.activityIndicator sizeToFit];
  self.activityIndicator.frame = NIFrameOfCenteredViewWithinView(self.activityIndicator, self.view);
  [self.view addSubview:self.activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.clearsSelectionOnViewWillAppear) {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                  animated:animated];
  }
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return nil;
}

#pragma mark - Public


- (void)setIsLoading:(BOOL)isLoading {
  self.tableView.hidden = isLoading;

  if (isLoading) {
    [self.activityIndicator startAnimating];

  } else {
    [self.activityIndicator stopAnimating];
  }
}

@end
