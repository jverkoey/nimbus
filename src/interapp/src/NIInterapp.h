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
#import <CoreLocation/CoreLocation.h>

@class NIMailAppInvocation;

/**
 * An interface for interacting with other apps installed on the device.
 *
 * @ingroup NimbusInterapp
 */
@interface NIInterapp : NSObject

#pragma mark Chrome vs Safari

+ (void)setPreferGoogleChrome:(BOOL)preferGoogleChromeOverSafari;
+ (BOOL)preferGoogleChrome;
+ (BOOL)openPreferredBrowserWithURL:(NSURL *)url;

#pragma mark Safari

+ (BOOL)safariWithURL:(NSURL *)url;

#pragma mark Google Chrome

+ (BOOL)googleChromeIsInstalled;
+ (BOOL)googleChromeWithURL:(NSURL *)url;
+ (NSString *)googleChromeAppStoreId;

#pragma mark Google Maps

+ (BOOL)googleMapsIsInstalled;
+ (BOOL)googleMaps;
+ (NSString *)googleMapsAppStoreId;

+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location;
+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location title:(NSString *)title;
+ (BOOL)googleMapDirectionsFromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation;

// directionsMode can be nil. @"driving", @"transit", or @"walking".
+ (BOOL)googleMapDirectionsFromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation withMode:(NSString*)directionsMode;
+ (BOOL)googleMapDirectionsFromSourceAddress:(NSString *)srcAddr toDestAddress:(NSString *)destAddr withMode:(NSString *)directionsMode;

// these just use the user's current location (even if your application doesn't have locations services on, the google maps site/app MIGHT
+ (BOOL)googleMapDirectionsToDestAddress:(NSString *)destAddr withMode:(NSString *)directionsMode;
+ (BOOL)googleMapDirectionsToLocation:(CLLocationCoordinate2D)toLocation withMode:(NSString *)directionsMode;

+ (BOOL)googleMapWithQuery:(NSString *)query;

#pragma mark Phone

+ (BOOL)phone;
+ (BOOL)phoneWithNumber:(NSString *)phoneNumber;

#pragma mark SMS

+ (BOOL)sms;
+ (BOOL)smsWithNumber:(NSString *)phoneNumber;

#pragma mark Mail

+ (BOOL)mailWithInvocation:(NIMailAppInvocation *)invocation;

#pragma mark YouTube

+ (BOOL)youTubeWithVideoId:(NSString *)videoId;

#pragma mark App Store

+ (BOOL)appStoreWithAppId:(NSString *)appId;
+ (BOOL)appStoreGiftWithAppId:(NSString *)appId;
+ (BOOL)appStoreReviewWithAppId:(NSString *)appId;

#pragma mark iBooks

+ (BOOL)iBooksIsInstalled;
+ (BOOL)iBooks;
+ (NSString *)iBooksAppStoreId;

#pragma mark Facebook

+ (BOOL)facebookIsInstalled;
+ (BOOL)facebook;
+ (BOOL)facebookProfileWithId:(NSString *)profileId;
+ (NSString *)facebookAppStoreId;

#pragma mark Twitter

+ (BOOL)twitterIsInstalled;
+ (BOOL)twitter;
+ (BOOL)twitterWithMessage:(NSString *)message;
+ (BOOL)twitterProfileForUsername:(NSString *)username;
+ (NSString *)twitterAppStoreId;

#pragma mark Instagram

+ (BOOL)instagramIsInstalled;
+ (BOOL)instagram;
+ (BOOL)instagramCamera;
+ (BOOL)instagramProfileForUsername:(NSString *)username;
+ (NSURL *)urlForInstagramImageAtFilePath:(NSString *)filePath error:(NSError **)error;
+ (NSString *)instagramAppStoreId;

#pragma mark Custom Application

+ (BOOL)applicationIsInstalledWithScheme:(NSString *)applicationScheme;
+ (BOOL)applicationWithScheme:(NSString *)applicationScheme;
+ (BOOL)applicationWithScheme:(NSString *)applicationScheme andAppStoreId:(NSString *)appStoreId;
+ (BOOL)applicationWithScheme:(NSString *)applicationScheme andPath:(NSString *)path;
+ (BOOL)applicationWithScheme:(NSString *)applicationScheme appStoreId:(NSString *)appStoreId andPath:(NSString *)path;

@end

@interface NIMailAppInvocation : NSObject {
@private
  NSString* _recipient;
  NSString* _cc;
  NSString* _bcc;
  NSString* _subject;
  NSString* _body;
}

@property (nonatomic, copy) NSString* recipient;
@property (nonatomic, copy) NSString* cc;
@property (nonatomic, copy) NSString* bcc;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSString* body;

/**
 * Returns an autoreleased invocation object.
 */
+ (id)invocation;

@end

/** @name Safari **/

/**
 * Opens the given URL in Safari.
 *
 * @fn NIInterapp::safariWithURL:
 */


/** @name Google Chrome **/

/**
 * Returns YES if the Google Chrome application is installed.
 *
 * @fn NIInterapp::googleChromeIsInstalled
 */

/**
 * Opens the given URL in Google Chrome if installed on the device.
 *
 * @fn NIINterapp::googleChromeWithURL:
 */

/**
 * The Google Chrome App Store ID.
 *
 * @fn NIInterapp::googleChromeAppStoreId
 */


/** @name Google Maps **/

/**
 * Opens Google Maps at the given location.
 *
 * @fn NIInterapp::googleMapAtLocation:
 */

/**
 * Opens Google Maps at the given location with a title.
 *
 * @fn NIInterapp::googleMapAtLocation:title:
 */

/**
 * Opens Google Maps with directions from one location to another.
 *
 * @fn NIInterapp::googleMapDirectionsFromLocation:toLocation:
 */

/**
 * Opens Google Maps with a generic query.
 *
 * @fn NIInterapp::googleMapWithQuery:
 */


/** @name Phone **/

/**
 * Opens the phone app.
 *
 * @fn NIInterapp::phone
 */

/**
 * Make a phone call with the given number.
 *
 * @fn NIInterapp::phoneWithNumber:
 */


/** @name SMS **/

/**
 * Opens the phone app.
 *
 * @fn NIInterapp::sms
 */

/**
 * Start texting the given number.
 *
 * @fn NIInterapp::smsWithNumber:
 */


/** @name Mail **/

/**
 * Opens mail with the given invocation properties.
 *
 * @fn NIInterapp::mailWithInvocation:
 */


/** @name YouTube **/

/**
 * Opens the YouTube video with the given video id.
 *
 * @fn NIInterapp::youTubeWithVideoId:
 */


/** @name iBooks **/

/**
 * Returns YES if the iBooks application is installed.
 *
 * @fn NIInterapp::iBooksIsInstalled
 */

/**
 * Opens the iBooks application. If the iBooks application is not installed, will open the
 * App Store to the iBooks download page.
 *
 * @fn NIInterapp::iBooks
 */

/**
 * The iBooks App Store ID.
 *
 * @fn NIInterapp::iBooksAppStoreId
 */


/** @name Facebook **/

/**
 * Returns YES if the Facebook application is installed.
 *
 * @fn NIInterapp::facebookIsInstalled
 */

/**
 * Opens the Facebook application. If the Facebook application is not installed, will open the
 * App Store to the Facebook download page.
 *
 * @fn NIInterapp::facebook
 */

/**
 * Opens the Facebook profile with the given id.
 *
 * @fn NIInterapp::facebookProfileWithId:
 */

/**
 * The Facebook App Store ID.
 *
 * @fn NIInterapp::facebookAppStoreId
 */


/** @name Twitter **/

/**
 * Returns YES if the Twitter application is installed.
 *
 * @fn NIInterapp::twitterIsInstalled
 */

/**
 * Opens the Twitter application. If the Twitter application is not installed, will open the
 * App Store to the Twitter download page.
 *
 * @fn NIInterapp::twitter
 */

/**
 * Begins composing a message.
 *
 * @fn NIInterapp::twitterWithMessage:
 */

/**
 * Opens the profile for the given username.
 *
 * @fn NIInterapp::twitterProfileForUsername:
 */

/**
 * The Twitter App Store ID.
 *
 * @fn NIInterapp::twitterAppStoreId
 */


/** @name Custom Application **/

/**
 * Returns YES if the supplied application is installed.
 *
 * @fn NIInterapp::applicationIsInstalledWithScheme:
 */

/**
 * Opens the supplied application.
 *
 * @fn NIInterapp::applicationWithScheme
 */

/**
 * Opens the supplied application. If the supplied application is not installed, will open the
 * App Store to the specified ID download page.
 *
 * @fn NIInterapp::applicationWithScheme:andAppStoreId:
 */

/**
 * Opens the supplied application.
 *
 * @fn NIInterapp::applicationWithScheme:andPath:
 */

/**
 * Opens the supplied application, to the specified path. If the supplied application is not installed, will open the
 * App Store to the download page for the specified AppStoreId.
 *
 * @fn NIInterapp::applicationWithScheme:appStoreId:andPath:
 */

/**
 * Opens the application with the supplied custom URL.
 *
 * @fn NIInterapp::applicationWithUrl:
 */


/** @name Instagram **/
// http://instagram.com/developer/iphone-hooks/

/**
 * Returns YES if the Instagram application is installed.
 *
 * @fn NIInterapp::instagramIsInstalled
 */

/**
 * Opens the Instagram application. If the Instagram application is not installed, will open the
 * App Store to the Instagram download page.
 *
 * @fn NIInterapp::instagram
 */

/**
 * Opens the Instagram camera.
 *
 * @fn NIInterapp::instagramCamera
 */

/**
 * Opens the profile for the given username.
 *
 * @fn NIInterapp::instagramProfileForUsername:
 */

/**
 * Copies an image to a temporary path suitable for use with a UIDocumentInteractionController in
 * order to open the image in Instagram.
 *
 * The image at filePath must be at least 612x612 and preferably square. If the image
 * is smaller than 612x612 then this method will fail.
 *
 * @fn NIInterapp::urlForInstagramImageAtFilePath:error:
 */

/**
 * The Instagram App Store ID.
 *
 * @fn NIInterapp::instagramAppStoreId
 */


/** @name App Store **/

/**
 * Opens the App Store page for the app with the given ID.
 *
 * @fn NIInterapp::appStoreWithAppId:
 */

/**
 * Opens the "Gift this app" App Store page for the app with the given ID.
 *
 * @fn NIInterapp::appStoreGiftWithAppId:
 */

/**
 * Opens the "Write a review" App Store page for the app with the given ID.
 *
 * @fn NIInterapp::appStoreReviewWithAppId:
 */
