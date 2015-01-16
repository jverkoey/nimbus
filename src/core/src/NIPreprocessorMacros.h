//
// Copyright 2011-2014 NimbusKit
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


#pragma mark - Preprocessor Macros

/**
 * Preprocessor macros are added to Nimbus with care. Macros hide functionality and are difficult
 * to debug, so most macros found in Nimbus are one-liners or compiler utilities.
 *
 * <h2>Creating Byte- and Hex-based Colors</h2>
 * 
 * Nimbus provides the RGBCOLOR and RGBACOLOR macros for easily creating UIColor objects
 * with byte and hex values.
 * 
 * <h3>Examples</h3>
 * 
@code
UIColor* color = RGBCOLOR(255, 128, 64); // Fully opaque orange
UIColor* color = RGBACOLOR(255, 128, 64, 0.5); // Orange with 50% transparency
UIColor* color = RGBCOLOR(0xFF, 0x7A, 0x64); // Hexadecimal color
@endcode
 * 
 * <h3>Why it exists</h3>
 * 
 * There is no easy way to create UIColor objects using 0 - 255 range values or hexadecimal. This
 * leads to code like this being written:
 * 
@code
UIColor* color = [UIColor colorWithRed:128.f/255.0f green:64.f/255.0f blue:32.f/255.0f alpha:1]
@endcode
 *
 * <h2>Avoid requiring the -all_load and -force_load flags</h2>
 * 
 * Categories can introduce the need for the -all_load and -force_load because of the fact that
 * the application will not load these categories on startup without them. This is due to the way
 * Xcode deals with .m files that only contain categories: it doesn't load them without the
 * -all_load or -force_load flag specified.
 * 
 * There is, however, a way to force Xcode into loading the category .m file. If you provide an
 * empty class implementation in the .m file then your app will pick up the category
 * implementation.
 * 
 * Example in plain UIKit:
 * 
@code
@interface BogusClass
@end
@implementation BogusClass
@end

@implementation UIViewController (MyCustomCategory)
...
@end
@endcode
 * 
 * NI_FIX_CATEGORY_BUG is a Nimbus macro that you include in your category `.m` file to save you
 * the trouble of having to write a bogus class for every category. Just be sure that the name you
 * provide to the macro is unique across your project or you will encounter duplicate symbol errors
 * when linking.
 * 
@code
NI_FIX_CATEGORY_BUG(UIViewController_MyCustomCategory);

@implementation UIViewController (MyCustomCategory)
...
@end
@endcode
 * 
 * @ingroup NimbusCore
 * @defgroup Preprocessor-Macros Preprocessor Macros
 * @{
 */

/**
 * Mark a method or property as deprecated to the compiler.
 *
 * Any use of a deprecated method or property will flag a warning when compiling.
 *
 * Borrowed from Apple's AvailabiltyInternal.h header.
 *
 * @htmlonly
 * <pre>
 *   __AVAILABILITY_INTERNAL_DEPRECATED         __attribute__((deprecated))
 * </pre>
 * @endhtmlonly
 */
#define __NI_DEPRECATED_METHOD __attribute__((deprecated))

/**
 * Mark APIs as unavailable in app extensions.
 *
 * Use of unavailable methods, classes, or functions produces a compile error when built as part
 * of an app extension target. If the method, class or function using the unavailable API has also
 * been marked as unavailable in app extensions, the error will be suppressed.
 */
#ifdef NS_EXTENSION_UNAVAILABLE_IOS
#define NI_EXTENSION_UNAVAILABLE_IOS(msg) NS_EXTENSION_UNAVAILABLE_IOS(msg)
#else
#define NI_EXTENSION_UNAVAILABLE_IOS(msg)
#endif

/**
 * Force a category to be loaded when an app starts up.
 *
 * Add this macro before each category implementation, so we don't have to use
 * -all_load or -force_load to load object files from static libraries that only contain
 * categories and no classes.
 * See http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html for more info.
 */
#define NI_FIX_CATEGORY_BUG(name) @interface NI_FIX_CATEGORY_BUG_##name : NSObject @end \
@implementation NI_FIX_CATEGORY_BUG_##name @end

/**
 * Creates an opaque UIColor object from a byte-value color definition.
 */
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

/**
 * Creates a UIColor object from a byte-value color definition and alpha transparency.
 */
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/**@}*/// End of Preprocessor Macros //////////////////////////////////////////////////////////////
