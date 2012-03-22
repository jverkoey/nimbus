//
//  SearchTableViewModel.h
//  BasicMessageController
//
//  Created by Tony Lewis on 3/1/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NITableViewModel.h"

@interface NITableViewSearchModel : NITableViewModel

- (NITableViewModel*)search:(NSString*)text;

@end
