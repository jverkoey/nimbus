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
#import <CoreLocation/CoreLocation.h>

@class NIMailAppInvocation;

/**
 * An interface for interacting with other apps installed on the device.
 *
 *      @ingroup NimbusInterapp
 */
@interface NIInterapp : NSObject

#pragma mark Safari /** @name Safari **/

/**
 * Opens the given URL in Safari.
 */
+ (BOOL)safariWithURL:(NSURL *)url;


#pragma mark Google Maps /** @name Google Maps **/

/**
 * Opens Google Maps at the given location.
 */
+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location;

/**
 * Opens Google Maps at the given location with a title.
 */
+ (BOOL)googleMapAtLocation: (CLLocationCoordinate2D)location
                      title: (NSString *)title;

/**
 * Opens Google Maps with directions from one location to another.
 */
+ (BOOL)googleMapDirectionsFromLocation: (CLLocationCoordinate2D)fromLocation
                             toLocation: (CLLocationCoordinate2D)toLocation;

/**
 * Opens Google Maps with a generic query.
 */
+ (BOOL)googleMapWithQuery:(NSString *)query;


#pragma mark Phone /** @name Phone **/

/**
 * Opens the phone app.
 */
+ (BOOL)phone;

/**
 * Make a phone call with the given number.
 */
+ (BOOL)phoneWithNumber:(NSString *)phoneNumber;


#pragma mark SMS /** @name SMS **/

/**
 * Opens the phone app.
 */
+ (BOOL)sms;

/**
 * Start texting the given number.
 */
+ (BOOL)smsWithNumber:(NSString *)phoneNumber;


#pragma mark Mail /** @name Mail **/

/**
 * Opens mail with the given invocation properties.
 */
+ (BOOL)mailWithInvocation:(NIMailAppInvocation *)invocation;


#pragma mark YouTube /** @name YouTube **/

/**
 * Opens the YouTube video with the given video id.
 */
+ (BOOL)youTubeWithVideoId:(NSString *)videoId;


#pragma mark iBooks /** @name iBooks **/

/**
 * Returns YES if the iBooks application is installed.
 */
+ (BOOL)iBooksIsInstalled;

/**
 * Opens the iBooks application. If the iBooks application is not installed, will open the
 * App Store to the iBooks download page.
 */
+ (BOOL)iBooks;

/**
 * The iBooks App Store ID.
 */
+ (NSString *)iBooksAppStoreId;


#pragma mark Facebook /** @name Facebook **/

/**
 * Returns YES if the Facebook application is installed.
 */
+ (BOOL)facebookIsInstalled;

/**
 * Opens the Facebook application. If the Facebook application is not installed, will open the
 * App Store to the Facebook download page.
 */
+ (BOOL)facebook;

/**
 * Opens the Facebook profile with the given id.
 */
+ (BOOL)facebookProfileWithId:(NSString *)profileId;

/**
 * The Facebook App Store ID.
 */
+ (NSString *)facebookAppStoreId;


#pragma mark Twitter /** @name Twitter **/

/**
 * Returns YES if the Twitter application is installed.
 */
+ (BOOL)twitterIsInstalled;

/**
 * Opens the Twitter application. If the Twitter application is not installed, will open the
 * App Store to the Twitter download page.
 */
+ (BOOL)twitter;

/**
 * Begins composing a message.
 */
+ (BOOL)twitterWithMessage:(NSString *)message;

/**
 * Opens the profile for the given username.
 */
+ (BOOL)twitterProfileForUsername:(NSString *)username;

/**
 * The Twitter App Store ID.
 */
+ (NSString *)twitterAppStoreId;


#pragma mark Instagram /** @name Instagram **/
// http://instagram.com/developer/iphone-hooks/

/**
 * Returns YES if the Instagram application is installed.
 */
+ (BOOL)instagramIsInstalled;

/**
 * Opens the Instagram application. If the Instagram application is not installed, will open the
 * App Store to the Instagram download page.
 */
+ (BOOL)instagram;

/**
 * Opens the Instagram camera.
 */
+ (BOOL)instagramCamera;

/**
 * Opens the profile for the given username.
 */
+ (BOOL)instagramProfileForUsername:(NSString *)username;

/**
 * Copies an image to a temporary path suitable for use with a UIDocumentInteractionController in
 * order to open the image in Instagram.
 *
 * The image at filePath must be at least 612x612 and preferably square. If the image
 * is smaller than 612x612 then this method will fail.
 */
+ (NSURL *)urlForInstagramImageAtFilePath:(NSString *)filePath error:(NSError **)error;

/**
 * The Instagram App Store ID.
 */
+ (NSString *)instagramAppStoreId;



#pragma mark App Store /** @name App Store **/

/**
 * Opens the App Store page for the app with the given ID.
 */
+ (BOOL)appStoreWithAppId:(NSString *)appId;

@end

@interface NIMailAppInvocation : NSObject {
@private
  NSString* _recipient;
  NSString* _cc;
  NSString* _bcc;
  NSString* _subject;
  NSString* _body;
}

@property (nonatomic, readwrite, copy) NSString* recipient;
@property (nonatomic, readwrite, copy) NSString* cc;
@property (nonatomic, readwrite, copy) NSString* bcc;
@property (nonatomic, readwrite, copy) NSString* subject;
@property (nonatomic, readwrite, copy) NSString* body;

/**
 * Creates an autoreleased invocation object.
 */
+ (id)invocation;

@end
