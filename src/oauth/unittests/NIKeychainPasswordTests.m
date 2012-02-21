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

// See: http://bit.ly/hS5nNh for unit test macros.

#import <SenTestingKit/SenTestingKit.h>

#import "NIKeychainPassword.h"
#import "NimbusCore.h"

@interface NIKeychainPasswordTests : SenTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIKeychainPasswordTests


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  NIKeychainPassword* keychain = [NIKeychainPassword keychainPasswordWithIdentifier:@"auth"];
  [keychain erasePassword];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testInitialization {
  NIKeychainPassword* keychain = [[[NIKeychainPassword alloc] initWithIdentifier:@"auth"] autorelease];
  STAssertNil(keychain.password, @"Password should be nil by default.");

  keychain = [NIKeychainPassword keychainPasswordWithIdentifier:@"auth"];
  STAssertNil(keychain.password, @"Password should be nil by default.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStorageAndRetrieval {
  NIKeychainPassword* keychainStorage = [[[NIKeychainPassword alloc] initWithIdentifier:@"auth"] autorelease];
  keychainStorage.password = @"mypassword";
  STAssertTrue([keychainStorage.password isEqualToString:@"mypassword"], @"Password should be equal.");
  
  NIKeychainPassword* keychainRetrieval = [NIKeychainPassword keychainPasswordWithIdentifier:@"auth"];
  STAssertTrue([keychainRetrieval.password isEqualToString:@"mypassword"], @"Password should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testDoubleStorageAndRetrieval {
  NIKeychainPassword* keychainStorage = [[[NIKeychainPassword alloc] initWithIdentifier:@"auth"] autorelease];
  keychainStorage.password = @"mypassword";
  keychainStorage.password = @"mypassword2";
  STAssertTrue([keychainStorage.password isEqualToString:@"mypassword2"], @"Password should be equal.");
  
  NIKeychainPassword* keychainRetrieval = [NIKeychainPassword keychainPasswordWithIdentifier:@"auth"];
  STAssertTrue([keychainRetrieval.password isEqualToString:@"mypassword2"], @"Password should be equal.");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testStorageDeletionAndRetrieval {
  NIKeychainPassword* keychainStorage = [[[NIKeychainPassword alloc] initWithIdentifier:@"auth"] autorelease];
  keychainStorage.password = @"mypassword";
  [keychainStorage erasePassword];

  NIKeychainPassword* keychainRetrieval = [NIKeychainPassword keychainPasswordWithIdentifier:@"auth"];
  STAssertNil(keychainRetrieval.password, @"Password should be nil.");
}


@end
