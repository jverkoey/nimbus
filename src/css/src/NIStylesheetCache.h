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

#import <Foundation/Foundation.h>

@class NIStylesheet;

/**
 * A simple in-memory cache for stylesheets.
 *
 * @ingroup NimbusCSS
 *
 * It is recommended that you use this object to store stylesheets in a centralized location.
 * Ideally you would have one stylesheet cache throughout the lifetime of your application.
 *
 *
 * <h2>Using a stylesheet cache with Chameleon</h2>
 *
 * A stylesheet cache must be used with the Chameleon observer so that changes can be sent
 * for a given stylesheet. This is because changes are sent using the stylesheet object as
 * the notification object, so a listener must register notifications with the stylesheet as
 * the object.
 *
@code
NIStylesheet* stylesheet = [stylesheetCache stylesheetWithPath:@"common.css"];
NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
[nc addObserver:self
       selector:@selector(stylesheetDidChange)
           name:NIStylesheetDidChangeNotification
         object:stylesheet];
@endcode
 */
@interface NIStylesheetCache : NSObject {
@private
  NSMutableDictionary* _pathToStylesheet;
  NSString* _pathPrefix;
}

@property (nonatomic, readonly, copy) NSString* pathPrefix;

// Designated initializer.
- (id)initWithPathPrefix:(NSString *)pathPrefix;

- (NIStylesheet *)stylesheetWithPath:(NSString *)path loadFromDisk:(BOOL)loadFromDisk;
- (NIStylesheet *)stylesheetWithPath:(NSString *)path;

@end

/**
 * The path prefix that will be used to load stylesheets.
 *
 * @fn NIStylesheetCache::pathPrefix
 */

/**
 * Initializes a newly allocated stylesheet cache with a given path prefix.
 *
 * @fn NIStylesheetCache::initWithPathPrefix:
 */

/**
 * Fetches a stylesheet from the in-memory cache if it exists or loads the stylesheet from disk if
 * loadFromDisk is YES.
 *
 * @fn NIStylesheetCache::stylesheetWithPath:loadFromDisk:
 */

/**
 * Fetches a stylesheet from the in-memory cache if it exists or loads the stylesheet from disk.
 *
 * Short form for calling [cache stylesheetWithPath:path loadFromDisk:YES]
 *
 * @fn NIStylesheetCache::stylesheetWithPath:
 */
