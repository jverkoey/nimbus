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

/**
 * For inspecting code and writing to logs in debug builds.
 *
 * Nearly all of the following macros will only do anything if the DEBUG macro is defined.
 * The recommended way to enable the debug tools is to specify DEBUG in the "Preprocessor Macros"
 * field in your application's Debug target settings. Be careful not to set this for your release
 * or app store builds because this will enable code that may cause your app to be rejected.
 *
 *
 * <h2>Debug Assertions</h2>
 *
 * Debug assertions are a lightweight "sanity check". They won't crash the app, nor will they
 * be included in release builds. They <i>will</i> halt the app's execution when debugging so
 * that you can inspect the values that caused the failure.
 *
 * @code
 *  NIDASSERT(statement);
 * @endcode
 *
 * If <i>statement</i> is false, the statement will be written to the log and if a debugger is
 * attached, the app will break on the assertion line.
 *
 *
 * <h2>Debug Logging</h2>
 *
 * @code
 *  NIDPRINT(@"formatted log text %d", param1);
 * @endcode
 *
 * Print the given formatted text to the log.
 *
 * @code
 *  NIDPRINTMETHODNAME();
 * @endcode
 *
 * Print the current method name to the log.
 *
 * @code
 *  NIDCONDITIONLOG(statement, @"formatted log text %d", param1);
 * @endcode
 *
 * If statement is true, then the formatted text will be written to the log.
 *
 * @code
 *  NIDINFO/NIDWARNING/NIDERROR(@"formatted log text %d", param1);
 * @endcode
 *
 * Will only write the formatted text to the log if NIMaxLogLevel is greater than the respective
 * NID* method's log level. See below for log levels.
 *
 * The default maximum log level is NILOGLEVEL_WARNING.
 *
 * <h3>Turning up the log level while the app is running</h3>
 *
 * NIMaxLogLevel is declared a non-const extern so that you can modify it at runtime. This can
 * be helpful for turning logging on while the application is running.
 *
 * @code
 *  NIMaxLogLevel = NILOGLEVEL_INFO;
 * @endcode
 *
 *      @ingroup NimbusCore
 *      @defgroup Debugging-Tools Debugging Tools
 *      @{
 */

#if defined(DEBUG) || defined(NI_DEBUG)

/**
 * Assertions that only fire when DEBUG is defined.
 *
 * An assertion is like a programmatic breakpoint. Use it for sanity checks to save headache while
 * writing your code.
 */
#import <TargetConditionals.h>

#if defined __cplusplus
extern "C" {
#endif

int NIIsInDebugger(void);
#if TARGET_IPHONE_SIMULATOR
// We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
// a "breakInDebugger" function.
#define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); \
if (NIDebugAssertionsShouldBreak && NIIsInDebugger()) { __asm__("int $3\n" : : ); } } \
} ((void)0)
#else
#define NIDASSERT(xx) { if (!(xx)) { NIDPRINT(@"NIDASSERT failed: %s", #xx); \
if (NIDebugAssertionsShouldBreak && NIIsInDebugger()) { raise(SIGTRAP); } } \
} ((void)0)
#endif // #if TARGET_IPHONE_SIMULATOR

#else
#define NIDASSERT(xx) ((void)0)
#endif // #if defined(DEBUG) || defined(NI_DEBUG)


#define NILOGLEVEL_INFO     5
#define NILOGLEVEL_WARNING  3
#define NILOGLEVEL_ERROR    1

/**
 * The maximum log level to output for Nimbus debug logs.
 *
 * This value may be changed at run-time.
 *
 * The default value is NILOGLEVEL_WARNING.
 */
extern NSInteger NIMaxLogLevel;

/**
 * Whether or not debug assertions should halt program execution like a breakpoint when they fail.
 *
 * An example of when this is used is in unit tests, when failure cases are tested that will
 * fire debug assertions.
 *
 * The default value is YES.
 */
extern BOOL NIDebugAssertionsShouldBreak;

/**
 * Only writes to the log when DEBUG is defined.
 *
 * This log method will always write to the log, regardless of log levels. It is used by all
 * of the other logging methods in Nimbus' debugging library.
 */
#if defined(DEBUG) || defined(NI_DEBUG)
#define NIDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define NIDPRINT(xx, ...)  ((void)0)
#endif // #if defined(DEBUG) || defined(NI_DEBUG)

/**
 * Write the containing method's name to the log using NIDPRINT.
 */
#define NIDPRINTMETHODNAME() NIDPRINT(@"%s", __PRETTY_FUNCTION__)

#if defined(DEBUG) || defined(NI_DEBUG)
/**
 * Only writes to the log if condition is satisified.
 *
 * This macro powers the level-based loggers. It can also be used for conditionally enabling
 * families of logs.
 */
#define NIDCONDITIONLOG(condition, xx, ...) { if ((condition)) { NIDPRINT(xx, ##__VA_ARGS__); } \
} ((void)0)
#else
#define NIDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #if defined(DEBUG) || defined(NI_DEBUG)


/**
 * Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_ERROR.
 */
#define NIDERROR(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_ERROR <= NIMaxLogLevel), xx, ##__VA_ARGS__)

/**
 * Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_WARNING.
 */
#define NIDWARNING(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_WARNING <= NIMaxLogLevel), \
xx, ##__VA_ARGS__)

/**
 * Only writes to the log if NIMaxLogLevel >= NILOGLEVEL_INFO.
 */
#define NIDINFO(xx, ...)  NIDCONDITIONLOG((NILOGLEVEL_INFO <= NIMaxLogLevel), xx, ##__VA_ARGS__)

#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Debugging Tools //////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
