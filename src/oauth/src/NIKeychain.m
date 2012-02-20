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

#import "NIKeychain.h"

@interface NIKeychainPassword()
@property (nonatomic, readwrite, copy) NSString* identifier;
@end

@implementation NIKeychainPassword

@synthesize identifier = _identifier;
@synthesize password = _password;

- (void)dealloc {
  [_identifier release];
  [_password release];

  [super dealloc];
}

- (id)initWithIdentifier:(NSString *)identifier {
  if (self = [super init]) {
    _identifier = [identifier copy];
  }

  return self;
}

- (NSMutableDictionary *)query {
  NSMutableDictionary *query = [[NSMutableDictionary alloc] init];  

  [query setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];

  NSData *encodedIdentifier = [self.identifier dataUsingEncoding:NSUTF8StringEncoding];
  [query setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
  [query setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
//  [query setObject:serviceName forKey:(id)kSecAttrService];
	
  return query; 
}

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
    SecItemUpdate((CFDictionaryRef)query,
                  (CFDictionaryRef)updateQuery);
  }
}

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

@end
