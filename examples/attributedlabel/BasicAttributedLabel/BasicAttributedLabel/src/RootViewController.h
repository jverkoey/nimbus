//
//  RootViewController.h
//  BasicAttributedLabel
//
//  Created by Roger Chapman on 23/08/2011.
//  Copyright 2011 Storm ID Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController {
  NIAttributedLabel *label1;
}

@property (nonatomic, retain) IBOutlet NIAttributedLabel *label1;

@end
