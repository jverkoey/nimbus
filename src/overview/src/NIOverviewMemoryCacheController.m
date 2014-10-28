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

#import "NIOverviewMemoryCacheController.h"

#import "NIDeviceInfo.h"
#import "NimbusModels.h"
#import "NimbusCore.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NIMemoryCache(Private)
@property (nonatomic, strong) NSMutableOrderedSet* lruCacheObjects;
@end

// Anonymous private category for LRU cache objects.
@interface NSObject(Private)
- (NSDate *)lastAccessTime;
@end

@interface NIOverviewMemoryCacheController()
@property (nonatomic, readonly, strong) NIMemoryCache* cache;
@property (nonatomic, strong) NITableViewModel* model;
@end

@implementation NIOverviewMemoryCacheController

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
}

- (id)initWithMemoryCache:(NIMemoryCache *)cache {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    _cache = cache;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(didReceiveMemoryWarning:)
               name: UIApplicationDidReceiveMemoryWarningNotification
             object: nil];
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didTapRefreshButton:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
  }
  return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
  return [self initWithMemoryCache:[Nimbus imageMemoryCache]];
}

#pragma mark - Model


- (void)refreshModel {
  NSMutableArray* contents = [NSMutableArray array];
  NSString* summary = nil;

  // Display a summary.
  if ([self.cache isKindOfClass:[NIImageMemoryCache class]]) {
    NIImageMemoryCache* imageCache = (NIImageMemoryCache *)self.cache;
    summary = [NSString stringWithFormat:
               @"Number of images: %zd\nNumber of pixels: %@/%@\nStress limit: %@",
               self.cache.count,
               NIStringFromBytes(imageCache.numberOfPixels),
               NIStringFromBytes(imageCache.maxNumberOfPixels),
               NIStringFromBytes(imageCache.maxNumberOfPixelsUnderStress)];

  } else {
    summary = [NSString stringWithFormat:
               @"Number of objects: %zd",
               self.cache.count];
  }
  [contents addObject:[NITableViewModelFooter footerWithTitle:summary]];

  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  // We care more about time than date here.
  [formatter setDateStyle:NSDateFormatterShortStyle];
  [formatter setTimeStyle:NSDateFormatterMediumStyle];

  // Add each of the cache objects to the model.
  for (id cacheObject in self.cache.lruCacheObjects) {
    NSString* name = nil;
    UIImage* image = nil;
    NSDate* lastAccessTime = nil;

    // We're accessing a private object from the core here, so we can't assume that any of
    // these selectors will be around forever. That being said, we should try to remember to
    // update this controller if the cache object internals ever change.
    // If any of these assertions fire it means we've changed the cache object signatures but
    // haven't gotten around to updating this controller yet.
    NIDASSERT([cacheObject respondsToSelector:@selector(name)]);
    if ([cacheObject respondsToSelector:@selector(name)]) {
      name = [cacheObject performSelector:@selector(name)];
    }
    NIDASSERT([cacheObject respondsToSelector:@selector(object)]);
    if ([cacheObject respondsToSelector:@selector(object)]) {
      id object = [cacheObject performSelector:@selector(object)];
      if ([object isKindOfClass:[UIImage class]]) {
        image = object;
      }
    }
    NIDASSERT([cacheObject respondsToSelector:@selector(lastAccessTime)]);
    if ([cacheObject respondsToSelector:@selector(lastAccessTime)]) {
      lastAccessTime = [cacheObject performSelector:@selector(lastAccessTime)];
    }

    [contents addObject:
     [NISubtitleCellObject objectWithTitle:name
                                  subtitle:[NSString stringWithFormat:
                                            @"Last access: %@",
                                            [formatter stringFromDate:lastAccessTime]]
                                     image:image]];
  }

  if (0 == self.cache.count) {
    [contents addObject:[NITitleCellObject objectWithTitle:@"No cache objects"]];
  }

  [contents addObject:[NITableViewModelFooter footerWithTitle:
                       @"The most-recently-used object is here at the bottom"]];

  self.model = [[NITableViewModel alloc] initWithSectionedArray:contents
                                                       delegate:(id)[NICellFactory class]];
  self.tableView.dataSource = self.model;
  [self.tableView reloadData];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self refreshModel];
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}

#endif

#pragma mark - Notifications


- (void)didReceiveMemoryWarning:(NSNotification *)notification {
  [self refreshModel];
}

#pragma mark - Actions


- (void)didTapRefreshButton:(UIBarButtonItem *)button {
  [self refreshModel];
}

@end
