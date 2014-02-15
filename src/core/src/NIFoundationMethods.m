//
// Copyright 2011-2014 NimbusKit
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

#import "NIFoundationMethods.h"

#import "NIDebuggingTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

#pragma mark - NSInvocation

NSInvocation* NIInvocationWithInstanceTarget(NSObject *targetObject, SEL selector) {
  NSMethodSignature* sig = [targetObject methodSignatureForSelector:selector];
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
  [inv setTarget:targetObject];
  [inv setSelector:selector];
  return inv;
}

NSInvocation* NIInvocationWithClassTarget(Class targetClass, SEL selector) {
  Method method = class_getInstanceMethod(targetClass, selector);
  struct objc_method_description* desc = method_getDescription(method);
  if (desc == NULL || desc->name == NULL)
    return nil;

  NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:desc->types];
  NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
  [inv setSelector:selector];
  return inv;
}

#pragma mark - CGRect

CGRect NIRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}

CGRect NIRectExpand(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + dx, rect.size.height + dy);
}

CGRect NIRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(NIRectContract(rect, dx, dy), dx, dy);
}

CGRect NIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets outsets) {
  return CGRectMake(rect.origin.x - outsets.left,
                    rect.origin.y - outsets.top,
                    rect.size.width + outsets.left + outsets.right,
                    rect.size.height + outsets.top + outsets.bottom);
}

CGFloat NICenterX(CGSize containerSize, CGSize size) {
  return NICGFloatFloor((containerSize.width - size.width) / 2.f);
}

CGFloat NICenterY(CGSize containerSize, CGSize size) {
  return NICGFloatFloor((containerSize.height - size.height) / 2.f);
}

CGRect NIFrameOfCenteredViewWithinView(UIView* viewToCenter, UIView* containerView) {
  CGPoint origin;
  CGSize containerViewSize = containerView.bounds.size;
  CGSize viewSize = viewToCenter.frame.size;
  origin.x = NICenterX(containerViewSize, viewSize);
  origin.y = NICenterY(containerViewSize, viewSize);
  return CGRectMake(origin.x, origin.y, viewSize.width, viewSize.height);
}

CGSize NISizeOfStringWithLabelProperties(NSString *string, CGSize constrainedToSize, UIFont *font, NSLineBreakMode lineBreakMode, NSInteger numberOfLines) {
  if (string.length == 0) {
    return CGSizeZero;
  }

  CGFloat lineHeight = font.lineHeight;
  CGSize size = CGSizeZero;

  if (numberOfLines == 1) {
    size = [string sizeWithFont:font forWidth:constrainedToSize.width lineBreakMode:lineBreakMode];

  } else {
    size = [string sizeWithFont:font constrainedToSize:constrainedToSize lineBreakMode:lineBreakMode];
    if (numberOfLines > 0) {
      size.height = MIN(size.height, numberOfLines * lineHeight);
    }
  }

  return size;
}

#pragma mark - NSRange

NSRange NIMakeNSRangeFromCFRange(CFRange range) {
  // CFRange stores its values in signed longs, but we're about to copy the values into
  // unsigned integers, let's check whether we're about to lose any information.
  NIDASSERT(range.location >= 0 && range.location <= NSIntegerMax);
  NIDASSERT(range.length >= 0 && range.length <= NSIntegerMax);
  return NSMakeRange(range.location, range.length);
}

#pragma mark - NSData

NSString* NIMD5HashFromData(NSData* data) {
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  bzero(result, sizeof(result));
  CC_MD5_CTX md5Context;
  CC_MD5_Init(&md5Context);
  size_t bytesHashed = 0;
  while (bytesHashed < [data length]) {
    CC_LONG updateSize = 1024 * 1024;
    if (([data length] - bytesHashed) < (size_t)updateSize) {
      updateSize = (CC_LONG)([data length] - bytesHashed);
    }
    CC_MD5_Update(&md5Context, (char *)[data bytes] + bytesHashed, updateSize);
    bytesHashed += updateSize;
  }
  CC_MD5_Final(result, &md5Context);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15]
          ];
}

NSString* NISHA1HashFromData(NSData* data) {
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  bzero(result, sizeof(result));
  CC_SHA1_CTX sha1Context;
  CC_SHA1_Init(&sha1Context);
  size_t bytesHashed = 0;
  while (bytesHashed < [data length]) {
    CC_LONG updateSize = 1024 * 1024;
    if (([data length] - bytesHashed) < (size_t)updateSize) {
      updateSize = (CC_LONG)([data length] - bytesHashed);
    }
    CC_SHA1_Update(&sha1Context, (char *)[data bytes] + bytesHashed, updateSize);
    bytesHashed += updateSize;
  }
  CC_SHA1_Final(result, &sha1Context);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15], result[16], result[17], result[18], result[19]
          ];
}

#pragma mark - NSString

NSString* NIMD5HashFromString(NSString* string) {
  return NIMD5HashFromData([string dataUsingEncoding:NSUTF8StringEncoding]);
}

NSString* NISHA1HashFromString(NSString* string) {
  return NISHA1HashFromData([string dataUsingEncoding:NSUTF8StringEncoding]);
}

BOOL NIIsStringWithWhitespaceAndNewlines(NSString* string) {
  NSCharacterSet* notWhitespaceAndNewlines = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
  return [string isKindOfClass:[NSString class]] && [string rangeOfCharacterFromSet:notWhitespaceAndNewlines].length == 0;
}

NSComparisonResult NICompareVersionStrings(NSString* string1, NSString* string2) {
  NSArray *oneComponents = [string1 componentsSeparatedByString:@"a"];
  NSArray *twoComponents = [string2 componentsSeparatedByString:@"a"];

  // The parts before the "a"
  NSString *oneMain = [oneComponents objectAtIndex:0];
  NSString *twoMain = [twoComponents objectAtIndex:0];

  // If main parts are different, return that result, regardless of alpha part
  NSComparisonResult mainDiff;
  if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
    return mainDiff;
  }

  // At this point the main parts are the same; just deal with alpha stuff
  // If one has an alpha part and the other doesn't, the one without is newer
  if ([oneComponents count] < [twoComponents count]) {
    return NSOrderedDescending;

  } else if ([oneComponents count] > [twoComponents count]) {
    return NSOrderedAscending;

  } else if ([oneComponents count] == 1) {
    // Neither has an alpha part, and we know the main parts are the same
    return NSOrderedSame;
  }

  // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
  // numerically. If it's not a valid number (including empty string) it's treated as zero.
  NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
  NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
  return [oneAlpha compare:twoAlpha];
}

NSDictionary* NIQueryDictionaryFromStringUsingEncoding(NSString* string, NSStringEncoding encoding) {
  NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
  NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:string];

  while (![scanner isAtEnd]) {
    NSString* pairString = nil;
    [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
    [scanner scanCharactersFromSet:delimiterSet intoString:NULL];

    NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
    if (kvPair.count == 1 || kvPair.count == 2) {
      NSString* key = [kvPair[0] stringByReplacingPercentEscapesUsingEncoding:encoding];

      NSMutableArray* values = pairs[key];
      if (nil == values) {
        values = [NSMutableArray array];
        pairs[key] = values;
      }

      if (kvPair.count == 1) {
        [values addObject:[NSNull null]];

      } else if (kvPair.count == 2) {
        NSString* value = [kvPair[1] stringByReplacingPercentEscapesUsingEncoding:encoding];
        [values addObject:value];
      }
    }
  }
  return [pairs copy];
}

NSString* NIStringByAddingPercentEscapesForURLParameterString(NSString* parameter) {
  CFStringRef buffer = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                               (__bridge CFStringRef)parameter,
                                                               NULL,
                                                               (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);

  NSString* result = [NSString stringWithString:(__bridge NSString *)buffer];
  CFRelease(buffer);
  return result;
}

NSString* NIStringByAddingQueryDictionaryToString(NSString* string, NSDictionary* query) {
  NSMutableArray* pairs = [NSMutableArray array];
  for (NSString* key in [query keyEnumerator]) {
    NSString* value = NIStringByAddingPercentEscapesForURLParameterString([query objectForKey:key]);
    NSString* pair = [NSString stringWithFormat:@"%@=%@", key, value];
    [pairs addObject:pair];
  }

  NSString* params = [pairs componentsJoinedByString:@"&"];
  if ([string rangeOfString:@"?"].location == NSNotFound) {
    return [string stringByAppendingFormat:@"?%@", params];

  } else {
    return [string stringByAppendingFormat:@"&%@", params];
  }
}

#pragma mark - General Purpose

// Deprecated.
CGFloat boundf(CGFloat value, CGFloat min, CGFloat max) {
  return NIBoundf(value, min, max);
}

// Deprecated.
NSInteger boundi(NSInteger value, NSInteger min, NSInteger max) {
  return NIBoundi(value, min, max);
}

CGFloat NIBoundf(CGFloat value, CGFloat min, CGFloat max) {
  if (max < min) {
    max = min;
  }
  CGFloat bounded = value;
  if (bounded > max) {
    bounded = max;
  }
  if (bounded < min) {
    bounded = min;
  }
  return bounded;
}

NSInteger NIBoundi(NSInteger value, NSInteger min, NSInteger max) {
  if (max < min) {
    max = min;
  }
  NSInteger bounded = value;
  if (bounded > max) {
    bounded = max;
  }
  if (bounded < min) {
    bounded = min;
  }
  return bounded;
}
