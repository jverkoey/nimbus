//
//  NIGradientView.m
//  BasicMessageController
//
//  Created by Tony Lewis on 3/3/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "NIGradientView.h"

@implementation NIGradientView

@synthesize startColor = _startColor;
@synthesize endColor = _endColor;


+ (Class)layerClass {
    return [CAGradientLayer class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)drawRect:(CGRect)rect {
    if (_startColor && _endColor) {
        [(CAGradientLayer*)[self layer] setColors:[NSArray arrayWithObjects:
                                                   (id)[_startColor CGColor],
                                                   (id)[_endColor CGColor], nil]];
    }
    
    [super drawRect:rect];
}



@end
