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

#import "NIInterapp.h"

#import "NimbusCore+Additions.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

// TODO: Make this a user default.
static BOOL sPreferGoogleChrome = NO;

@implementation NIInterapp

+ (NSString *)sanitizedPhoneNumberFromString:(NSString *)string {
  if (nil == string) {
    return nil;
  }

  NSCharacterSet* validCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890-+"];
  return [[string componentsSeparatedByCharactersInSet:[validCharacters invertedSet]]
          componentsJoinedByString:@""];
}

#pragma mark Chrome vs Safari

+ (void)setPreferGoogleChrome:(BOOL)preferGoogleChrome {
  sPreferGoogleChrome = preferGoogleChrome;
}

+ (BOOL)preferGoogleChrome {
  return sPreferGoogleChrome;
}

+ (BOOL)openPreferredBrowserWithURL:(NSURL *)url {
  if (sPreferGoogleChrome && [NIInterapp googleChromeIsInstalled]) {
    return [NIInterapp googleChromeWithURL:url];
  } else {
    return [NIInterapp safariWithURL:url];
  }
}

#pragma mark - Safari

+ (BOOL)safariWithURL:(NSURL *)url {
  return [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Google Chrome

/**
 * Based on https://developers.google.com/chrome/mobile/docs/ios-links
 */

static NSString* const sGoogleChromeHttpScheme = @"googlechrome:";
static NSString* const sGoogleChromeHttpsScheme = @"googlechromes:";

+ (BOOL)googleChromeIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sGoogleChromeHttpScheme]];
}

+ (BOOL)googleChromeWithURL:(NSURL *)url {
  NSString *chromeScheme = nil;
  if ([url.scheme isEqualToString:@"http"]) {
    chromeScheme = sGoogleChromeHttpScheme;
  } else if ([url.scheme isEqualToString:@"https"]) {
    chromeScheme = sGoogleChromeHttpsScheme;
  }

  if (chromeScheme) {
    NSRange rangeForScheme = [[url absoluteString] rangeOfString:@":"];
    NSString* urlNoScheme =  [[url absoluteString] substringFromIndex:rangeForScheme.location + 1];
    NSString* chromeUrlString = [chromeScheme stringByAppendingString:urlNoScheme];
    NSURL* chromeUrl = [NSURL URLWithString:chromeUrlString];

    BOOL didOpen = [[UIApplication sharedApplication] openURL:chromeUrl];
    if (!didOpen) {
      didOpen = [self appStoreWithAppId:[self googleChromeAppStoreId]];
    }

    return didOpen;
  }

  return NO;
}

+ (NSString *)googleChromeAppStoreId {
  return @"535886823";
}

#pragma mark - Google Maps

/**
 * Source for URL information: http://mapki.com/wiki/Google_Map_Parameters
 */

static NSString* const sGoogleMapsScheme = @"comgooglemaps:";

+ (BOOL)googleMapsIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sGoogleMapsScheme]];
}

+ (BOOL)googleMaps {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sGoogleMapsScheme]];
  
  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self googleMapsAppStoreId]];
  }
  
  return didOpen;
}

+ (NSString *)googleMapsAppStoreId {
  return @"585027354";
}

+ (BOOL)openBestGoogleMapUrl:(NSString*)urlString{
  if ([NIInterapp googleMapsIsInstalled]) {
    NSURL* url = [NSURL URLWithString:[@"comgooglemaps://" stringByAppendingString:urlString]];
    return [[UIApplication sharedApplication] openURL:url];
  } else {
    NSURL* url = [NSURL URLWithString:[@"http://maps.google.com/maps" stringByAppendingString:urlString]];
    return [NIInterapp openPreferredBrowserWithURL:url];
  }
}

+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location {
  NSString* urlPath = [NSString stringWithFormat:@"?q=%f,%f", location.latitude, location.longitude];
  return [NIInterapp openBestGoogleMapUrl:urlPath];
}

+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location title:(NSString *)title {
  NSString* urlPath = [NSString stringWithFormat:@"?q=%@@%f,%f",
                       NIStringByAddingPercentEscapesForURLParameterString(title),
                       location.latitude, location.longitude];
  return [NIInterapp openBestGoogleMapUrl:urlPath];

}

+ (BOOL)googleMapDirectionsFromLocation:(CLLocationCoordinate2D)fromLocation
                             toLocation:(CLLocationCoordinate2D)toLocation {
  return [NIInterapp googleMapDirectionsFromLocation:fromLocation toLocation:toLocation withMode:nil];
}

+ (BOOL)googleMapDirectionsFromLocation:(CLLocationCoordinate2D)fromLocation
                             toLocation:(CLLocationCoordinate2D)toLocation
                               withMode:(NSString *)directionsMode {
  NSString* saddr = [NSString stringWithFormat:@"%f,%f", fromLocation.latitude, fromLocation.longitude];
  NSString* daddr = [NSString stringWithFormat:@"%f,%f", toLocation.latitude, toLocation.longitude];

  return [NIInterapp googleMapDirectionsFromSourceAddress:saddr toDestAddress:daddr withMode:directionsMode];
}

+ (BOOL)googleMapDirectionsToLocation:(CLLocationCoordinate2D)toLocation
                             withMode:(NSString *)directionsMode {
  NSString* daddr = [NSString stringWithFormat:@"%f,%f", toLocation.latitude, toLocation.longitude];
  return [NIInterapp googleMapDirectionsFromSourceAddress:nil toDestAddress:daddr withMode:directionsMode];
}

+ (BOOL)googleMapDirectionsToDestAddress:(NSString *)destAddr withMode:(NSString *)directionsMode {
  return [NIInterapp googleMapDirectionsFromSourceAddress:nil toDestAddress:destAddr withMode:directionsMode];
}

+ (BOOL)googleMapDirectionsFromSourceAddress:(NSString *)srcAddr
                               toDestAddress:(NSString *)destAddr
                                    withMode:(NSString *)directionsMode {
  NSString* urlPath;
  // source can be left blank  == get current users location
  if (srcAddr.length > 0) {
    urlPath = [NSString stringWithFormat:@"?saddr=%@&daddr=%@", srcAddr, destAddr];
  } else {
    urlPath = [NSString stringWithFormat:@"?daddr=%@", destAddr];
  }
  if (directionsMode.length > 0) {
    urlPath = [NSString stringWithFormat:@"%@&directionsmode=%@", urlPath, directionsMode];
  }
  return [NIInterapp openBestGoogleMapUrl:urlPath];
}

+ (BOOL)googleMapWithQuery:(NSString *)query {
  NSString* urlPath = [NSString stringWithFormat:@"?q=%@", NIStringByAddingPercentEscapesForURLParameterString(query)];
  return [NIInterapp openBestGoogleMapUrl:urlPath];
}

#pragma mark - Phone

+ (BOOL)phone {
  return [self phoneWithNumber:nil];
}

+ (BOOL)phoneWithNumber:(NSString *)phoneNumber {
  phoneNumber = [self sanitizedPhoneNumberFromString:phoneNumber];

  if (nil == phoneNumber) {
    phoneNumber = @"";
  }

  NSString* urlPath = [@"tel:" stringByAppendingString:phoneNumber];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

#pragma mark - Texting

+ (BOOL)sms {
  return [self smsWithNumber:nil];
}

+ (BOOL)smsWithNumber:(NSString *)phoneNumber {
  phoneNumber = [self sanitizedPhoneNumberFromString:phoneNumber];

  if (nil == phoneNumber) {
    phoneNumber = @"";
  }

  NSString* urlPath = [@"sms:" stringByAppendingString:phoneNumber];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

#pragma mark - Mail

static NSString* const sMailScheme = @"mailto:";

+ (BOOL)mailWithInvocation:(NIMailAppInvocation *)invocation {
  NSMutableDictionary* parameters = [NSMutableDictionary dictionary];

  NSString* urlPath = sMailScheme;

  if (NIIsStringWithAnyText(invocation.recipient)) {
    urlPath = [urlPath stringByAppendingString:NIStringByAddingPercentEscapesForURLParameterString(invocation.recipient)];
  }

  if (NIIsStringWithAnyText(invocation.cc)) {
    [parameters setObject:invocation.cc forKey:@"cc"];
  }
  if (NIIsStringWithAnyText(invocation.bcc)) {
    [parameters setObject:invocation.bcc forKey:@"bcc"];
  }
  if (NIIsStringWithAnyText(invocation.subject)) {
    [parameters setObject:invocation.subject forKey:@"subject"];
  }
  if (NIIsStringWithAnyText(invocation.body)) {
    [parameters setObject:invocation.body forKey:@"body"];
  }

  urlPath = NIStringByAddingQueryDictionaryToString(urlPath, parameters);

  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

#pragma mark - YouTube

+ (BOOL)youTubeWithVideoId:(NSString *)videoId {
  NSString* urlPath = [@"http://www.youtube.com/watch?v=" stringByAppendingString:videoId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

#pragma mark - iBooks

static NSString* const sIBooksScheme = @"itms-books:";

+ (BOOL)iBooksIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sIBooksScheme]];
}

+ (BOOL)iBooks {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sIBooksScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self iBooksAppStoreId]];
  }

  return didOpen;
}

+ (NSString *)iBooksAppStoreId {
  return @"364709193";
}

#pragma mark - Facebook

static NSString* const sFacebookScheme = @"fb:";

+ (BOOL)facebookIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sFacebookScheme]];
}

+ (BOOL)facebook {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sFacebookScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self facebookAppStoreId]];
  }
  
  return didOpen;
}

+ (BOOL)facebookProfileWithId:(NSString *)profileId {
  NSString* urlPath = [sFacebookScheme stringByAppendingFormat:@"//profile/%@", profileId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (NSString *)facebookAppStoreId {
  return @"284882215";
}

#pragma mark - Twitter

static NSString* const sTwitterScheme = @"twitter:";

+ (BOOL)twitterIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sTwitterScheme]];
}

+ (BOOL)twitter {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sTwitterScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self twitterAppStoreId]];
  }
  
  return didOpen;
}

+ (BOOL)twitterWithMessage:(NSString *)message {
  NSString* urlPath = [sTwitterScheme stringByAppendingFormat:@"//post?message=%@",
                       NIStringByAddingPercentEscapesForURLParameterString(message)];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (BOOL)twitterProfileForUsername:(NSString *)username {
  NSString* urlPath = [sTwitterScheme stringByAppendingFormat:@"//user?screen_name=%@",
                       NIStringByAddingPercentEscapesForURLParameterString(username)];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (NSString *)twitterAppStoreId {
  return @"333903271";
}

#pragma mark - Application

+ (BOOL)applicationIsInstalledWithScheme:(NSString *)applicationScheme {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:applicationScheme]];
}

+ (BOOL)applicationWithScheme:(NSString *)applicationScheme {
    return [self applicationWithScheme:applicationScheme
                            appStoreId:nil
                               andPath:nil];
}

+ (BOOL)applicationWithScheme:(NSString *)applicationScheme
                andAppStoreId:(NSString *)appStoreId {
    return [self applicationWithScheme:applicationScheme
                            appStoreId:appStoreId
                               andPath:nil];
}

+ (BOOL)applicationWithScheme:(NSString *)applicationScheme
                      andPath:(NSString *)path {
    return [self applicationWithScheme:applicationScheme
                            appStoreId:nil
                               andPath:path];
}

+ (BOOL)applicationWithScheme:(NSString *)applicationScheme
                   appStoreId:(NSString *)appStoreId
                      andPath:(NSString *)path {
  BOOL didOpen = false;
  NSString* urlPath = applicationScheme;

  // Were we passed a path?
  if (path != nil) {
    // Generate the full application URL
    urlPath = [urlPath stringByAppendingFormat:@"%@", path];
  }

  // Try to open the application URL
  didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];

  // Didn't open and we have an appStoreId
  if (!didOpen && appStoreId != nil) {
    // Open the app store instead
    didOpen = [self appStoreWithAppId:appStoreId];
  }

  return didOpen;
}

#pragma mark - Instagram

static NSString* const sInstagramScheme = @"instagram:";

+ (BOOL)instagramIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sInstagramScheme]];
}

+ (BOOL)instagram {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sInstagramScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self instagramAppStoreId]];
  }

  return didOpen;
}

+ (BOOL)instagramCamera {
  NSString* urlPath = [sInstagramScheme stringByAppendingString:@"//camera"];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (BOOL)instagramProfileForUsername:(NSString *)username {
  NSString* urlPath = [sInstagramScheme stringByAppendingFormat:@"//user?username=%@",
                       NIStringByAddingPercentEscapesForURLParameterString(username)];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (NSURL *)urlForInstagramImageAtFilePath:(NSString *)filePath error:(NSError **)error {
  if (![self instagramIsInstalled]) {
    return nil;
  }

  UIImage* image = [[UIImage alloc] initWithContentsOfFile:filePath];

  // Unable to read the image.
  if (nil == image) {
    if (nil != error) {
      *error = [NSError errorWithDomain: NSCocoaErrorDomain
                                   code: NSFileReadUnknownError
                               userInfo: [NSDictionary dictionaryWithObject: filePath
                                                                     forKey: NSFilePathErrorKey]];
    }
    return nil;
  }

  // Instagram requires that images are at least 612x612 and preferably square.
  if (image.size.width < 612
      || image.size.height < 612) {
    if (nil != error) {
      *error = [NSError errorWithDomain: NINimbusErrorDomain
                                   code: NIImageTooSmall
                               userInfo: [NSDictionary dictionaryWithObject: image
                                                                     forKey: NIImageErrorKey]];
    }
    return nil;
  }

  NSFileManager* fm = [NSFileManager defaultManager];
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

  NIDASSERT(NIIsArrayWithObjects(paths));
  if (!NIIsArrayWithObjects(paths)) {
    return nil;
  }

  NSString* documentsPath = [paths objectAtIndex:0];
  NSString* destinationPath = [documentsPath stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"nimbus-instagram-image-%.0f.ig",
                                [NSDate timeIntervalSinceReferenceDate]]];

  [fm copyItemAtPath: filePath
              toPath: destinationPath
               error: error];

  NIDASSERT(nil == error || nil == *error);
  if (nil == error || nil == *error) {
    return [NSURL URLWithString:[@"file:" stringByAppendingString:destinationPath]];

  } else {
    return nil;
  }
}

+ (NSString *)instagramAppStoreId {
  return @"389801252";
}

#pragma mark - App Store

+ (BOOL)appStoreWithAppId:(NSString *)appId {
  NSString* urlPath = [@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=" stringByAppendingString:appId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (BOOL)appStoreGiftWithAppId:(NSString *)appId {
  NSString* urlPath = [NSString stringWithFormat:@"itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%@&productType=C&pricingParameter=STDQ&mt=8&ign-mscache=1", appId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

+ (BOOL)appStoreReviewWithAppId:(NSString *)appId {
  NSString* urlPath = [@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" stringByAppendingString:appId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}

@end

@implementation NIMailAppInvocation

+ (id)invocation {
  return [[[self class] alloc] init];
}

@end
