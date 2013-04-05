//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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
#import <UIKit/UIKit.h>

// Documentation for these additions is found in the .m file.
@interface NSString (NimbusCore)

#pragma mark Display

- (CGFloat)heightWithFont: (UIFont*)font
       constrainedToWidth: (CGFloat)width
            lineBreakMode: (NSLineBreakMode)lineBreakMode;

#pragma mark URL queries

- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)stringByAddingPercentEscapesForURLParameter;
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;

#pragma mark Versions

- (NSComparisonResult)versionStringCompare:(NSString *)other;

#pragma mark Hashing

@property (nonatomic, readonly) NSString* md5Hash;
@property (nonatomic, readonly) NSString* sha1Hash;

@end
