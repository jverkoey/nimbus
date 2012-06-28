//
//  VerticalPagingScrollViewController.m
//  NimbusCatalog
//
//  Created by Manu Cornet on 6/28/12.
//  Copyright (c) 2012 Nimbus. All rights reserved.
//

#import "VerticalPagingScrollViewController.h"

#import "NimbusPagingScrollView.h"

@interface VerticalPagingScrollViewController ()

@end

@implementation VerticalPagingScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Vertical Scroll View";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor blackColor];

  self.pagingScrollView = [[NIVerticalPagingScrollView alloc] initWithFrame:self.view.bounds];
  self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  self.pagingScrollView.dataSource = self;
  [self.view addSubview:self.pagingScrollView];
  [self.pagingScrollView reloadData];
}

@end
