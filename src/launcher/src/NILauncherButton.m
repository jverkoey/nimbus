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

// The padding around the entire button on the top, left, bottom, and right sides.
static const CGFloat kDefaultPadding = 5;

// The amount of space between the bottom of the image and the top of the text.
static const CGFloat kSpacing = 5;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherButton

@synthesize padding = _padding;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _padding = UIEdgeInsetsMake(kDefaultPadding, kDefaultPadding,
                                kDefaultPadding, kDefaultPadding);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textAlignment = UITextAlignmentCenter;
    self.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat titleLabelWidth = (self.frame.size.width - _padding.left - _padding.right);

  CGSize titleLabelSize = [self.titleLabel.text sizeWithFont: self.titleLabel.font
                                                    forWidth: titleLabelWidth
                                               lineBreakMode: self.titleLabel.lineBreakMode];

  self.titleLabel.frame = CGRectMake(_padding.left,
                                     self.frame.size.height
                                     - titleLabelSize.height - _padding.bottom,
                                     titleLabelWidth, titleLabelSize.height);

  self.imageView.frame = CGRectMake(_padding.left, _padding.top,
                                    titleLabelWidth,
                                    self.titleLabel.frame.origin.y - kSpacing);
}


@end
