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

#import "NIRunApp.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIRunApp


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)stringByEscapingParameterString:(NSString *)parameter {
  return [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)parameter,
                                                              NULL,
                                                              (CFStringRef)@";/?:@&=+$,",
                                                              kCFStringEncodingUTF8)
          autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)sanitizedPhoneNumberFromString:(NSString *)string {
  if (nil == string) {
    return nil;
  }

  NSCharacterSet* validCharacters =
  [NSCharacterSet characterSetWithCharactersInString:@"1234567890-+"];
  return [[string componentsSeparatedByCharactersInSet:[validCharacters invertedSet]]
          componentsJoinedByString:@""];

}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Safari


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)safariWithURL:(NSURL *)url {
  return [[UIApplication sharedApplication] openURL:url];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Google Maps

/**
 * Source for URL information: http://mapki.com/wiki/Google_Map_Parameters
 */


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)googleMapAtLocation:(CLLocationCoordinate2D)location {
  NSString* urlPath = [NSString stringWithFormat:
                       @"http://maps.google.com/maps?q=%f,%f",
                       location.latitude, location.longitude];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)googleMapAtLocation: (CLLocationCoordinate2D)location
                      title: (NSString *)title {
  NSString* urlPath = [NSString stringWithFormat:
                       @"http://maps.google.com/maps?q=%@@%f,%f",
                       [self stringByEscapingParameterString:title], location.latitude, location.longitude];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)googleMapDirectionsFromLocation: (CLLocationCoordinate2D)fromLocation
                             toLocation: (CLLocationCoordinate2D)toLocation {
  NSString* urlPath = [NSString stringWithFormat:
                       @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
                       fromLocation.latitude, fromLocation.longitude,
                       toLocation.latitude, toLocation.longitude];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)googleMapWithQuery:(NSString *)query {
  NSString* urlPath = [NSString stringWithFormat:
                       @"http://maps.google.com/maps?q=%@",
                       [self stringByEscapingParameterString:query]];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Phone


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)phone {
  return [self phoneWithNumber:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)phoneWithNumber:(NSString *)phoneNumber {
  phoneNumber = [self sanitizedPhoneNumberFromString:phoneNumber];

  NSString* urlPath = [@"tel:" stringByAppendingString:phoneNumber];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Texting


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)sms {
  return [self smsWithNumber:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)smsWithNumber:(NSString *)phoneNumber {
  phoneNumber = [self sanitizedPhoneNumberFromString:phoneNumber];
  
  NSString* urlPath = [@"sms:" stringByAppendingString:phoneNumber];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Mail

static NSString* const sMailScheme = @"mailto:";


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)mailWithInvocation:(NIMailAppInvocation *)invocation {
  NSString* urlPath = sMailScheme;
  if (NIIsStringWithAnyText(invocation.recipient)) {
    urlPath = [urlPath stringByAppendingString:[self stringByEscapingParameterString:
                                                invocation.recipient]];
  }
  NSMutableArray* parameters = [NSMutableArray array];
  if (NIIsStringWithAnyText(invocation.cc)) {
    [parameters addObject:[@"cc=" stringByAppendingString:[self stringByEscapingParameterString:invocation.cc]]];
  }
  if (NIIsStringWithAnyText(invocation.bcc)) {
    [parameters addObject:[@"bcc=" stringByAppendingString:[self stringByEscapingParameterString:invocation.bcc]]];
  }
  if (NIIsStringWithAnyText(invocation.subject)) {
    [parameters addObject:[@"subject=" stringByAppendingString:[self stringByEscapingParameterString:invocation.subject]]];
  }
  if (NIIsStringWithAnyText(invocation.body)) {
    [parameters addObject:[@"body=" stringByAppendingString:[self stringByEscapingParameterString:invocation.body]]];
  }
  if ([parameters count] > 0) {
    urlPath = [urlPath stringByAppendingFormat:@"?%@", [parameters componentsJoinedByString:@"&"]];
  }
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark YouTube


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)youTubeWithVideoId:(NSString *)videoId {
  NSString* urlPath = [@"http://www.youtube.com/watch?v=" stringByAppendingString:videoId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark iBooks

static NSString* const sIBooksScheme = @"itms-books:";


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)iBooksIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sIBooksScheme]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)iBooks {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sIBooksScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self iBooksAppStoreId]];
  }

  return didOpen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)iBooksAppStoreId {
  return @"364709193";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook

static NSString* const sFacebookScheme = @"fb:";


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)facebookIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sFacebookScheme]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)facebook {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sFacebookScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self facebookAppStoreId]];
  }
  
  return didOpen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)facebookProfileWithId:(NSString *)profileId {
  NSString* urlPath = [sFacebookScheme stringByAppendingFormat:@"//profile/%@", profileId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)facebookAppStoreId {
  return @"284882215";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Twitter

static NSString* const sTwitterScheme = @"twitter:";


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)twitterIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sTwitterScheme]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)twitter {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sTwitterScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self twitterAppStoreId]];
  }
  
  return didOpen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)twitterWithMessage:(NSString *)message {
  NSString* urlPath = [sTwitterScheme stringByAppendingFormat:@"//post?message=%@",
                       [self stringByEscapingParameterString:message]];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)twitterProfileForUsername:(NSString *)username {
  NSString* urlPath = [sTwitterScheme stringByAppendingFormat:@"//user?screen_name=%@",
                       [self stringByEscapingParameterString:username]];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)twitterAppStoreId {
  return @"333903271";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Instagram

static NSString* const sInstagramScheme = @"instagram:";


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)instagramIsInstalled {
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:sInstagramScheme]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)instagram {
  BOOL didOpen = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sInstagramScheme]];

  if (!didOpen) {
    didOpen = [self appStoreWithAppId:[self instagramAppStoreId]];
  }

  return didOpen;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)instagramCamera {
  NSString* urlPath = [sInstagramScheme stringByAppendingString:@"//camera"];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)instagramProfileForUsername:(NSString *)username {
  NSString* urlPath = [sInstagramScheme stringByAppendingFormat:@"//user?username=%@",
                       [self stringByEscapingParameterString:username]];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)instagramAppStoreId {
  return @"389801252";
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark App Store


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)appStoreWithAppId:(NSString *)appId {
  NSString* urlPath = [@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=" stringByAppendingString:appId];
  return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlPath]];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIMailAppInvocation

@synthesize recipient = _recipient;
@synthesize cc = _cc;
@synthesize bcc = _bcc;
@synthesize subject = _subject;
@synthesize body = _body;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_recipient);
  NI_RELEASE_SAFELY(_cc);
  NI_RELEASE_SAFELY(_bcc);
  NI_RELEASE_SAFELY(_subject);
  NI_RELEASE_SAFELY(_body);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)invocation {
  return [[[[self class] alloc] init] autorelease];
}


@end
