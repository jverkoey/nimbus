//
// Copyright 2011-2014 Jeff Verkoeyen
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

#pragma mark - NSInvocation Methods

/**
 * Construct an NSInvocation with an instance of an object and a selector
 *
 *  @return an NSInvocation that will call the given selector on the given target
 */
NSInvocation* NIInvocationWithInstanceTarget(NSObject* target, SEL selector);

/**
 * Construct an NSInvocation for a class method given a class object and a selector
 *
 *  @return an NSInvocation that will call the given class method/selector.
 */
NSInvocation* NIInvocationWithClassTarget(Class targetClass, SEL selector);

#pragma mark - CGRect Methods

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
 * Inverse of UIEdgeInsetsInsetRect.
 *
 *      Example result: CGRectMake(x - left, y - top,
 *                                 w + left + right, h + top + bottom)
 */
CGRect NIEdgeInsetsOutsetRect(CGRect rect, UIEdgeInsets outsets);

/**
 * Returns the x position that will center size within containerSize.
 *
 *      Example result: floorf((containerSize.width - size.width) / 2.f)
 */
CGFloat NICenterX(CGSize containerSize, CGSize size);

/**
 * Returns the y position that will center size within containerSize.
 *
 *      Example result: floorf((containerSize.height - size.height) / 2.f)
 */
CGFloat NICenterY(CGSize containerSize, CGSize size);

/**
 * Returns a rect that will center viewToCenter within containerView.
 *
 *      @return a CGPoint that will center viewToCenter within containerView.
 */
CGRect NIFrameOfCenteredViewWithinView(UIView* viewToCenter, UIView* containerView);

/**
 * Returns the size of the string with given UILabel properties.
 */
CGSize NISizeOfStringWithLabelProperties(NSString *string, CGSize constrainedToSize, UIFont *font, NSLineBreakMode lineBreakMode, NSInteger numberOfLines);

/**@}*/


#pragma mark - NSRange Methods

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


#pragma mark - NSData Methods

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


#pragma mark - NSString Methods

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

/**
 * Compares two strings expressing software versions.
 *
 * The comparison is (except for the development version provisions noted below) lexicographic
 * string comparison. So as long as the strings being compared use consistent version formats,
 * a variety of schemes are supported. For example "3.02" < "3.03" and "3.0.2" < "3.0.3". If you
 * mix such schemes, like trying to compare "3.02" and "3.0.3", the result may not be what you
 * expect.
 *
 * Development versions are also supported by adding an "a" character and more version info after
 * it. For example "3.0a1" or "3.01a4". The way these are handled is as follows: if the parts
 * before the "a" are different, the parts after the "a" are ignored. If the parts before the "a"
 * are identical, the result of the comparison is the result of NUMERICALLY comparing the parts
 * after the "a". If the part after the "a" is empty, it is treated as if it were "0". If one
 * string has an "a" and the other does not (e.g. "3.0" and "3.0a1") the one without the "a"
 * is newer.
 *
 * Examples (?? means undefined):
 * @htmlonly
 * <pre>
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 * </pre>
 * @endhtmlonly
 */
NSComparisonResult NICompareVersionStrings(NSString* string1, NSString* string2);

/**@}*/


#pragma mark - CGFloat Methods

/**
 * For manipulating CGFloat.
 *
 * @defgroup CGFloat-Methods CGFloat Methods
 * @{
 *
 * These methods provide math functions on CGFloats. They could easily be replaced with <tgmath.h>
 * but that is currently (Xcode 5.0) incompatible with CLANG_ENABLE_MODULES (on by default for
 * many projects/targets). We'll use CG_INLINE because this really should be completely inline.
 */


#ifdef CGFLOAT_IS_DOUBLE
  #define NI_CGFLOAT_EPSILON DBL_EPSILON
#else
  #define NI_CGFLOAT_EPSILON FLT_EPSILON
#endif

/**
 * fabs()/fabsf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatAbs(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)fabs(x);
#else
  return (CGFloat)fabsf(x);
#endif
}

/**
 * floor()/floorf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatFloor(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)floor(x);
#else
  return (CGFloat)floorf(x);
#endif
}

/**
 * ceil()/ceilf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatCeil(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)ceil(x);
#else
  return (CGFloat)ceilf(x);
#endif
}

/**
 * round()/roundf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatRound(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)round(x);
#else
  return (CGFloat)roundf(x);
#endif
}

/**
 * sqrt()/sqrtf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatSqRt(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)sqrt(x);
#else
  return (CGFloat)sqrtf(x);
#endif
}

/**
 * copysign()/copysignf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatCopySign(CGFloat x, CGFloat y) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)copysign(x, y);
#else
  return (CGFloat)copysignf(x, y);
#endif
}

/**
 * pow()/powf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatPow(CGFloat x, CGFloat y) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)pow(x, y);
#else
  return (CGFloat)powf(x, y);
#endif
}

/**
 * cos()/cosf() sized for CGFloat
 */
CG_INLINE CGFloat NICGFloatCos(CGFloat x) {
#ifdef CGFLOAT_IS_DOUBLE
  return (CGFloat)cos(x);
#else
  return (CGFloat)cosf(x);
#endif
}

/**@}*/

#pragma mark - General Purpose Methods

/**
 * For general purpose foundation type manipulation.
 *
 * @defgroup General-Purpose-Methods General Purpose Methods
 * @{
 */

/**
 * Deprecated method. Use NIBoundf instead.
 */
CGFloat boundf(CGFloat value, CGFloat min, CGFloat max) __NI_DEPRECATED_METHOD; // Use NIBoundf instead.

/**
 * Deprecated method. Use NIBoundi instead.
 */
NSInteger boundi(NSInteger value, NSInteger min, NSInteger max) __NI_DEPRECATED_METHOD; // Use NIBoundi instead.

/**
 * Bounds a given value within the min and max values.
 *
 * If max < min then value will be min.
 *
 *      @returns min <= result <= max
 */
CGFloat NIBoundf(CGFloat value, CGFloat min, CGFloat max);

/**
 * Bounds a given value within the min and max values.
 *
 * If max < min then value will be min.
 *
 *      @returns min <= result <= max
 */
NSInteger NIBoundi(NSInteger value, NSInteger min, NSInteger max);

/**@}*/

#if defined __cplusplus
};
#endif

/**@}*/// End of Foundation Methods ///////////////////////////////////////////////////////////////
