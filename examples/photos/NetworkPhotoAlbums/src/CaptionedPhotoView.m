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

#import "CaptionedPhotoView.h"

static UIEdgeInsets kWellPadding = {0}; // see +initialize

@interface CaptionedPhotoView ()
@property (nonatomic, readwrite, retain) UILabel* captionLabel;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CaptionedPhotoView

@synthesize captionWell = _captionWell;
@synthesize captionLabel = _captionLabel;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)initialize {
  kWellPadding = UIEdgeInsetsMake(10, 10, 10, 10);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _captionWell = [[UIView alloc] initWithFrame:self.bounds];
    _captionWell.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                     | UIViewAutoresizingFlexibleTopMargin);

    _captionLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _captionLabel.numberOfLines = 0;
    _captionLabel.font = [UIFont systemFontOfSize:14];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    _captionLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];

    UIView* topBorder = [[UIView alloc] initWithFrame:CGRectZero];
    topBorder.frame = CGRectMake(0, 0, self.bounds.size.width, 1);
    topBorder.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin
                                  | UIViewAutoresizingFlexibleWidth);

    _captionWell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    topBorder.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];

    [_captionWell addSubview:topBorder];
    [_captionWell addSubview:_captionLabel];
    [self addSubview:_captionWell];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat availableWidth = self.bounds.size.width - kWellPadding.left - kWellPadding.right;

  CGSize labelSize =  [self.captionLabel.text sizeWithFont:self.captionLabel.font
                                         constrainedToSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                             lineBreakMode:self.captionLabel.lineBreakMode];
  CGFloat wellHeight = labelSize.height + kWellPadding.top + kWellPadding.bottom;
  self.captionWell.frame = CGRectMake(0, self.bounds.size.height - wellHeight - NIToolbarHeightForOrientation(NIInterfaceOrientation()),
                                      self.bounds.size.width, wellHeight);
  self.captionLabel.frame = UIEdgeInsetsInsetRect(self.captionWell.bounds, kWellPadding);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCaption:(NSString *)caption {
  if (_captionLabel.text != caption) {
    _captionLabel.text = caption;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)caption {
  return _captionLabel.text;
}

@end
