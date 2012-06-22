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
#import "AFNetworking.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CatalogTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.title = NSLocalizedString(@"Photo Album Catalog", @"");

    NSArray* tableContents =
    [NSArray arrayWithObjects:
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
     [NSDictionary dictionaryWithObjectsAndKeys:
      [FacebookPhotoAlbumViewController class], @"class",
      @"Shark Week", @"title",
      @"208546235826221", @"initWith",
      nil],
     [NSDictionary dictionaryWithObjectsAndKeys:
      [FacebookPhotoAlbumViewController class], @"class",
      @"Game of Thrones", @"title",
      @"489714642733", @"initWith",
      nil],
     nil];
    _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                     delegate:self];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = _model;
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
#pragma mark NITableViewModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];

  if (nil == cell) {
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }

  cell.textLabel.text = [object objectForKey:@"title"];

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [_model objectAtIndexPath:indexPath];

  Class vcClass = [object objectForKey:@"class"];
  id initWith = [object objectForKey:@"initWith"];
  NSString* title = [object objectForKey:@"title"];
  UIViewController* vc = [[vcClass alloc] initWith:initWith];
  vc.title = title;

  [self.navigationController pushViewController:vc animated:YES];
}


@end
