//
//  SoundCloudController.m
//  OAuthCatalog
//
//  Created by Jeffrey Verkoeyen on 12-02-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundCloudController.h"

#import "TableViewText.h"
#import "TableViewKeyValue.h"

typedef enum {
  AuthenticateAction = 1,
  DeauthenticateAction,
} Actions;

@interface SoundCloudController()
@property (nonatomic, readwrite, retain) NISoundCloudOpenAuthenticator* auth;
@property (nonatomic, readwrite, retain) NITableViewModel* model;
@end

@implementation SoundCloudController

@synthesize auth = _auth;
@synthesize model = _model;

- (void)dealloc {
  [_auth release];
  [_model release];

  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.auth = [[[NISoundCloudOpenAuthenticator alloc]
                  initWithClientIdentifier:@"41381b580d073d076059a96d17da2e2e"
                  clientSecret:@"c35bb8d143e13255c2addca65e59a34d"] autorelease];
    self.title = @"SoundCloud";
  }
  return self;
}

- (void)refreshModel {
  NSMutableArray* objects = [NSMutableArray array];
  if (NIOpenAuthenticationStateAuthorized == self.auth.state) {
    [objects addObject:[TableViewText objectWithText:@"Authenticated!"
                                              object:nil]];
    
    [objects addObject:[TableViewText objectWithText:@"De-authenticate"
                                              object:[NSNumber numberWithInt:DeauthenticateAction]]];

  } else if (NIOpenAuthenticationStateFetchingToken == self.auth.state) {
    [objects addObject:[TableViewText objectWithText:@"Authenticating..."
                                              object:nil]];

  } else {
    [objects addObject:[TableViewText objectWithText:@"Authenticate"
                                              object:[NSNumber numberWithInt:AuthenticateAction]]];
  }
  self.model = [[[NITableViewModel alloc] initWithSectionedArray:objects
                                                        delegate:(id)[NICellFactory class]]autorelease];
  self.tableView.dataSource = self.model;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [self refreshModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TableViewText* textObject = [self.model objectAtIndexPath:indexPath];
  if (nil == textObject.object) {
    return;
  }

  switch ([textObject.object intValue]) {
    case AuthenticateAction: {
      [self.auth authenticateWithStateHandler:
       ^(NIOpenAuthenticator* auth, NIOpenAuthenticationState state, NSError* error) {
         [self refreshModel];
         [self.tableView reloadData];
       }];
      break;
    }
    case DeauthenticateAction: {
      [self.auth clearAuthentication];
      [self refreshModel];
      [self.tableView reloadData];
      break;
    }
  }
}

@end
