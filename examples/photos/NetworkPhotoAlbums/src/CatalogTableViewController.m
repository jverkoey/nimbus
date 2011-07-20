//
// Copyright 2011 Jeff Verkoeyen
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

#import "CatalogTableViewController.h"

#import "FacebookPhotoAlbumViewController.h"
#import "DribbblePhotoAlbumViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CatalogTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.title = NSLocalizedString(@"Photo Album Catalog", @"");
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault
                                              animated: animated];

  UINavigationBar* navBar = self.navigationController.navigationBar;
  navBar.barStyle = UIBarStyleDefault;
  navBar.translucent = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

/**
 * TODO (jverkoey July 20, 2011): This data source implementation is totally messy.
 * There *is* potential here so I might consider cleaning this up someday.
 */


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)rows {
  static NSArray* rows = nil;
  if (nil == rows) {
    rows = [NSArray arrayWithObjects:
            @"Dribbble",
            [NSDictionary dictionaryWithObjectsAndKeys:
             [DribbblePhotoAlbumViewController class], @"class",
             @"Popular Shots", @"title",
             @"/shots", @"initWith",
             nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
             [DribbblePhotoAlbumViewController class], @"class",
             @"Everyone's Shots", @"title",
             @"/shots/everyone", @"initWith",
             nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
             [DribbblePhotoAlbumViewController class], @"class",
             @"Debuts", @"title",
             @"/shots/debuts", @"initWith",
             nil],

            @"Facebook Albums",
            [NSDictionary dictionaryWithObjectsAndKeys:
             [FacebookPhotoAlbumViewController class], @"class",
             @"120th Commencement in Pictures", @"title",
             @"10150219083838418", @"initWith",
             nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
             [FacebookPhotoAlbumViewController class], @"class",
             @"Stanford 40th Annual Powwow", @"title",
             @"10150185938728418", @"initWith",
             nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
             [FacebookPhotoAlbumViewController class], @"class",
             @"Spring blossoms at Stanford", @"title",
             @"10150160584103418", @"initWith",
             nil],

            nil];
    [rows retain];
  }
  return rows;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  NSArray* rows = [self rows];

  NSInteger numberOfSections = 0;
  for (id object in rows) {
    numberOfSections += [object isKindOfClass:[NSString class]];
  }

  return MAX(1, numberOfSections);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSArray* rows = [self rows];

  NSInteger sectionIndex = -1;
  for (id object in rows) {
    sectionIndex += [object isKindOfClass:[NSString class]];

    if (sectionIndex == section) {
      return object;
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray* rows = [self rows];

  NSInteger sectionIndex = -1;
  NSInteger numberOfRows = 0;
  for (id object in rows) {
    sectionIndex += [object isKindOfClass:[NSString class]];

    if (sectionIndex == section && [object isKindOfClass:[NSDictionary class]]) {
      numberOfRows++;
    } else if (numberOfRows > 0) {
      break;
    }
  }

  return numberOfRows;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)objectForIndexPath:(NSIndexPath *)indexPath {
  // UGH: This is slow. Thankfully it doesn't matter because we know that we're only ever going to
  // have < 100 items or so.

  NSArray* rows = [self rows];

  NSInteger sectionIndex = -1;
  NSInteger rowIndex = -1;
  for (id object in rows) {
    sectionIndex += [object isKindOfClass:[NSString class]];

    if (sectionIndex == [indexPath section] && [object isKindOfClass:[NSDictionary class]]) {
      rowIndex++;
    } else if (rowIndex >= 0) {
      break;
    }

    if (rowIndex == [indexPath row] && sectionIndex == [indexPath section]) {
      return object;
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];

  if (nil == cell) {
    cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"]
            autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  id object = [self objectForIndexPath:indexPath];

  cell.textLabel.text = [object objectForKey:@"title"];

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self objectForIndexPath:indexPath];

  Class vcClass = [object objectForKey:@"class"];
  id initWith = [object objectForKey:@"initWith"];
  NSString* title = [object objectForKey:@"title"];
  UIViewController* vc = [[[vcClass alloc] initWith:initWith] autorelease];
  vc.title = title;

  [self.navigationController pushViewController:vc animated:YES];
}


@end
