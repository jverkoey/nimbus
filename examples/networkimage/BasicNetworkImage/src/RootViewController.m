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
static const CGFloat kTextBottomMargin = 10;
static const CGFloat kImageDimensions = 93;
static const CGFloat kImageSpacing = 10;


@interface RootViewController()
@property (nonatomic, readwrite, retain) UIScrollView* scrollView;
@property (nonatomic, readwrite, retain)NSMutableArray* networkImageViews;
@property (nonatomic, readwrite, retain)UILabel* memoryUsageLabel;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController

@synthesize scrollView = _scrollView;
@synthesize networkImageViews = _networkImageViews;
@synthesize memoryUsageLabel = _memoryUsageLabel;


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @returns an autoreleased network image view.
 */
- (NINetworkImageView *)networkImageView {
  UIImage* initialImage = [UIImage imageWithContentsOfFile:
                           NIPathForBundleResource(nil, @"nimbus64x64.png")];

  NINetworkImageView* networkImageView = [[NINetworkImageView alloc] initWithImage:initialImage];
  networkImageView.delegate = self;
  networkImageView.contentMode = UIViewContentModeCenter;

  // Try playing with the following scale options and turning off clips to bounds to
  // see the effects on the result image.
  //networkImageView.scaleOptions = (NINetworkImageViewScaleToFillLeavesExcess
  //                                 | NINetworkImageViewScaleToFitCropsExcess);
  //networkImageView.clipsToBounds = NO;

  networkImageView.backgroundColor = [UIColor blackColor];

  networkImageView.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.2] CGColor];
  networkImageView.layer.borderWidth = 1;

  return networkImageView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Fit as many columns as we can with a fixed width and then center the columns in the remaining
 * space.
 */
- (void)layoutImageViews {
  CGRect frame = _scrollView.bounds;

  CGFloat maxRightEdge = 0;

  CGFloat currentX = kFramePadding;
  CGFloat currentY = kFramePadding;

  for (NINetworkImageView* imageView in _networkImageViews) {
    imageView.frame = CGRectMake(currentX, currentY, kImageDimensions, kImageDimensions);

    maxRightEdge = MAX(maxRightEdge, currentX + kImageDimensions);

    currentX += kImageDimensions + kImageSpacing;

    if (currentX + kImageDimensions >= frame.size.width - kFramePadding) {
      // Wrap to the next row.
      currentX = kFramePadding;
      currentY += kImageDimensions + kImageSpacing;
    }
  }

  if (currentX == kFramePadding) {
    // If layout ends on a new row then we remove the row from the height, otherwise the
    // scroll view will be too tall by one row.
    currentY -= kImageDimensions + kImageSpacing;
  }

  // Center the columns.
  CGFloat contentWidth = (maxRightEdge + kFramePadding);
  CGFloat contentPadding = floorf((frame.size.width - contentWidth) / 2);

  for (NINetworkImageView* imageView in _networkImageViews) {
    CGRect imageFrame = imageView.frame;
    imageFrame.origin.x += contentPadding;
    imageView.frame = imageFrame;
  }

  _scrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                       currentY + kImageDimensions + kFramePadding);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  // Off-white background to show the text shadow highlight.
  self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];

  _memoryUsageLabel = [[UILabel alloc] init];
  _memoryUsageLabel.backgroundColor = self.view.backgroundColor;
  _memoryUsageLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
  _memoryUsageLabel.shadowColor = [UIColor colorWithWhite:1 alpha:1];
  _memoryUsageLabel.shadowOffset = CGSizeMake(0, 1);
  _memoryUsageLabel.font = [UIFont boldSystemFontOfSize:14];
  _memoryUsageLabel.text = @"Fetching the images...";
  [_memoryUsageLabel sizeToFit];
  _memoryUsageLabel.frame = CGRectMake(kFramePadding, kFramePadding,
                                       _memoryUsageLabel.frame.size.width,
                                       _memoryUsageLabel.frame.size.height);

  [self.view addSubview:_memoryUsageLabel];


  UIView* bottomBorder = [[UIView alloc] initWithFrame:
                           CGRectMake(0,
                                      CGRectGetMaxY(_memoryUsageLabel.frame)
                                      + kTextBottomMargin - 1,
                                      self.view.frame.size.width,
                                      1)];
  bottomBorder.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                   | UIViewAutoresizingFlexibleBottomMargin);
  bottomBorder.backgroundColor = [UIColor whiteColor];

  [self.view addSubview:bottomBorder];


  _networkImageViews = [[NSMutableArray alloc] init];

  _scrollView = [[UIScrollView alloc] initWithFrame:
                  NIRectShift(self.view.bounds,
                              0, CGRectGetMaxY(_memoryUsageLabel.frame) + kTextBottomMargin)];
  _scrollView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
  _scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
  _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                  | UIViewAutoresizingFlexibleHeight);

  for (NSInteger ix = UIViewContentModeScaleToFill; ix <= UIViewContentModeBottomRight; ++ix) {
    if (UIViewContentModeRedraw == ix) {
      // Unsupported mode.
      continue;
    }
    NINetworkImageView* networkImageView = [self networkImageView];

    // From: http://www.flickr.com/photos/thonk25/3929945380/
    // We fetch the network image by explicitly setting the display size and content mode.
    // This overrides the use of the frame to determine the display size.
    [networkImageView setPathToNetworkImage:
     @"http://farm3.static.flickr.com/2484/3929945380_deef6f4962_z.jpg"
                             forDisplaySize: CGSizeMake(kImageDimensions, kImageDimensions)
                                contentMode: ix];

    [_scrollView addSubview:networkImageView];
    [_networkImageViews addObject:networkImageView];
  }

  [self.view addSubview:_scrollView];

  [self layoutImageViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _memoryUsageLabel = nil;
  _networkImageViews = nil;
  _scrollView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [_scrollView flashScrollIndicators];
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
  [self layoutImageViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  [_scrollView flashScrollIndicators];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NINetworkImageViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image {
  _memoryUsageLabel.text = [NSString stringWithFormat:@"In-memory cache size: %d pixels",
                            [[Nimbus imageMemoryCache] numberOfPixels]];
  [_memoryUsageLabel sizeToFit];
  _memoryUsageLabel.frame = CGRectMake(kFramePadding, kFramePadding,
                                       _memoryUsageLabel.frame.size.width,
                                       _memoryUsageLabel.frame.size.height);
}


@end
