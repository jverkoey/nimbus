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
 * @brief Nimbus' Core library contains many often used utilities.
 * @defgroup NimbusCore Nimbus Core
 * @{
 *
 * The Nimbus Core sets the foundation for all of Nimbus' other libraries. By establishing a
 * strong base of helpful utility methods and debugging tools, the rest of the libraries can
 * benefit from this code reuse and decreased time spent re-inventing the wheel.
 *
 * In your own projects, consider familiarizing yourself with Nimbus by first adding the
 * Core and feeling your way around. For existing projects this is especially recommended
 * because it allows you to gradually introduce concepts found within Nimbus.
 */

#pragma mark -
#pragma mark Debugging Tools

/**
 * @brief Tools for inspecting code and writing to logs in debug builds.
 * @defgroup Debugging-Tools Debugging Tools
 * @{
 *
 * Provided in this header are a set of debugging methods and macros. Nearly all of the methods
 * found within this header will only do anything interesting if the DEBUG macro is defined.
 * The recommended way to enable the debug tools is to specify DEBUG in the "Preprocessor Macros"
 * field in your application's Debug target settings. Be careful not to set this for your release
 * or app store builds.
 *
 * @code
 * NIDASSERT(statement);
 * @endcode
 *
 * If statement is false, the statement will be written to the log and if you are running in
 * the simulator with a debugger attached, the app will break on the assertion line.
 *
 * @code
 * NIDPRINT(@"formatted log text %d", param1);
 * @endcode
 *
 * Print the given formatted text to the log.
 *
 * @code
 * NIDPRINTMETHODNAME();
 * @endcode
 *
 * Print the current method name to the log.
 *
 * @code
 * NIDCONDITIONLOG(statement, @"formatted log text %d", param1);
 * @endcode
 *
 * If statement is true, then the formatted text will be written to the log.
 *
 * @code
 * NIDINFO/NIDWARNING/NIDERROR(@"formatted log text %d", param1);
 * @endcode
 *
 * Will only write the formatted text to the log if NIMaxLogLevel is greater than the respective
 * NID* method's log level. See below for log levels.
 *
 * The default maximum log level is NILOGLEVEL_WARNING.
 */

#define NILOGLEVEL_INFO     5
#define NILOGLEVEL_WARNING  3
#define NILOGLEVEL_ERROR    1

/**
 * @brief The maximum log level to output for Nimbus debug logs.
 *
 * This value may be changed at run-time if you so desire.
 *
 * The default value is NILOGLEVEL_WARNING.
 */
extern NSInteger NIMaxLogLevel;

/**
 * @brief Only writes to the log when DEBUG is defined.
 *
 * This log method will always write to the log, regardless of log levels. It is used by all
 * of the other logging methods in Nimbus' debugging library.
 */
#ifdef DEBUG
#define NIDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NIDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

/**
 * @brief Write the containing method's name to the log using NIDPRINT.
 */
#define NIDPRINTMETHODNAME() NIDPRINT(@"%s", __PRETTY_FUNCTION__)

/**
 * @brief Assertions that only fire when DEBUG is defined.
 *
 * An assertion is like a programmatic breakpoint. Use it for sanity checks to save headache while
 * writing your code.
 */
#ifdef DEBUG

#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR
int NIIsInDebugger();
// We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
// a "breakInDebugger" function.
#define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); \
if (NIIsInDebugger()) { __asm__("int $3\n" : : ); }; } \
} ((void)0)
#else
#define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); } } ((void)0)
#endif // #if TARGET_IPHONE_SIMULATOR

#else
#define NIDASSERT(xx) ((void)0)
#endif // #ifdef DEBUG

#ifdef DEBUG
#define NIDCONDITIONLOG(condition, xx, ...) { if ((condition)) { NIDPRINT(xx, ##__VA_ARGS__); } \
} ((void)0)
#else
#define NIDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG


#pragma mark Level-Based Loggers

/**
 * @name Level-Based Loggers
 * @{
 */

/**
 * @brief Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_ERROR.
 */
#define NIDERROR(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_ERROR <= NIMaxLogLevel), xx, ##__VA_ARGS__)

/**
 * @brief Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_WARNING.
 */
#define NIDWARNING(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_WARNING <= NIMaxLogLevel), \
                                             xx, ##__VA_ARGS__)

/**
 * @brief Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_INFO.
 */
#define NIDINFO(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_INFO <= NIMaxLogLevel), xx, ##__VA_ARGS__)

/**@}*/// End of Level-Based Loggers


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Debugging-Tools //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Non-Retaining Collections

/**
 * @brief Collections that don't retain their objects.
 * @defgroup Non-Retaining-Collections Non-Retaining Collections
 * @{
 *
 * Non-retaining collections have historically been used when we needed more than one delegate
 * in an object. However, NSNotificationCenter is a much better solution for n > 1 delegates.
 * Using a non-retaining collection is dangerous, so if you must use one, use it with extreme care.
 * The danger primarily lies in the fact that by all appearances the collection should still
 * operate like a regular collection, so this might lead to a lot of developer error if the
 * developer assumes that the collection does, in fact, retain the object.
 */

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 *
 * Typically used with arrays of delegates.
 */
NSMutableArray* NICreateNonRetainingArray();


/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 *
 * Typically used with dictionaries of delegates.
 */
NSMutableDictionary* NICreateNonRetainingDictionary();

/**
 * Creates a mutable set which does not retain references to the values it contains.
 *
 * Typically used with sets of delegates.
 */
NSMutableSet* NICreateNonRetainingSet();


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Non-Retaining Collections ////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Non-Empty Collection Testing

/**
 * @brief Test whether a collection is of a certain type and is non-empty.
 * @defgroup Non-Empty-Collection-Testing Non-Empty Collection Testing
 * @{
 *
 * Simply calling -count on an object may not yield the expected results when enumerating it if
 * certain assumptions are also made about the object's type. For example, if a JSON response
 * returns a dictionary when you expected an array, casting the result to an NSArray and
 * calling count will yield a positive value, but objectAtIndex: will crash the application.
 * These methods provide a safer check for non-emptiness of collections.
 */

/**
 * @brief Tests if an object is a non-nil array which is not empty.
 */
BOOL NIIsArrayWithObjects(id object);

/**
 * @brief Tests if an object is a non-nil set which is not empty.
 */
BOOL NIIsSetWithObjects(id object);

/**
 * @brief Tests if an object is a non-nil string which is not empty.
 */
BOOL NIIsStringWithAnyText(id object);


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Non-Empty Collection Testing /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark Runtime Class Modifications

/**
 * @brief Modifying class implementations at runtime.
 * @defgroup Runtime-Class-Modifications Runtime Class Modifications
 * @{
 */

/**
 * @brief Swap the two method implementations on the given class.
 *
 * Uses method_exchangeImplementations to accomplish this.
 */
void NISwapMethods(Class cls, SEL originalSel, SEL newSel);


///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Runtime Class Modifications //////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


/**@}*/
