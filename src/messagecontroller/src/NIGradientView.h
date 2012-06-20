//
//  NIGradientView.h
//  BasicMessageController
//
//  Created by Tony Lewis on 3/3/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface NIGradientView : UIView {
    UIColor* _startColor;
    UIColor* _endColor;
}

@property (nonatomic) UIColor* startColor;
@property (nonatomic) UIColor* endColor;

@end
