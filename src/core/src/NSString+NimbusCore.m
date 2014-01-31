//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "NSString+NimbusCore.h"

#import "NIFoundationMethods.h"
#import "NIPreprocessorMacros.h"

#import <UIKit/UIKit.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

NI_FIX_CATEGORY_BUG(NSStringNimbusCore)
/**
 * For manipulating NSStrings.
 */
@implementation NSString (NimbusCore)


/**
 * Calculates the height of this text given the font, max width, and line break mode.
 *
 * A convenience wrapper for sizeWithFont:constrainedToSize:lineBreakMode:
 */
// COV_NF_START
- (CGFloat)heightWithFont:(UIFont*)font
       constrainedToWidth:(CGFloat)width
            lineBreakMode:(NSLineBreakMode)lineBreakMode {
  return [self sizeWithFont:font
          constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
              lineBreakMode:lineBreakMode].height;
}
// COV_NF_END


/**
 * Parses a URL query string into a dictionary where the values are arrays.
 *
 * A query string is one that looks like &param1=value1&param2=value2...
 *
 * The resulting NSDictionary will contain keys for each parameter name present in the query.
 * The value for each key will be an NSArray which may be empty if the key is simply present
 * in the query. Otherwise each object in the array with be an NSString corresponding to a value
 * in the query for that parameter.
 */
- (NSDictionary*)queryContentsUsingEncoding:(NSStringEncoding)encoding {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:self];
  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 1 || kvPair.count == 2) {
      NSString* key = [[kvPair objectAtIndex:0]
                       stringByReplacingPercentEscapesUsingEncoding:encoding];
      NSMutableArray* values = [pairs objectForKey:key];
      if (nil == values) {
        values = [NSMutableArray array];
        [pairs setObject:values forKey:key];
      }
      if (kvPair.count == 1) {
        [values addObject:[NSNull null]];

      } else if (kvPair.count == 2) {
        NSString* value = [[kvPair objectAtIndex:1]
                           stringByReplacingPercentEscapesUsingEncoding:encoding];
        [values addObject:value];
      }
    }
  }
  return [NSDictionary dictionaryWithDictionary:pairs];
}

/**
 * Returns a string that has been escaped for use as a URL parameter.
 */
- (NSString *)stringByAddingPercentEscapesForURLParameter {
  
  CFStringRef buffer = 
  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                          (__bridge CFStringRef)self,
                                          NULL,
                                          (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                          kCFStringEncodingUTF8);
  
  NSString *result = [NSString stringWithString:(__bridge NSString *)buffer];
  
  CFRelease(buffer);
  
  return result;
}

/**
 * Parses a URL, adds query parameters to its query, and re-encodes it as a new URL.
 */
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = [[query objectForKey:key] stringByAddingPercentEscapesForURLParameter];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }

  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([self rangeOfString:@"?"].location == NSNotFound) {
    return [self stringByAppendingFormat:@"?%@", params];

  } else {
    return [self stringByAppendingFormat:@"&%@", params];
  }
}

/**
 * Calculate the md5 hash using CC_MD5.
 *
 * @returns md5 hash of this string.
 */
- (NSString*)md5Hash {
  return NIMD5HashFromData([self dataUsingEncoding:NSUTF8StringEncoding]);
}

/**
 * Calculate the SHA1 hash using CommonCrypto CC_SHA1.
 *
 * @returns SHA1 hash of this string.
 */
- (NSString*)sha1Hash {
  return NISHA1HashFromData([self dataUsingEncoding:NSUTF8StringEncoding]);
}

@end
