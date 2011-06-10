//
// Copyright 2011 Jeff Verkoeyen
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

/**
 * @ingroup NimbusCore
 * @{
 *
 * All category documentation is found in the source files due to limitations of Doxygen.
 * Look for the documentation in the Classes tab of the documentation.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef BASE_PRODUCT_NAME
#import "NimbusCore/NimbusCore.h"
#else
#import "NimbusCore.h"
#endif

#pragma mark -
#pragma mark NSData Additions

@interface NSData (NimbusCore)

@property (nonatomic, readonly) NSString* md5Hash;

@property (nonatomic, readonly) NSString* sha1Hash;

@end


#pragma mark -
#pragma mark NSString Additions

@interface NSString (NimbusCore)


#pragma mark Checking String Contents

- (BOOL)isWhitespaceAndNewlines;


#pragma mark Display

- (CGFloat)heightWithFont: (UIFont*)font
       constrainedToWidth: (CGFloat)width
            lineBreakMode: (UILineBreakMode)lineBreakMode;


#pragma mark URL queries

- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding;

- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;


#pragma mark Versions

- (NSComparisonResult)versionStringCompare:(NSString *)other;


#pragma mark Hashing

@property (nonatomic, readonly) NSString* md5Hash;
@property (nonatomic, readonly) NSString* sha1Hash;


@end

/**@}*/
