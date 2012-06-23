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

#import "RestoringLauncherViewController.h"

@interface RestoringLauncherViewController () <NILauncherViewModelDelegate>
@property (nonatomic, readwrite, retain) NILauncherViewModel* model;
@end

@implementation RestoringLauncherViewController

@synthesize model = _model;

- (NSString *)pathForLauncherData {
  return NIPathForDocumentsResource(@"launcher");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Restoring";

    NSString* path = [self pathForLauncherData];
    _model = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (nil == _model) {
      _model = [[NILauncherViewModel alloc] initWithArrayOfPages:nil delegate:nil];
    }
    _model.delegate = self;

    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                  target:self
                                                  action:@selector(didTapAddButton:)];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor underPageBackgroundColor];

  self.launcherView.dataSource = self.model;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

#pragma mark - NILauncherViewModelDelegate

- (void)launcherViewModel:(NILauncherViewModel *)launcherViewModel
      configureButtonView:(UIView<NILauncherButtonView> *)buttonView
          forLauncherView:(NILauncherView *)launcherView
                pageIndex:(NSInteger)pageIndex
              buttonIndex:(NSInteger)buttonIndex
                   object:(id<NILauncherViewObject>)object {
  NILauncherButtonView* launcherButtonView = (NILauncherButtonView *)buttonView;
  
  launcherButtonView.label.layer.shadowColor = [UIColor blackColor].CGColor;
  launcherButtonView.label.layer.shadowOffset = CGSizeMake(0, 1);
  launcherButtonView.label.layer.shadowOpacity = 1;
  launcherButtonView.label.layer.shadowRadius = 1;
}

#pragma mark - NILauncherDelegate

- (void)launcherView:(NILauncherView *)launcher didSelectItemOnPage:(NSInteger)page atIndex:(NSInteger)index {
  id<NILauncherViewObject> object = [self.model objectAtIndex:index pageIndex:page];
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                  message:[@"Did tap button with title: " stringByAppendingString:object.title]
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

#pragma mark - User Actions

- (void)didTapAddButton:(UIBarButtonItem *)barButtonItem {
  NSString* imagePath = NIPathForBundleResource(nil, @"Icon.png");
  UIImage* image = [[Nimbus imageMemoryCache] objectWithName:imagePath];
  if (nil == image) {
    image = [UIImage imageWithContentsOfFile:imagePath];
    [[Nimbus imageMemoryCache] storeObject:image withName:imagePath];
  }

  NSInteger randomNumberOfItems = arc4random_uniform(8) + 1;
  NSMutableArray* objects = [NSMutableArray array];
  for (NSInteger ix = 0; ix < randomNumberOfItems; ++ix) {
    [objects addObject:[NILauncherViewObject objectWithTitle:[NSString stringWithFormat:@"Nimbus %d", arc4random_uniform(1000)] image:image]];
  }

  [self.model appendPage:objects];
  [self.launcherView reloadData];

  [NSKeyedArchiver archiveRootObject:self.model toFile:[self pathForLauncherData]];
}

@end
