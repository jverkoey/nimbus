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

#import "NSData+NimbusCore.h"

#import "NIPreprocessorMacros.h"

#import <CommonCrypto/CommonDigest.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
NI_FIX_CATEGORY_BUG(NSDataNimbusCore)
/**
 * For hashing raw data.
 *
 * Turning NSData objects into hashes is a common operation when verifying downloaded
 * data and sending data over the wire.
 */
@implementation NSData (NimbusCore)


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Calculate an md5 hash using CC_MD5.
 *
 * @returns The md5 hash of this data.
 */
- (NSString *)md5Hash {
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5([self bytes], [self length], result);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15]
          ];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Calculate the SHA1 hash using CC_SHA1.
 *
 * @returns The SHA1 hash of this data.
 */
- (NSString *)sha1Hash {
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1([self bytes], [self length], result);

  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11], result[12], result[13], result[14],
          result[15], result[16], result[17], result[18], result[19]
          ];
}


@end

/**@}*/
