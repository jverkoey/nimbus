//
// Copyright 2009-2011 Facebook
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

#import "NIPickerViewCell.h"

static const CGFloat kPaddingX = 8;
static const CGFloat kPaddingY = 3;
static const CGFloat kMaxWidth = 250;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIPickerViewCell

@synthesize object    = _object;
@synthesize selected  = _selected;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        _labelView = [[UILabel alloc] init];
        _labelView.backgroundColor = [UIColor clearColor];
        _labelView.textColor = [UIColor blackColor];
        _labelView.highlightedTextColor = [UIColor whiteColor];
        _labelView.lineBreakMode = UILineBreakModeTailTruncation;
        [self addSubview:_labelView];
        
        self.startColor = RGBCOLOR(221, 231, 248);
        self.endColor = RGBACOLOR(188, 206, 241, 1);
        
        self.backgroundColor = [UIColor clearColor];
        [self.layer setCornerRadius:13.0f];
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:RGBCOLOR(161, 187, 255).CGColor];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    NI_RELEASE_SAFELY(_object);
    NI_RELEASE_SAFELY(_labelView);
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    _labelView.frame = CGRectMake(kPaddingX, kPaddingY,
                                  self.frame.size.width-kPaddingX*2, self.frame.size.height-kPaddingY*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font];
    CGFloat width = labelSize.width + kPaddingX*2;
    return CGSizeMake(width > kMaxWidth ? kMaxWidth : width, labelSize.height + kPaddingY*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)label {
    return _labelView.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLabel:(NSString*)label {
    _labelView.text = label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
    return _labelView.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
    _labelView.font = font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected {
    _selected = selected;
    _labelView.highlighted = selected;

    if (self.selected) {
        [self.layer setCornerRadius:13.0f];
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:RGBCOLOR(118, 130, 255).CGColor];
        self.startColor = RGBCOLOR(79, 144, 255);
        self.endColor = RGBCOLOR(49, 90, 255);
    } else {
        [self.layer setCornerRadius:13.0f];
        [self.layer setBorderWidth:1.0f];
        [self.layer setBorderColor:RGBCOLOR(161, 187, 255).CGColor];
        self.startColor = RGBCOLOR(221, 231, 248);
        self.endColor = RGBACOLOR(188, 206, 241, 1);
    }
    
    [self setNeedsDisplay];
}


@end
