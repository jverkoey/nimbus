//
// Copyright 2012 Jeff Verkoeyen
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

#import "NIOpenAuthenticator.h"

/**
 * A SoundCloud OAuth 2.0 implementation.
 *
 * This provides support for authenticating against the SoundCloud API outlined here:
 * http://developers.soundcloud.com/docs
 *
 * <h1>Registering a SoundCloud Application</h1>
 *
 * To register a SoundCloud application for use with the Nimbus OAuth API, please follow the
 * following steps.
 *
 * 1) Create a SoundCloud account at http://soundcloud.com/
 * 2) Visit the developer apps page at http://soundcloud.com/you/apps
 * 3) Click "Register a new application"
 * 4) Provide a name for your application and click "Register"
 * 5) Ensure that OAuth 2 is selected and enter the following value in the Redirect URI input:
 *    <your application URL prefix>://oauth/soundcloud
 * 6) Click "Save app".
 * 7) Follow the generic directions for using the Nimbus OAuth API in your application. You will
 *    find your Client ID and Client Secret on the page where you edited your application's
 *    redirect URI.
 *
 *      @ingroup NimbusOAuth
 *      @class NISoundCloudOpenAuthenticator
 */
@interface NISoundCloudOpenAuthenticator : NIOpenAuthenticator
@end
