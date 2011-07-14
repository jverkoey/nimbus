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

#import "NIPhotoViewController.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPhotoViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  _pagingScrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
  _pagingScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                        | UIViewAutoresizingFlexibleHeight);
  _pagingScrollView.pagingEnabled = YES;

  _pagingScrollView.delegate = self;

  // This is a strange thing, but we must set a background color on the scroll view otherwise
  // touches won't be received unless the touch is on a subview of the scroll view.
  _pagingScrollView.backgroundColor = [UIColor blackColor];

  // Don't show any scroll indicators.
  _pagingScrollView.showsVerticalScrollIndicator = NO;
  _pagingScrollView.showsHorizontalScrollIndicator = NO;

  self.view = _pagingScrollView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  // We don't have to release the scroll view here because self.view is the only thing retaining
  // it.
  _pagingScrollView = nil;

  [super viewDidUnload];
}


@end
