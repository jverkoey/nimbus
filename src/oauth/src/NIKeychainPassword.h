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
#import <Security/Security.h>

@interface NIKeychainPassword : NSObject

// Designated initializer.
- (id)initWithIdentifier:(NSString *)identifier;
+ (id)keychainPasswordWithIdentifier:(NSString *)identifier;

@property (nonatomic, readwrite, copy) NSString* password;
- (void)erasePassword;

@end

/**
 * A simple keychain storage mechanism for passwords.
 *
 * This object provides a simple interface for storing and retrieving values that need to be
 * safely encrypted in the keychain.
 *
 * Example:
@code
NIKeychainPassword* keychain = [NIKeychainPassword keychainPasswordWithIdentifier:@"authentication"];

// Store the password in the keychain:
keychain.password = @"my-secret-password";

// At a later point (perhaps even after the app restarts), fetch the password from the keychain:
NSString* password = keychain.password;

// Destroy the password:
[keychain erasePassword];
@endcode
 *
 *      @ingroup NimbusOAuth
 *      @class NIKeychainPassword
 */

/** @name Creating a Keychain Password */

/**
 * Initializes a newly allocated keychain password object with a given identifier.
 *
 * The identifier is used to uniquely identify this keychain password within this application.
 *
 *      @fn NIKeychainPassword::initWithIdentifier:
 */

/**
 * Returns an autoreleased keychain password object with a given identifier.
 *
 *      @sa NIKeychainPassword::initWithIdentifier:
 *      @fn NIKeychainPassword::keychainPasswordWithIdentifier:
 */

/** @name Querying a Keychain Password */

/**
 * The password value for this keychain item.
 *
 * This value is stored in, and retrieved from, the keychain on every access.
 *
 *      @fn NIKeychainPassword::password
 */

/**
 * Erases the password value from the keychain.
 *
 * Permanently destroys whatever password value was stored in the keychain for this object.
 *
 *      @fn NIKeychainPassword::erasePassword
 */
