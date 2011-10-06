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

#import "NIDOM.h"

#import "NIStylesheet.h"
#import "NimbusCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIDOM


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_stylesheet);
  NI_RELEASE_SAFELY(_registeredViews);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)domWithStylesheet:(NIStylesheet *)stylesheet {
  return [[[self alloc] initWithStylesheet:stylesheet] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)domWithStylesheetPaths:(NSString *)stylesheetPath, ... {
  va_list ap;
  va_start(ap, stylesheetPath);

  NIStylesheet* compositeStylesheet = [[[NIStylesheet alloc] init] autorelease];

  while (nil != stylesheetPath) {
    NIDASSERT([stylesheetPath isKindOfClass:[NSString class]]);

    if ([stylesheetPath isKindOfClass:[NSString class]]) {
      NIStylesheet* stylesheet = [[NIStylesheet alloc] init];
      if ([stylesheet loadFromPath:stylesheetPath]) {
        [compositeStylesheet addStylesheet:stylesheet];
      }
      NI_RELEASE_SAFELY(stylesheet);
    }
    stylesheetPath = va_arg(ap, NSString*);
  }
  va_end(ap);

  return [[[self alloc] initWithStylesheet:compositeStylesheet] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStylesheet:(NIStylesheet *)stylesheet {
  if ((self = [super init])) {
    _stylesheet = [stylesheet retain];
    _registeredViews = [[NSMutableSet alloc] init];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Styling Views


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshStyleForView:(UIView *)view {
  
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)registerView:(UIView *)view {
  [_registeredViews addObject:view];
}

@end
