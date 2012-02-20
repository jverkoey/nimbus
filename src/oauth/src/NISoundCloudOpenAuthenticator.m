//
// Copyright 2012 Jeff Verkoeyen
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

#import "NISoundCloudOpenAuthenticator.h"

#import "NIOpenAuthenticator+Subclassing.h"
#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISoundCloudOpenAuthenticator


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)redirectPath {
  return [[super redirectPath] stringByAppendingString:@"/soundcloud"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)authenticationUrl {
  return [NSURL URLWithString:
          [NSString stringWithFormat:
           @"https://soundcloud.com/connect?client_id=%@&response_type=code&redirect_uri=%@&scope=non-expiring",
           self.clientIdentifier,
           self.redirectPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL *)tokenUrl {
  return [NSURL URLWithString:@"https://api.soundcloud.com/oauth2/token"];
}

@end
