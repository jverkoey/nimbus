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

#import "NimbusCore.h"
#import "NICSSParser.h"

@class NIStylesheet;
@class NIStylesheetCache;

extern NSString* const NIJSONDidChangeNotification;
extern NSString* const NIJSONDidChangeFilePathKey;
extern NSString* const NIJSONDidChangeNameKey;

/**
 * An observer for the Chameleon server.
 *
 *      @ingroup NimbusCSS
 *
 * This observer connects to a Chameleon server and waits for changes in stylesheets. Once
 * a stylesheet change has been detected, the new stylesheet is retrieved from the server
 * and a notification is fired via NIStylesheetDidChangeNotification after the stylesheet
 * has been reloaded.
 *
 * Thanks to the use of NIOperations, the stylesheet loading and processing is accomplished
 * on a separate thread. This means that the UI will only be notified of stylesheet changes
 * once the request thread has successfully loaded and processed the changed stylesheet.
 */
@interface NIChameleonObserver : NSObject <NIOperationDelegate, NICSSParserDelegate> {
@private
  NIStylesheetCache* _stylesheetCache;
  NSMutableArray* _stylesheetPaths;
  NSOperationQueue* _queue;
  NSString* _host;
  NSInteger _retryCount;
}

// Designated initializer.
- (id)initWithStylesheetCache:(NIStylesheetCache *)stylesheetCache host:(NSString *)host;

- (NIStylesheet *)stylesheetForPath:(NSString *)path;

- (void)watchSkinChanges;

- (void)enableBonjourDiscovery: (NSString*) serviceName;

@end

/**
 * Initializes a newly allocated Chameleon observer with a given stylesheet cache and host.
 *
 *      @fn NIChameleonObserver::initWithStylesheetCache:host:
 */

/**
 * Returns a loaded stylesheet from the given path.
 *
 *      @fn NIChameleonObserver::stylesheetForPath:
 */

/**
 * Begins listening to the Chameleon server for changes.
 *
 * When changes are detected the Chameleon observer downloads the new CSS files, reloads them,
 * and then fires the appropriate notifications.
 *
 *      @fn NIChameleonObserver::watchSkinChanges
 */

/**
 * Browses Bonjour for services with the given name (e.g. your username) and sets the host
 * automatically.
 *
 *      @fn NIChameleonObserver::enableBonjourDiscovery:
 */
