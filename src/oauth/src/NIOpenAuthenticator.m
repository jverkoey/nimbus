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

#import "NIOpenAuthenticator.h"

#import "NimbusCore.h"

@implementation NIOpenAuthenticator

@synthesize clientIdentifier = _clientIdentifier;
@synthesize clientSecret = _clientSecret;

- (void)dealloc {
  NI_RELEASE_SAFELY(_clientIdentifier);
  NI_RELEASE_SAFELY(_clientSecret);

  [super dealloc];
}

- (id)initWithClientIdentifier:(NSString *)clientIdentifier clientSecret:(NSString *)clientSecret {
  if ((self = [super init])) {
    _clientIdentifier = [clientIdentifier copy];
    _clientSecret = [clientSecret copy];
  }
}

@end
