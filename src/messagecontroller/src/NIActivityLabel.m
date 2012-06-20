//
//  NIActivityLabel.h
//
//  Created by Tony Lewis on 02/03/2012.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "NIActivityLabel.h"

static CGFloat kMargin          = 10;
static CGFloat kPadding         = 15;
static CGFloat kBannerPadding   = 8;
static CGFloat kSpacing         = 6;
static CGFloat kProgressMargin  = 6;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIActivityLabel

@synthesize style             = _style;
@synthesize progress          = _progress;
@synthesize smoothesProgress  = _smoothesProgress;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(NIActivityLabelStyle)style text:(NSString*)text {
	self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        _progress = 0;
        _smoothesProgress = NO;
        _smoothTimer =nil;
        _progressView = nil;
        
        _bezelView = [[UIView alloc] init];
        if (_style == NIActivityLabelStyleBlackBezel) {
            _bezelView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
            _bezelView.layer.cornerRadius = 10.0f;
            self.backgroundColor = [UIColor clearColor];
            
        } else if (_style == NIActivityLabelStyleWhiteBox) {
            _bezelView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = [UIColor whiteColor];
            
        } else if (_style == NIActivityLabelStyleWhiteBezel) {
            _bezelView.backgroundColor = [UIColor clearColor];
            _bezelView.layer.cornerRadius = 10.0f;
            //_bezelView.layer.borderColor = [RGBCOLOR(178, 178, 178) CGColor];
            //_bezelView.layer.borderWidth = 1;
            self.backgroundColor = [UIColor clearColor];
        } else if (_style == NIActivityLabelStyleBlackBanner) {
            _bezelView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
            self.backgroundColor = [UIColor clearColor];
        } else {
            _bezelView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = [UIColor clearColor];
        }
        
        self.autoresizingMask =
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        _label = [[UILabel alloc] init];
        _label.text = text;
        _label.backgroundColor = [UIColor clearColor];
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        
        if (_style == NIActivityLabelStyleBlackBezel) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleWhiteLarge];
            _activityIndicator.frame = CGRectMake(0, 0, 24, 24);
            _label.font = [UIFont systemFontOfSize:17];
            _label.textColor = [UIColor whiteColor];
            _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
            _label.shadowOffset = CGSizeMake(1, 1);
            
        } else if (_style == NIActivityLabelStyleWhiteBezel
                   || _style == NIActivityLabelStyleWhiteBox) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _label.font = [UIFont systemFontOfSize:17];
            _label.textColor = RGBCOLOR(99, 109, 125);
        } else if (_style == NIActivityLabelStyleBlackBanner) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleWhite];
            _label.font = [UIFont boldSystemFontOfSize:11];
            _label.textColor = [UIColor whiteColor];
            _label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
            _label.shadowOffset = CGSizeMake(1, 1);
        }
        
        [self addSubview:_bezelView];
        [_bezelView addSubview:_activityIndicator];
        [_bezelView addSubview:_label];
        [_activityIndicator startAnimating];
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame style:(NIActivityLabelStyle)style {
	self = [self initWithFrame:frame style:style text:nil];
    if (self) {
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(NIActivityLabelStyle)style {
	self = [self initWithFrame:CGRectZero style:style text:nil];
    if (self) {
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [self initWithFrame:frame style:NIActivityLabelStyleWhiteBox text:nil];
    if (self) {
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize textSize = [_label.text sizeWithFont:_label.font];
    
    CGFloat indicatorSize = 0;
    [_activityIndicator sizeToFit];
    if (_activityIndicator.isAnimating) {
        if (_activityIndicator.frame.size.height > textSize.height) {
            indicatorSize = textSize.height;
            
        } else {
            indicatorSize = _activityIndicator.frame.size.height;
        }
    }
    
    CGFloat contentWidth = indicatorSize + kSpacing + textSize.width;
    CGFloat contentHeight = textSize.height > indicatorSize ? textSize.height : indicatorSize;
    
    if (_progressView) {
        [_progressView sizeToFit];
        contentHeight += _progressView.frame.size.height + kSpacing;
    }
    
    CGFloat margin, padding, bezelWidth, bezelHeight;
    if (_style == NIActivityLabelStyleBlackBezel || _style == NIActivityLabelStyleWhiteBezel) {
        margin = kMargin;
        padding = kPadding;
        bezelWidth = contentWidth + padding*2;
        bezelHeight = contentHeight + padding*2;
        
    } else {
        margin = 0;
        padding = kBannerPadding;
        bezelWidth = self.frame.size.width;
        bezelHeight = self.frame.size.height;
    }
    
//    CGFloat maxBevelWidth = [UIApplication sharedApplication].keyWindow.bounds.size.width - margin*2;
//    if (bezelWidth > maxBevelWidth) {
//        bezelWidth = maxBevelWidth;
//        contentWidth = bezelWidth - (kSpacing + indicatorSize);
//    }
    
    CGFloat textMaxWidth = (bezelWidth - (indicatorSize + kSpacing)) - padding*2;
    CGFloat textWidth = textSize.width;
    if (textWidth > textMaxWidth) {
        textWidth = textMaxWidth;
    }
    
    _bezelView.frame = CGRectMake(floor(self.frame.size.width/2 - bezelWidth/2),
                                  floor(self.frame.size.height/2 - bezelHeight/2),
                                  bezelWidth, bezelHeight);
    
    CGFloat y = padding + floor((bezelHeight - padding*2)/2 - contentHeight/2);
    
    if (_progressView) {
        if (_style == NIActivityLabelStyleBlackBanner) {
            y += kBannerPadding/2;
        }
        _progressView.frame = CGRectMake(kProgressMargin, y,
                                         bezelWidth - kProgressMargin*2, _progressView.frame.size.height);
        y += _progressView.frame.size.height + kSpacing-1;
    }
    
    _label.frame = CGRectMake(floor((bezelWidth/2 - contentWidth/2) + indicatorSize + kSpacing), y,
                              textWidth, textSize.height);
    
    _activityIndicator.frame = CGRectMake(_label.frame.origin.x - (indicatorSize+kSpacing), y,
                                          indicatorSize, indicatorSize);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat padding;
    if (_style == NIActivityLabelStyleBlackBezel || _style == NIActivityLabelStyleWhiteBezel) {
        padding = kPadding;
        
    } else {
        padding = kBannerPadding;
    }
    
    CGFloat height = _label.font.lineHeight + padding*2;
    if (_progressView) {
        height += _progressView.frame.size.height + kSpacing;
    }
    
    return CGSizeMake(size.width, height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)smoothTimer {
    if (_progressView.progress < _progress) {
        _progressView.progress += 0.01;
        
    } else {
        NI_INVALIDATE_TIMER(_smoothTimer);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)text {
    return _label.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
    _label.text = text;
    [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
    return _label.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
    _label.font = font;
    [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAnimating {
    return _activityIndicator.isAnimating;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setIsAnimating:(BOOL)isAnimating {
    if (isAnimating) {
        [_activityIndicator startAnimating];
        
    } else {
        [_activityIndicator stopAnimating];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setProgress:(float)progress {
    _progress = progress;
    
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = 0;
        [_bezelView addSubview:_progressView];
        [self setNeedsLayout];
    }
    
    if (_smoothesProgress) {
        if (!_smoothTimer) {
            _smoothTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self
                                                          selector:@selector(smoothTimer) userInfo:nil repeats:YES];
        }
        
    } else {
        _progressView.progress = progress;
    }
}


@end
