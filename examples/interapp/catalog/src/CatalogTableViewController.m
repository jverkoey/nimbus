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
#import <objc/message.h>

typedef BOOL (^BasicBlockReturnBool)(void);

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CatalogTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cleanupDocController {
  [[NSFileManager defaultManager] removeItemAtURL:_fileUrl error:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self cleanupDocController];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.title = NSLocalizedString(@"InterApp Catalog", @"");
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
#pragma mark UIDocumentInteractionControllerDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
  [self cleanupDocController];
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
            @"Generic",
            [NSDictionary dictionaryWithObjectsAndKeys: @"URL in Safari", @"title",
             ^{ return [NIInterapp safariWithURL:[NSURL URLWithString:@"http://jverkoey.github.com/nimbus"]];}, @"block", nil],

            @"Google Maps",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Location", @"title",
             ^{ return [NIInterapp googleMapAtLocation:CLLocationCoordinate2DMake(37.37165, -121.97877)];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Location with title", @"title",
             ^{ return [NIInterapp googleMapAtLocation:CLLocationCoordinate2DMake(37.37165, -121.97877)
                                                title:@"Trampoline Dodgeball"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Directions", @"title",
             ^{ return [NIInterapp googleMapDirectionsFromLocation:CLLocationCoordinate2DMake(37.6139, -122.4871)
                                                       toLocation:CLLocationCoordinate2DMake(36.6039, -121.9116)];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Query for Boudin Bakeries", @"title",
             ^{ return [NIInterapp googleMapWithQuery:@"Boudin Bakeries"];}, @"block", nil],

            @"Phone",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp phone];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Call 123-456-7890", @"title",
             ^{ return [NIInterapp phoneWithNumber:@"123-456-7890"];}, @"block", nil],

            @"SMS",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp sms];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"SMS 123-456-7890", @"title",
             ^{ return [NIInterapp smsWithNumber:@"123-456-7890"];}, @"block", nil],

            @"Mail",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Mail to jverkoey@gmail.com", @"title",
             ^{ NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
              invocation.recipient = @"jverkoey+nimbus@gmail.com";
              return [NIInterapp mailWithInvocation:invocation];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Mail to jverkoey@gmail.com with a subject", @"title",
             ^{ NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
              invocation.recipient = @"jverkoey+nimbus@gmail.com";
              invocation.subject = @"Nimbus made me do it!";
              return [NIInterapp mailWithInvocation:invocation];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Mail to jverkoey@gmail.com with all details", @"title",
             ^{ NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
              invocation.recipient = @"jverkoey+nimbus@gmail.com";
              invocation.subject = @"Nimbus made me do it!";
              invocation.bcc = @"jverkoey+bcc@gmail.com";
              invocation.cc = @"jverkoey+cc@gmail.com";
              invocation.body = @"This will be an awesome email.";
              return [NIInterapp mailWithInvocation:invocation];}, @"block", nil],

            @"YouTube",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Ninja cat video", @"title",
             ^{ return [NIInterapp youTubeWithVideoId:@"fzzjgBAaWZw"];}, @"block", nil],

            @"iBooks",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp iBooks];}, @"block", nil],

            @"App Store",
            [NSDictionary dictionaryWithObjectsAndKeys: @"iBooks", @"title",
             ^{ return [NIInterapp appStoreWithAppId:@"364709193"];}, @"block", nil],
            
            @"Facebook",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp facebook];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Jeff's profile page", @"title",
             ^{ return [NIInterapp facebookProfileWithId:@"122605446"];}, @"block", nil],

            @"Twitter",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp twitter];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Post a tweet", @"title",
             ^{ return [NIInterapp twitterWithMessage:@"I'm playing with the Nimbus sample apps! http://jverkoey.github.com/nimbus"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"featherless", @"title",
             ^{ return [NIInterapp twitterProfileForUsername:@"featherless"];}, @"block", nil],

            @"Instagram",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open the app", @"title",
             ^{ return [NIInterapp instagram];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Camera", @"title",
             ^{ return [NIInterapp instagramCamera];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"featherless", @"title",
             ^{ return [NIInterapp instagramProfileForUsername:@"featherless"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open local image in Instagram", @"title",
             [NSValue valueWithPointer:@selector(openInstagramImage:)], @"selector", nil],
            
            @"Custom Application",
            [NSDictionary dictionaryWithObjectsAndKeys: @"Open custom app (RAWR:)", @"title",
             ^{ return [NIInterapp applicationWithScheme:@"RAWR:"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Custom app or AppStore", @"title",
             ^{ return [NIInterapp applicationWithScheme:@"RAWR:"
                                            andAppStoreId:@"000000000"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Custom app with url", @"title",
             ^{ return [NIInterapp applicationWithScheme:@"RAWR:" 
                                                  andPath:@"//friends/blah"];}, @"block", nil],
            [NSDictionary dictionaryWithObjectsAndKeys: @"Custom app with url or AppStore", @"title",
             ^{ return [NIInterapp applicationWithScheme:@"RAWR:" 
                                               appStoreId:@"000000000" 
                                                  andPath:@"//friends/blah"];}, @"block", nil],

            nil];
  }
  return rows;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openInstagramImage:(NSIndexPath *)indexPath {
  [self cleanupDocController];

  NSError* error = nil;
  _fileUrl = [NIInterapp urlForInstagramImageAtFilePath: NIPathForBundleResource(nil, @"dilly.jpg")
                                                        error: &error];
  NIDASSERT(nil != _fileUrl);
  if (nil != _fileUrl) {
    _docController = [UIDocumentInteractionController interactionControllerWithURL:_fileUrl];
    _docController.delegate = self;

    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [_docController presentOpenInMenuFromRect: cell.frame
                                       inView: self.tableView
                                     animated: YES];
  }
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
    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                   reuseIdentifier: @"row"];
    cell.accessoryType = UITableViewCellAccessoryNone;
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

  BasicBlockReturnBool block = [object objectForKey:@"block"];
  if (nil != block) {
    BOOL result = block();
    if (!result) {
      UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"We've givin' her all she's got, cap'n!"
                                                       message: @"The app you tried to open does not appear to be installed on this device."
                                                      delegate: nil
                                             cancelButtonTitle: @"Oh well"
                                             otherButtonTitles: nil];
      [alert show];
    }

  } else if (nil != [object objectForKey:@"selector"]) {
    SEL selector = (SEL)[[object objectForKey:@"selector"] pointerValue];
    // supress warning: PerformSelector may cause a leak because its selector is unknown
    objc_msgSend(self, selector, indexPath);
  }
}


@end
