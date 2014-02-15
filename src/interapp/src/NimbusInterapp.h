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

/**
 * @defgroup NimbusInterapp Nimbus Interapp
 *
 * <div id="github" feature="interapp"></div>
 *
 * Nimbus' inter-application communication feature for interacting with other applications
 * installed on the device.
 *
 * Applications may define schemes that make it possible to open them from your own application
 * using <code>[[UIApplication sharedApplication] openURL:]</code>. There is no way to
 * ask an application which URLs it implements, so Interapp strives to provide a growing
 * set of implementations for known application interfaces.
 *
 * <h2>Minimum Requirements</h2>
 *
 * Required frameworks:
 *
 * - Foundation.framework
 * - UIKit.framework
 * - CoreLocation.framework
 *
 * Minimum Operating System: <b>iOS 4.0</b>
 *
 * Source located in <code>src/interapp/src</code>
 *
 *
 * <h2>When to Use Interapp</h2>
 *
 * Interapp is particularly useful if you would like to reuse functionality provided by other
 * applications. For example, imagine building an app for a client that would optionally
 * support tweeting messages. Instead of building Oath into your application, you
 * can simply check to see whether the Twitter app is installed and then launch it with a
 * pre-populated message. If the app is not installed, Interapp also makes it easy to launch
 * the App Store directly to the page where the app can be downloaded.
 *
 * Choosing to use Interapp over building functionality into your application is a definite
 * tradeoff. Keeping the user within the context of your application may be worth the extra
 * effort to communicate with the API or implement the functionality yourself. In this case
 * you may find it useful to use Interapp as a quick means of prototyping the eventual
 * functionality.
 *
 *
 * <h2>Examples</h2>
 *
 * <h3>Composing a Message in the Twitter App</h3>
 *
 * @code
 *  // Check whether the Twitter app is installed.
 *  if ([NIInterapp twitterIsInstalled]) {
 *    // Opens the Twitter app with the composer prepopulated with the following message.
 *    [NIInterapp twitterWithMessage:@"Playing with the Nimbus Interapp feature!"];
 *
 *  } else {
 *    // Optionally, we can open the App Store to the twitter page to download the app.
 *    [NIInterapp twitter];
 *  }
 * @endcode
 *
 *
 * <h3>Opening a Photo in Instagram</h3>
 *
 * @code
 *  NSString* filePath = ...;
 *  NSError* error = nil;
 *
 *  // Copies the image at filePath to a suitable location for being opened by Instagram.
 *  NSURL* fileUrl = [NIInterapp urlForInstagramImageAtFilePath:filePath error:&error];
 *
 *  // It's possible that copying the file might fail (if the image dimensions are
 *  // less than 612x612, for example).
 *  if (nil != fileUrl && nil == error) {
 *
 *    // Note: You must retain docController at some point here. Generally you would retain
 *    // a local copy of docController in your containing controller and then release the
 *    // docController as necessary.
 *    UIDocumentInteractionController* docController =
 *    [UIDocumentInteractionController interactionControllerWithURL:_fileUrl];
 *
 *    // Use the delegate methods to release the doc controller when the menu is dismissed.
 *    docController.delegate = self;
 *
 *    // Use any of the presentOpenIn* methods to present the menu from the correct location.
 *    [docController presentOpenInMenuFromRect: bounds
 *                                      inView: view
 *                                    animated: YES];
 *  }
 * @endcode
 */

#import "NimbusCore.h"
#import "NIInterapp.h"
