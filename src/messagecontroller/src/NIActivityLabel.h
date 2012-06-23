//
//  NIActivityLabel.h
//
//  Created by Tony Lewis on 02/03/2012.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//


#ifndef NIActivityLabel_Enums_h
#define NIActivityLabel_Enums_h

typedef enum {
    NIActivityLabelStyleBlackBezel,
    NIActivityLabelStyleWhiteBezel,
    NIActivityLabelStyleWhiteBox,
    NIActivityLabelStyleBlackBanner
} NIActivityLabelStyle;


#endif

#define NI_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

#import <QuartzCore/QuartzCore.h>

@interface NIActivityLabel : UIView {
    NIActivityLabelStyle      _style;
    
    UIView*                   _bezelView;
    UIProgressView*           _progressView;
    UIActivityIndicatorView*  _activityIndicator;
    UILabel*                  _label;
    
    float                     _progress;
    BOOL                      _smoothesProgress;
    NSTimer*                  _smoothTimer;
}

@property (nonatomic, readonly) NIActivityLabelStyle style;

@property (nonatomic, copy)     NSString* text;
@property (nonatomic, copy)     UIFont*   font;

@property (nonatomic)           float     progress;
@property (nonatomic)           BOOL      isAnimating;
@property (nonatomic)           BOOL      smoothesProgress;

- (id)initWithFrame:(CGRect)frame style:(NIActivityLabelStyle)style;
- (id)initWithFrame:(CGRect)frame style:(NIActivityLabelStyle)style text:(NSString*)text;
- (id)initWithStyle:(NIActivityLabelStyle)style;

@end