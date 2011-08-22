//
// Copyright 2011 Jeff Verkoeyen
//
// Forked from Three20 June 10, 2011 - Copyright 2009-2011 Facebook
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

#import "NILauncherViewController.h"

#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherItemDetails

@synthesize title     = _title;
@synthesize imagePath = _imagePath;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_title);
  NI_RELEASE_SAFELY(_imagePath);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title imagePath:(NSString *)imagePath {
  if ((self = [super init])) {
    _title = [title copy];
    _imagePath = [imagePath copy];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)itemDetailsWithTitle:(NSString *)title imagePath:(NSString *)imagePath {
  return [[[NILauncherItemDetails alloc] initWithTitle: title
                                             imagePath: imagePath]
          autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [self initWithTitle:nil imagePath:nil])) {
    self.title = [decoder decodeObjectForKey:@"title"];
    self.imagePath = [decoder decodeObjectForKey:@"imagePath"];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.title forKey:@"title"];
  [encoder encodeObject:self.imagePath forKey:@"imagePath"];
}


@end
