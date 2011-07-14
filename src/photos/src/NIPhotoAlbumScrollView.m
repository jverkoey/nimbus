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

#import "NIPhotoAlbumScrollView.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoAlbumScrollView

@synthesize loadingImage = _loadingImage;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pagingScrollView);
  NI_RELEASE_SAFELY(_loadingImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _pagingScrollView.pagingEnabled = YES;
    [self addSubview:_pagingScrollView];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadPhotoAtIndex: (NSInteger)photoIndex
                  photoSize: (NIPhotoScrollViewPhotoSize)photoSize {

}


@end
