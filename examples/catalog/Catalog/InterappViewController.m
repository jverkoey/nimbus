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

#import "InterappViewController.h"
#import "NimbusModels.h"
#import "NimbusInterapp.h"

//
// What's going on in this file:
//
// This controller shows all of the available communication methods that NIInterapp provides.
//
// You will find the following Nimbus features used:
//
// [interapp]
// All NIInterapp category methods
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// CoreLocation.framework
//

@interface InterappViewController () <UIDocumentInteractionControllerDelegate>
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;
@property (nonatomic, readwrite, copy) NSURL* fileUrl;
@property (nonatomic, readwrite, retain) UIDocumentInteractionController* docController;
@end

@implementation InterappViewController

@synthesize model = _model;
@synthesize actions = _actions;
@synthesize fileUrl = _fileUrl;
@synthesize docController = _docController;

- (void)cleanupDocController {
  [[NSFileManager defaultManager] removeItemAtURL:self.fileUrl error:nil];
  self.fileUrl = nil;
  self.docController = nil;
}

// This method is the short form of adding a cell object with an action.
- (id)objectWithAction:(BOOL (^)())action title:(NSString *)title subtitle:(NSString *)subtitle {
  return [self.actions attachToObject:[NISubtitleCellObject objectWithTitle:title subtitle:subtitle]
                             tapBlock:
          ^BOOL(id object, UIViewController *controller, NSIndexPath* indexPath) {
            if (!action()) {
              UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"We've givin' her all she's got, cap'n!"
                                                              message:@"The app you tried to open does not appear to be installed on this device."
                                                             delegate:nil
                                                    cancelButtonTitle:@"Oh well"
                                                    otherButtonTitles:nil];
              [alert show];
            }
            return YES;
          }];
}

// Prepares an Instagram image for sharing and then uses the UIDocumentInteractionController
// to show a sharing controller.
- (BOOL)openInstagramImage {
  [self cleanupDocController];
  
  NSError* error = nil;
  self.fileUrl = [NIInterapp urlForInstagramImageAtFilePath:NIPathForBundleResource(nil, @"dilly.jpg")
                                                      error:&error];
  if (nil != self.fileUrl) {
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:_fileUrl];
    self.docController.delegate = self;

    [self.docController presentOpenInMenuFromRect:CGRectZero
                                           inView:self.view
                                         animated:YES];
    return YES;
  }

  return NO;
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
    self.title = @"All Actions";
    
    _actions = [[NITableViewActions alloc] initWithTarget:self];

    NSArray* sectionedObjects =
    [NSArray arrayWithObjects:

     @"Safari",
     [self objectWithAction:^{return [NIInterapp safariWithURL:[NSURL URLWithString:@"http://latest.docs.nimbuskit.info"]];}
                      title:@"Open a URL in Safari" subtitle:@"http://latest.docs.nimbuskit.info"],

     @"Maps",
     [self objectWithAction:^{return [NIInterapp googleMapAtLocation:CLLocationCoordinate2DMake(37.37165, -121.97877)];}
                      title:@"Open a Lat/Long" subtitle:@"Trampoline dodgeball!"],
     [self objectWithAction:^{return [NIInterapp googleMapAtLocation:CLLocationCoordinate2DMake(37.37165, -121.97877)
                                                               title:@"Trampoline Dodgeball"];}
                      title:@"Open a Lat/Long with a title" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp googleMapDirectionsFromLocation:CLLocationCoordinate2DMake(37.6139, -122.4871)
                                                                      toLocation:CLLocationCoordinate2DMake(36.6039, -121.9116)];}
                      title:@"Directions" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp googleMapWithQuery:@"Boudin Bakeries"];}
                      title:@"Search for Boudin Bakeries" subtitle:nil],

     @"Phone",
     [self objectWithAction:^{return [NIInterapp phone];} title:@"Open the app" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp phoneWithNumber:@"123-500-7890"];} title:@"Call 123-500-7890" subtitle:nil],

     @"SMS",
     [self objectWithAction:^{return [NIInterapp sms];} title:@"Open the app" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp smsWithNumber:@"123-500-7890"];} title:@"SMS 123-500-7890" subtitle:nil],
     
     @"Mail",
     [self objectWithAction:^{NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
      invocation.recipient = @"jverkoey@gmail.com";
      return [NIInterapp mailWithInvocation:invocation];} title:@"Mail to jverkoey@gmail.com" subtitle:nil],
     [self objectWithAction:^{NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
      invocation.recipient = @"jverkoey@gmail.com";
      invocation.subject = @"Nimbus made me do it!";
      return [NIInterapp mailWithInvocation:invocation];} title:@"Mail with a subject" subtitle:nil],
     [self objectWithAction:^{NIMailAppInvocation* invocation = [NIMailAppInvocation invocation];
      invocation.recipient = @"jverkoey@gmail.com";
      invocation.subject = @"Nimbus made me do it!";
      invocation.bcc = @"jverkoey+bcc@gmail.com";
      invocation.cc = @"jverkoey+cc@gmail.com";
      invocation.body = @"This will be an awesome email.";
      return [NIInterapp mailWithInvocation:invocation];} title:@"Mail with all details" subtitle:nil],
     
     @"YouTube",
     [self objectWithAction:^{return [NIInterapp youTubeWithVideoId:@"fzzjgBAaWZw"];} title:@"Ninja cat video" subtitle:nil],
     
     @"iBooks",
     [self objectWithAction:^{return [NIInterapp iBooks];} title:@"Open the app" subtitle:nil],
     
     @"App Store",
     [self objectWithAction:^{return [NIInterapp appStoreWithAppId:@"364709193"];} title:@"Buy the iBooks app" subtitle:nil],
     
     @"Facebook",
     [self objectWithAction:^{return [NIInterapp facebook];} title:@"Open the app" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp facebookProfileWithId:@"122605446"];} title:@"Jeff's profile page" subtitle:nil],
     
     @"Twitter",
     [self objectWithAction:^{return [NIInterapp twitter];} title:@"Open the app" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp twitterWithMessage:@"I'm playing with the Nimbus sample apps! http://nimbuskit.info"];} title:@"Post a tweet" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp twitterProfileForUsername:@"featherless"];} title:@"Open featherless' profile" subtitle:nil],
     
     @"Instagram",
     [self objectWithAction:^{return [NIInterapp instagram];} title:@"Open the app" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp instagramCamera];} title:@"Camera" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp instagramProfileForUsername:@"featherless"];} title:@"Open featherless' profile" subtitle:nil],
     [self objectWithAction:^{return [self openInstagramImage];} title:@"Open local image in Instagram" subtitle:nil],
     
     @"Custom Application",
     [self objectWithAction:^{return [NIInterapp applicationWithScheme:@"RAWR:"];} title:@"Open custom app (RAWR:)" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp applicationWithScheme:@"RAWR:"
                                                         andAppStoreId:@"000000000"];} title:@"Custom app or AppStore" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp applicationWithScheme:@"RAWR:"
                                                               andPath:@"//friends/blah"];} title:@"Custom app with url" subtitle:nil],
     [self objectWithAction:^{return [NIInterapp applicationWithScheme:@"RAWR:"
                                                            appStoreId:@"000000000" 
                                                               andPath:@"//friends/blah"];} title:@"Custom app with url or AppStore" subtitle:nil],
     
     nil];

    _model = [[NITableViewModel alloc] initWithSectionedArray:sectionedObjects
                                                     delegate:(id)[NICellFactory class]];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView.dataSource = self.model;
  self.tableView.delegate = [self.actions forwardingTo:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
  [self cleanupDocController];
}

@end
