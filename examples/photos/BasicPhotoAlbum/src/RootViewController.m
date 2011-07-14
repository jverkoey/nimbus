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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation RootViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  _photoView = [[[NIPhotoScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds]
                autorelease];
  [_photoView setImage:[UIImage imageWithContentsOfFile:
                        NIPathForBundleResource(nil, @"clouds.jpeg")]];

  [self.view addSubview:_photoView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  _photoView = nil;

  [super viewDidUnload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
  return NIIsSupportedOrientation(toInterfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
  CGPoint restorePoint = [_photoView pointToCenterAfterRotation];
  CGFloat restoreScale = [_photoView scaleToRestoreAfterRotation];
  _photoView.frame = self.view.bounds;
  [_photoView setMaxMinZoomScalesForCurrentBounds];
  [_photoView restoreCenterPoint:restorePoint scale:restoreScale];
}


@end
