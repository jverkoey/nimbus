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

#import <QuartzCore/QuartzCore.h>
#import "NILauncherButtonView.h"

#import "NILauncherViewObject.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

// The contentInset around the entire button on the top, left, bottom, and right sides.
static const CGFloat kDefaultContentInset = 0;

// The amount of space between the bottom of the image and the top of the text.
static const CGFloat kImageBottomMargin = 5;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherButtonView

@synthesize label = _label;
@synthesize button = _button;
@synthesize contentInset = _contentInset;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
    _contentInset = UIEdgeInsetsMake(kDefaultContentInset, kDefaultContentInset, kDefaultContentInset, kDefaultContentInset);

    _button = [UIButton buttonWithType:UIButtonTypeCustom];

    _button.imageView.contentMode = UIViewContentModeCenter;

    _label = [[UILabel alloc] init];
    _label.backgroundColor = [UIColor clearColor];
    _label.numberOfLines = 1;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < NIIOS_6_0
    _label.textAlignment = UITextAlignmentCenter;
    _label.lineBreakMode = UILineBreakModeTailTruncation;
#else
    _label.textAlignment = NSTextAlignmentCenter;
    _label.lineBreakMode = NSLineBreakByTruncatingTail;
#endif
    _label.font = [UIFont boldSystemFontOfSize:12];
    _label.textColor = [UIColor whiteColor];

    self.layer.rasterizationScale = NIScreenScale();
    [self.layer setShouldRasterize:YES];

    [self addSubview:_button];
    [self addSubview:_label];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect contentBounds = UIEdgeInsetsInsetRect(self.bounds, self.contentInset);

  self.label.frame = CGRectMake(CGRectGetMinX(contentBounds), CGRectGetMaxY(contentBounds) - self.label.font.lineHeight,
                                CGRectGetWidth(contentBounds), self.label.font.lineHeight);
  self.button.frame = NIRectContract(contentBounds, 0, self.label.bounds.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIRecyclableView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  self.label.text = nil;
  [self.button setImage:nil forState:UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NILauncherModelObjectView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shouldUpdateViewWithObject:(NILauncherViewObject *)object {
  self.label.text = object.title;
  [self.button setImage:object.image forState:UIControlStateNormal];

  [self setNeedsLayout];
}


@end
