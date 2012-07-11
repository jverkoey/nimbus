//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "ContentModesNetworkImageViewController.h"
#import "NimbusNetworkImage.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This controller demos the various UIViewContentMode types supported by the network image view.
// It shows a grid of images, each with a different content mode for the same image.
//
// You will find the following Nimbus features used:
//
// [networkimage]
// NINetworkImageView
//
// This controller requires the following frameworks:
//
// Foundation.framework
// UIKit.framework
// QuartzCore.framework
// AFNetworking https://github.com/AFNetworking/AFNetworking
//

// Various display metrics used through the view. We define them at the top of the file so that
// they're easy to access and modify.
static const CGFloat kImageDimensions = 78;
static const CGFloat kFramePadding = 10;
static const CGFloat kImageSpacing = 5;

@interface ContentModesNetworkImageViewController()
@property (nonatomic, readwrite, copy) NSArray* networkImageViews;
@end

@implementation ContentModesNetworkImageViewController

@synthesize networkImageViews = _networkImageViews;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Content Modes";
  }
  return self;
}

// Lays out all of our network image views within the controller view.
- (void)layoutImageViews {
  CGRect frame = self.view.bounds;
  
  CGFloat maxRightEdge = 0;
  
  CGFloat currentX = kFramePadding;
  CGFloat currentY = kFramePadding;

  // Iterate through the image views and wrap them in rows/columns.
  for (NINetworkImageView* imageView in self.networkImageViews) {
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

  // Offset all of the images as a unit so that they're all centered.
  // If we wanted to simplify this we could add all of the image views to a container view
  // that would then be offset to center everything.
  for (NINetworkImageView* imageView in self.networkImageViews) {
    CGRect imageFrame = imageView.frame;
    imageFrame.origin.x += contentPadding;
    imageView.frame = imageFrame;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor underPageBackgroundColor];

  // We only want one network request to be able to fire off at a time because we know all of the
  // requests are going to be for the same image. This way each subsequent request will load the
  // already downloaded image from the cache.
  [[Nimbus networkOperationQueue] setMaxConcurrentOperationCount:1];

  // We're going to create a network image view for each UIViewContentMode that the network image
  // view supports.
  NSMutableArray* networkImageViews = [NSMutableArray array];
  for (NSInteger ix = UIViewContentModeScaleToFill; ix <= UIViewContentModeBottomRight; ++ix) {
    if (UIViewContentModeRedraw == ix) {
      // Unsupported mode.
      continue;
    }
    NINetworkImageView* imageView = [[NINetworkImageView alloc] initWithFrame:CGRectZero];
    imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    imageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.1].CGColor;
    imageView.layer.borderWidth = 1;
    
    // From: http://www.flickr.com/photos/htakashi/5653586269/
    // We fetch the network image by explicitly setting the display size and content mode.
    // This overrides the use of the frame to determine the display size. This allows you to fetch
    // the image without laying out your views first, which can be useful if you know the dimensions
    // of the images you'll be fetching.
    //
    // The network image view is smart enough to know that the display size you pass should be
    // doubled when creating the image on retina displays.
    //
    // Note that setting the content mode this way is also a useful way of having a different
    // content mode for the network image compared to the initial image.
    [imageView setPathToNetworkImage:
     @"http://farm6.staticflickr.com/5030/5653586269_0737781c55_b.jpg"
                      forDisplaySize:CGSizeMake(kImageDimensions, kImageDimensions)
                         contentMode:ix];

    [self.view addSubview:imageView];
    [networkImageViews addObject:imageView];
  }
  self.networkImageViews = networkImageViews;

  [self layoutImageViews];
}

- (void)viewDidUnload {
  [super viewDidUnload];

  // The views are no longer needed.
  self.networkImageViews = nil;

  // Reset the maximum number of concurrent operations.
  [[Nimbus networkOperationQueue] setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

  // When we rotate we will need to update the layout of all of the image views so that they fit.
  [self layoutImageViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
