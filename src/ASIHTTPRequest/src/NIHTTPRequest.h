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

#import "ASIHTTPRequest.h"

/**
 * An implementation of ASIHTTPRequest that uses the core network activity features in Nimbus.
 *
 * ASIHTTPRequest sometimes leaves the network activity indicator in a permanent "on" state.
 * Instead of modifying ASIHTTPRequest to use Nimbus' core network activity features, this
 * class may be used in place of ASIHTTPRequest to ensure correct integration with Nimbus.
 *
 * This has the most obvious benefit of allowing us to update ASIHTTPRequest without any
 * merging hassles. This also allows you to add this class to your own project if you already
 * have ASIHTTPRequest included.
 */
@interface NIHTTPRequest : ASIHTTPRequest {
@private
  // Used internally to avoid double-calling the network indicator start/stop methods.
  BOOL _didStartNetworkRequest;
}

@end
