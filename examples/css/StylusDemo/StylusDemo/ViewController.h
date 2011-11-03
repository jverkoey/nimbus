//
//  ViewController.h
//  StylusDemo
//
//  Created by Daniel Barden on 11/2/11.
//  Copyright (c) 2011 None. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCSS.h"

@interface ViewController : UIViewController {
@private
    NIDOM* _dom;
    UIView* _backgroundView;
    UIActivityIndicatorView* _activityIndicator;
    UILabel* _testLabel;
}

@end
