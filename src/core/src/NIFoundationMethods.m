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

#import "NIFoundationMethods.h"

#import "NIDebuggingTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CGRect Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIRectContract(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - dx, rect.size.height - dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIRectExpand(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + dx, rect.size.height + dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIRectShift(CGRect rect, CGFloat dx, CGFloat dy) {
  return CGRectOffset(NIRectContract(rect, dx, dy), dx, dy);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets outsets) {
  return CGRectMake(rect.origin.x - outsets.left,
                    rect.origin.y - outsets.top,
                    rect.size.width + outsets.left + outsets.right,
                    rect.size.height + outsets.top + outsets.bottom);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat NICenterX(CGSize containerSize, CGSize size) {
  return floorf((containerSize.width - size.width) / 2.f);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat NICenterY(CGSize containerSize, CGSize size) {
  return floorf((containerSize.height - size.height) / 2.f);
}


/////////////////////////////////////////////////////////////////////////////////////////////
CGRect NIFrameOfCenteredViewWithinView(UIView* viewToCenter, UIView* containerView) {
  CGPoint origin;
  CGSize containerViewSize = containerView.bounds.size;
  CGSize viewSize = viewToCenter.frame.size;
  origin.x = NICenterX(containerViewSize, viewSize);
  origin.y = NICenterY(containerViewSize, viewSize);
  return CGRectMake(origin.x, origin.y, viewSize.width, viewSize.height);
}


/////////////////////////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSRange Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
NSRange NIMakeNSRangeFromCFRange(CFRange range) {
  // CFRange stores its values in signed longs, but we're about to copy the values into
  // unsigned integers, let's check whether we're about to lose any information.
  NIDASSERT(range.location >= 0 && range.location <= NSIntegerMax);
  NIDASSERT(range.length >= 0 && range.length <= NSIntegerMax);
  return NSMakeRange(range.location, range.length);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSData Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* NIMD5HashFromData(NSData* data) {
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5(data.bytes, data.length, result);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15]
          ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* NISHA1HashFromData(NSData* data) {
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, data.length, result);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15], result[16], result[17], result[18], result[19]
          ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSString Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL NIIsStringWithWhitespaceAndNewlines(NSString* string) {
  NSCharacterSet* notWhitespaceAndNewlines = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
  return [string isKindOfClass:[NSString class]] && [string rangeOfCharacterFromSet:notWhitespaceAndNewlines].length == 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General Purpose Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat boundf(CGFloat value, CGFloat min, CGFloat max) {
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


///////////////////////////////////////////////////////////////////////////////////////////////////
NSInteger boundi(NSInteger value, NSInteger min, NSInteger max) {
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

///////////////////////////////////////////////////////////////////////////////////////////////////
// Inspired by https://gist.github.com/atomicbird/1592634
// Created by Tom Harrington on 12/29/11.
///////////////////////////////////////////////////////////////////////////////////////////////////
void NISetValuesForKeys(NSObject *target, NSDictionary* keyedValues, NSDateFormatter *dateFormatter) {
  unsigned int propertyCount;
	objc_property_t *properties = class_copyPropertyList([target class], &propertyCount);
	
  NSMutableSet *unusedValueKeys = [[NSMutableSet alloc] initWithArray:keyedValues.allKeys];
  
	/*
	 This code iterates over self's properties instead of ivars because the backing ivar might have a different name
	 than the property, for example if the class includes something like:
	 
	 @synthesize foo = foo_;
	 
	 In this case what we really want is "foo", not "foo_", since the incoming keys in keyedValues probably
	 don't have the underscore. Looking through properties gets "foo", looking through ivars gets "foo_".
	 */
	for (int i=0; i<propertyCount; i++) {
		objc_property_t property = properties[i];
		const char *propertyName = property_getName(property);
		NSString *keyName = [NSString stringWithUTF8String:propertyName];
		
		id value = [keyedValues objectForKey:keyName];
		if (value != nil) {
      [unusedValueKeys removeObject:keyName];
			char *typeEncoding = NULL;
			typeEncoding = property_copyAttributeValue(property, "T");
			
			if (typeEncoding == NULL) {
				continue;
			}
			switch (typeEncoding[0]) {
				case '@':
				{
					// Object
					Class class = nil;
					if (strlen(typeEncoding) >= 3) {
						char *className = strndup(typeEncoding+2, strlen(typeEncoding)-3);
						class = NSClassFromString([NSString stringWithUTF8String:className]);
						free(className);
					}
					// Check for type mismatch, attempt to compensate
					if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
						value = [value stringValue];
					} else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
						// If the ivar is an NSNumber we really can't tell if it's intended as an integer, float, etc.
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
						value = [numberFormatter numberFromString:value];
					} else if ([class isSubclassOfClass:[NSDate class]] && [value isKindOfClass:[NSString class]] && (dateFormatter != nil)) {
						value = [dateFormatter dateFromString:value];
					}
					
					break;
				}
					
				case 'i': // int
				case 's': // short
				case 'l': // long
				case 'q': // long long
				case 'I': // unsigned int
				case 'S': // unsigned short
				case 'L': // unsigned long
				case 'Q': // unsigned long long
				case 'f': // float
				case 'd': // double
				case 'B': // BOOL
				{
					if ([value isKindOfClass:[NSString class]]) {
						NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
						[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
						value = [numberFormatter numberFromString:value];
					}
					break;
				}
					
				case 'c': // char
				case 'C': // unsigned char
				{
					if ([value isKindOfClass:[NSString class]]) {
						char firstCharacter = [value characterAtIndex:0];
						value = [NSNumber numberWithChar:firstCharacter];
					}
					break;
				}
					
				default:
				{
					break;
				}
			}
			[target setValue:value forKey:keyName];
			free(typeEncoding);
		}
	}
	free(properties);
  if ([unusedValueKeys count]) {
    for (NSString *key in unusedValueKeys) {
      @try {
        [target setValue:[keyedValues objectForKey:key] forUndefinedKey:key];
      }
      @catch (NSException *exception) {
      }
    }
  }
}
