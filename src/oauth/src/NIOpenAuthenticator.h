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

#import <Foundation/Foundation.h>

@class NIOpenAuthenticator;

typedef enum {
  NIOpenAuthenticationStateInactive,
  NIOpenAuthenticationStateFetchingToken,
  NIOpenAuthenticationStateAuthorized,
} NIOpenAuthenticationState;

typedef void (^NIOpenAuthenticationBlock)(NIOpenAuthenticator* auth, NIOpenAuthenticationState state, NSError* error);

@interface NIOpenAuthenticator : NSObject

// Designated initializer.
- (id)initWithClientIdentifier:(NSString *)clientIdentifier clientSecret:(NSString *)clientSecret redirectBasePath:(NSString *)redirectBasePath;
- (id)initWithClientIdentifier:(NSString *)clientIdentifier clientSecret:(NSString *)clientSecret;

@property (nonatomic, readonly, copy) NSString* clientIdentifier;
@property (nonatomic, readonly, copy) NSString* clientSecret;

@property (nonatomic, readonly, copy) NSString* redirectBasePath;
@property (nonatomic, readonly, assign) NIOpenAuthenticationState state;

@property (nonatomic, readonly, copy) NSString* oauthCode;
@property (nonatomic, readonly, copy) NSString* oauthToken;

- (void)authenticateWithStateHandler:(NIOpenAuthenticationBlock)stateHandler;

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

+ (void)setApplicationRedirectBasePath:(NSString *)redirectBasePath;

@end
