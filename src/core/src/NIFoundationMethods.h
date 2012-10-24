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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPreprocessorMacros.h"

#if defined __cplusplus
extern "C" {
#endif

/**
 * For filling in gaps in Apple's Foundation framework.
 *
 * @ingroup NimbusCore
 * @defgroup Foundation-Methods Foundation Methods
 * @{
 *
 * Utility methods save time and headache. You've probably written dozens of your own. Nimbus
 * hopes to provide an ever-growing set of convenience methods that compliment the Foundation
 * framework's functionality.
 */

#pragma mark -
#pragma mark CGRect Methods

/**
 * For manipulating CGRects.
 *
 * @defgroup CGRect-Methods CGRect Methods
 * @{
 *
 * These methods provide additional means of modifying the edges of CGRects beyond the basics
 * included in CoreGraphics.
 */

/**
 * Modifies only the right and bottom edges of a CGRect.
 *
 *      @return a CGRect with dx and dy subtracted from the width and height.
 *
 *      Example result: CGRectMake(x, y, w - dx, h - dy)
 */
CGRect NIRectContract(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Modifies only the right and bottom edges of a CGRect.
 *
 *      @return a CGRect with dx and dy added to the width and height.
 *
 *      Example result: CGRectMake(x, y, w + dx, h + dy)
 */
CGRect NIRectExpand(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Modifies only the top and left edges of a CGRect.
 *
 *      @return a CGRect whose origin has been offset by dx, dy, and whose size has been
 *              contracted by dx, dy.
 *
 *      Example result: CGRectMake(x + dx, y + dy, w - dx, h - dy)
 */
CGRect NIRectShift(CGRect rect, CGFloat dx, CGFloat dy);

/**
 * Returns a rect that will center viewToCenter within containerView.
 *
 *      @return a CGPoint that will center viewToCenter within containerView.
 */
CGRect NIFrameOfCenteredViewWithinView(UIView* viewToCenter, UIView* containerView);

/**
 * Returns the size of the string with given UILabel properties.
 */
CGSize NISizeOfStringWithLabelProperties(NSString *string, CGSize constrainedToSize, UIFont *font, UILineBreakMode lineBreakMode, NSInteger numberOfLines);

/**@}*/


#pragma mark -
#pragma mark NSRange Methods

/**
 * For manipulating NSRange.
 *
 * @defgroup NSRange-Methods NSRange Methods
 * @{
 */

/**
 * Create an NSRange object from a CFRange object.
 *
 *      @return an NSRange object with the same values as the CFRange object.
 *
 *      @attention This has the potential to behave unexpectedly because it converts the
 *                 CFRange's long values to unsigned integers. Nimbus will fire off a debug
 *                 assertion at runtime if the value will be chopped or the sign will change.
 *                 Even though the assertion will fire, the method will still chop or change
 *                 the sign of the values so you should take care to fix this.
 */
NSRange NIMakeNSRangeFromCFRange(CFRange range);

/**@}*/


#pragma mark -
#pragma mark NSData Methods

/**
 * For manipulating NSData.
 *
 * @defgroup NSData-Methods NSData Methods
 * @{
 */

/**
 * Calculates an md5 hash of the data using CC_MD5.
 */
NSString* NIMD5HashFromData(NSData* data);

/**
 * Calculates a sha1 hash of the data using CC_SHA1.
 */
NSString* NISHA1HashFromData(NSData* data);

/**@}*/


#pragma mark -
#pragma mark NSString Methods

/**
 * For manipulating NSStrings.
 *
 * @defgroup NSString-Methods NSString Methods
 * @{
 */

/**
 * Returns a Boolean value indicating whether the string is a NSString object that contains only
 * whitespace and newlines.
 */
BOOL NIIsStringWithWhitespaceAndNewlines(NSString* string);

/**@}*/


#pragma mark -
#pragma mark General Purpose Methods

/**
 * For general purpose foundation type manipulation.
 *
 * @defgroup General-Purpose-Methods General Purpose Methods
 * @{
 */

/**
 * Bounds a given value within the min and max values.
 *
 * If max < min then value will be min.
 *
 *      @returns min <= result <= max
 */
CGFloat boundf(CGFloat value, CGFloat min, CGFloat max);

/**
 * Bounds a given value within the min and max values.
 *
 * If max < min then value will be min.
 *
 *      @returns min <= result <= max
 */
NSInteger boundi(NSInteger value, NSInteger min, NSInteger max);

/**@}*/

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Foundation Methods ///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
