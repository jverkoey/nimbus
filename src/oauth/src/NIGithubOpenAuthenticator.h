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
 * An Rdio OAuth 2.0 implementation.
 *
 * This provides support for authenticating against the Github API outlined here:
 * http://developer.github.com/v3/
 *
 * <h1>Registering a Github Application</h1>
 *
 * To register a Github application for use with the Nimbus OAuth API, please follow the
 * following steps.
 *
 * 1) Create a Github account at http://github.com/
 * 2) Create a new application at https://github.com/settings/applications/new
 * 4) Provide a name for your application and url for your application's website.
 * 5) Enter the following value in the Redirect URI input:
 *    <your application URL prefix>://oauth/github
 * 6) Click "Register application".
 * 7) Follow the generic directions for using the Nimbus OAuth API in your application. You will
 *    find your Client ID and Client Secret on your application's information page.
 *
 *      @ingroup NimbusOAuth
 *      @class NIGithubOpenAuthenticator
 */
@interface NIGithubOpenAuthenticator : NIOpenAuthenticator
@end
