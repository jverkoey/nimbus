//
//  NIOpenAuthenticator+Subclassing.h
//  Nimbus
//
//  Created by Jeffrey Verkoeyen on 12-02-19.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIOpenAuthenticator.h"

@interface NIOpenAuthenticator()

/**
 * The path that will be used to open this application once the OAuth handshake completes.
 *
 * Subclasses should implement this method and append a unique identifier so that the authentication
 * mechanism can find the correct authenticator object.
 *
 * Example:
@code
- (NSString *)applicationRedirectPath {
  return [[super applicationRedirectPath] stringByAppendingString:@"/soundcloud"];
}
@endcode
 */
- (NSString *)applicationRedirectPath;

@property (nonatomic, readonly, copy) NSURL* authenticationUrl;
@property (nonatomic, readonly, copy) NSURL* tokenUrl;

@end
