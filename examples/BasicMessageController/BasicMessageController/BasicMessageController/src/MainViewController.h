//
//  MainViewController.h
//  BasicMessageController
//
//  Created by Tony Lewis on 2/29/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NimbusMessageController.h"
#import "SearchViewController.h"
#import "SearchTableViewModel.h"

@interface MainViewController : UIViewController
<SearchViewControllerDelegate,NIMessageControllerDelegate> {
    NIMessageController* _messageController;
}

@end
