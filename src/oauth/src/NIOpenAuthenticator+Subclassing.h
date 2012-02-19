//
//  NIOpenAuthenticator+Subclassing.h
//  Nimbus
//
//  Created by Jeffrey Verkoeyen on 12-02-19.
//  Copyright (c) 2012 Jeff Verkoeyen. All rights reserved.
//

#import "NIOpenAuthenticator.h"

@interface NIOpenAuthenticator()

@property (nonatomic, readonly, copy) NSURL* authenticationUrl;
@property (nonatomic, readonly, copy) NSURL* tokenUrl;

@end
