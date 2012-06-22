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

#import "BasicInstantiationNetworkImageViewController.h"
#import "NimbusNetworkImage.h"

#import <QuartzCore/QuartzCore.h>

//
// What's going on in this file:
//
// This is a simple example of instantiating a NINetworkImageView and loading an image from the
// network. This controller shows how to modify the content mode and frame to adjust the way the
// network image is displayed.
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

@implementation BasicInstantiationNetworkImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.title = @"Basic Instantiation";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor underPageBackgroundColor];

  // A NINetworkImageView is a subclass of UIImageView. We can provide an image to the initializer
  // and it will be displayed until the network image is loaded. In this example we won't set an
  // initial image.
  NINetworkImageView* imageView = [[NINetworkImageView alloc] initWithFrame:CGRectZero];
  imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

  // We don't set an initial image so let's create a nice-looking "frame" effect on the view.
  // This will show a translucent background with a highlighted border.
  imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
  imageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.1].CGColor;
  imageView.layer.borderWidth = 1;

  // The content mode of the image view is an important thing to consider. For normal UIImageViews
  // the content mode is used to position the image in the bounds. This is how NINetworkImageView
  // works as well, but with one additional feature: images downloaded from the network will be
  // cropped and/or resized to fit the content mode. This ensures that the image being displayed
  // in your NINetworkImageView is only taking up as much memory as is needed to display it.
  // This also significantly improves performance because the image dimensions match your view
  // dimensions, allowing a straight copy onto the screen.
  //
  // Experiment: Try changing the content mode to different values and seeing the effect it has on
  // the downloaded image.
  imageView.contentMode = UIViewContentModeScaleAspectFill;

  // When we ask the network image view to download an image it will use the current image view's
  // dimensions to create the final cropped and/or resized image. It's important, as a result, to
  // set the frame before we load the image.
  imageView.frame = CGRectMake(20, 20, 200, 200);

  // We can set the path to this image view's image on the network now that the various presentation
  // options have been set. As discussed above, the network image view will use the contentMode and
  // bounds to crop and/or resize the downloaded image to fit the dimensions perfectly.
  [imageView setPathToNetworkImage:@"http://farm5.staticflickr.com/4016/4441744445_97cfbf4519_b_d.jpg"];

  [self.view addSubview:imageView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return NIIsSupportedOrientation(interfaceOrientation);
}

@end
