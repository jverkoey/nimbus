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

#import "RootViewController.h"

static const CGFloat kFramePadding = 10;
static const CGFloat kImageDimensions = 100;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  UIImage* initialImage = [UIImage imageWithContentsOfFile:
                           NIPathForBundleResource(nil, @"nimbus64x64.png")];

  _networkImageView = [[[NINetworkImageView alloc] initWithImage:initialImage] autorelease];
  _networkImageView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
  _networkImageView.contentMode = UIViewContentModeScaleAspectFit;
  _networkImageView.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin
                                        | UIViewAutoresizingFlexibleBottomMargin);

  _networkImageView.frame = CGRectMake(kFramePadding, kFramePadding,
                                       kImageDimensions,
                                       kImageDimensions);

  // From: http://www.flickr.com/photos/thonk25/3929945380/
  [_networkImageView setPathToNetworkImage:
   @"http://farm3.static.flickr.com/2484/3929945380_deef6f4962_z.jpg"];

  [self.view addSubview:_networkImageView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _networkImageView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


@end
