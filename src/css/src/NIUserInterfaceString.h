//
// Copyright 2011 Max Metral
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

/**
 * The notification key for when a strings file has changed.
 *
 *      @ingroup NimbusCSS
 *
 * This notification will be sent globally at the moment.
 *
 * The NSNotification userInfo object will contain the local disk path of the strings file.
 */
extern NSString* const NIStringsDidChangeNotification;
extern NSString* const NIStringsDidChangeFilePathKey;

/**
 * A very thin derivative of NSString that will track what user interface
 * elements it has been assigned to and watch for updates via Chameleon
 */
@class NIUserInterfaceString;

/**
 * A simple NSLocalizedString like macro to make it easier to use NIUserInterfaceStrings
 */
#define NILocalizedStringWithDefault(key,default) [[NIUserInterfaceString alloc] initWithKey: key defaultValue: default]
#define NILocalizedStringWithKey(key) [[NIUserInterfaceString alloc] initWithKey: key];

@protocol NIUserInterfaceStringResolver
@required
/**
 * The default resolver will just call NSLocalizedString, but also watch the notification center
 * for incoming updates from Chameleon
 */
-(NSString*)stringForKey: (NSString*) key withDefaultValue: (NSString*) value;
/**
 * Determine whether string change tracking is enabled or not. Since there
 * is some overhead to this, the default behavior is to return YES
 * if DEBUG is defined, and NO otherwise.
 */
-(BOOL)isChangeTrackingEnabled;
@end

/**
 * A very thin derivative of NSString that will track what user interface
 * elements it has been assigned to and watch for updates via Chameleon
 */
@interface NIUserInterfaceString : NSObject
@property (nonatomic,strong) NSString *string;
@property (nonatomic,strong) NSString *originalKey;

/**
 * The global resolver for strings by key
 */
+(id<NIUserInterfaceStringResolver>)stringResolver;
/**
 * Set the global resolver for strings by key
 */
+(void)setStringResolver:(id<NIUserInterfaceStringResolver>)stringResolver;

/**
 * Create a string with the given key using the resolver.
 */
-(id)initWithKey: (NSString*) key;

/**
* Create a string with the given key using the resolver and a default value if
* not found.
*/
-(id)initWithKey: (NSString*) key defaultValue: (NSString*) value;

/**
 * Attach a string to a user interface element. Any changes to the string will
 * be sent to the view until the view is dealloced or the string is detached.
 * This method uses setText if available, else setTitle or asserts.
 */
-(void)attach: (UIView*) view;

/**
 * Attach a string to an element via a selector. The selector must take
 * one argument.
 */
-(void)attach: (id) element withSelector: (SEL) selector;

/**
 * Attach a string to a user interface element that supports control states.
 * Any changes to the string will be sent to the view until the view is 
 * dealloced or the string is detached.
 */
-(void)attach: (UIView*) view withSelector: (SEL) selector forControlState: (UIControlState) state;

/**
 * Detach a string from a user interface element. This does not "unset"
 * the string value itself but it essentially stops tracking changes
 * and frees internal structures.
 */
-(void)detach: (UIView*) view;

/**
 * Attach a string to an element via a selector. The selector must take
 * one argument.
 */
-(void)detach: (id) element withSelector: (SEL) selector;

/**
 * Attach a string to an element via a selector. The selector must take
 * one argument.
 */
-(void)detach: (UIView*) element withSelector: (SEL) selector forControlState: (UIControlState) state;

@end
