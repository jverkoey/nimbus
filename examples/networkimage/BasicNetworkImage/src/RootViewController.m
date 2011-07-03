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
static const CGFloat kImageDimensions = 93;
static const CGFloat kImageSpacing = 10;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NINetworkImageView *)networkImageView {
  UIImage* initialImage = [UIImage imageWithContentsOfFile:
                           NIPathForBundleResource(nil, @"nimbus64x64.png")];

  NINetworkImageView* networkImageView = [[[NINetworkImageView alloc] initWithImage:initialImage]
                                          autorelease];
  networkImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.3 alpha:1];

  return networkImageView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutImageViewsForOrientation:(UIInterfaceOrientation)orientation {
  CGRect frame = self.view.bounds;

  CGFloat maxRightEdge = 0;
  CGFloat currentX = kFramePadding;
  CGFloat currentY = kFramePadding;
  for (NINetworkImageView* imageView in _networkImageViews) {
    imageView.frame = CGRectMake(currentX, currentY, kImageDimensions, kImageDimensions);

    maxRightEdge = MAX(maxRightEdge, currentX + kImageDimensions);

    currentX += kImageDimensions + kImageSpacing;

    if (currentX + kImageDimensions >= frame.size.width - kFramePadding) {
      currentX = kFramePadding;
      currentY += kImageDimensions + kImageSpacing;
    }
  }

  CGFloat contentWidth = (maxRightEdge + kFramePadding);
  CGFloat contentPadding = floorf((frame.size.width - contentWidth) / 2);

  for (NINetworkImageView* imageView in _networkImageViews) {
    CGRect imageFrame = imageView.frame;
    imageFrame.origin.x += contentPadding;
    imageView.frame = imageFrame;
  }

  _scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                       currentY + kImageDimensions+ kFramePadding);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _networkImageViews = [[NSMutableArray alloc] init];

  _scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
  _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight);

  for (NSInteger ix = UIViewContentModeScaleToFill; ix <= UIViewContentModeBottomRight; ++ix) {
    NINetworkImageView* networkImageView = [self networkImageView];
    networkImageView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];

    networkImageView.contentMode = ix;

    // From: http://www.flickr.com/photos/thonk25/3929945380/
    [networkImageView setPathToNetworkImage:
     @"http://farm3.static.flickr.com/2484/3929945380_deef6f4962_z.jpg"
                             forDisplaySize: CGSizeMake(kImageDimensions, kImageDimensions)];

    [_scrollView addSubview:networkImageView];
    [_networkImageViews addObject:networkImageView];
  }

  [self.view addSubview:_scrollView];

  [self layoutImageViewsForOrientation:NIInterfaceOrientation()];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  NI_RELEASE_SAFELY(_networkImageViews);
  _scrollView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation)toInterfaceOrientation
                                         duration: (NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                          duration: duration];
  [self layoutImageViewsForOrientation:toInterfaceOrientation];
}


@end
