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

#import "NIKeychainPassword.h"

#import "NimbusCore.h"

@interface NIKeychainPassword()
@property (nonatomic, readwrite, copy) NSDictionary* baseQuery;
@property (nonatomic, readwrite, copy) NSString* identifier;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIKeychainPassword

@synthesize baseQuery = _baseQuery;
@synthesize identifier = _identifier;
@synthesize password = _password;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_baseQuery release];
  [_identifier release];
  [_password release];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithIdentifier:(NSString *)identifier {
  if ((self = [super init])) {
    _identifier = [identifier copy];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)keychainPasswordWithIdentifier:(NSString *)identifier {
  return [[[self alloc] initWithIdentifier:identifier] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @internal
 * Returns a basic query for interacting with the keychain.
 */
- (NSMutableDictionary *)query {
  if (nil == self.baseQuery) {
    NSMutableDictionary* query = [[[NSMutableDictionary alloc] init] autorelease];  

    [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];

    NSData* encodedIdentifier = [self.identifier dataUsingEncoding:NSUTF8StringEncoding];
    [query setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [query setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    if (nil != bundleIdentifier) {
      [query setObject:bundleIdentifier forKey:(id)kSecAttrService];
    }

    self.baseQuery = query;
  }

  return [[self.baseQuery mutableCopy] autorelease]; 
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPassword:(NSString *)password {
  NSMutableDictionary* query = [self query];
  NSData *data = [password dataUsingEncoding:NSUTF8StringEncoding];

  NSString* existingPassword = self.password;
  if (nil == existingPassword) {
    [query setObject:data forKey:(id)kSecValueData];

    OSStatus status = SecItemAdd((CFDictionaryRef)query, NULL);
    NIDASSERT(status == noErr);

  } else {
    NSDictionary* updateQuery = [NSDictionary dictionaryWithObject:data forKey:(id)kSecValueData];
    SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)updateQuery);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)password {
  NSMutableDictionary* query = [self query];
  [query setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
  [query setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];

  NSData* result = nil;
  OSStatus status = SecItemCopyMatching((CFDictionaryRef)query,
                                        (CFTypeRef *)&result);
  if (status == noErr) {
    return [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)erasePassword {
  NSMutableDictionary* query = [self query];
  SecItemDelete((CFDictionaryRef)query);
}

@end
