//
//  NITableViewDelegate.h
//  Nimbus
//
//  Created by Jared Egan on 2/28/13.
//  Copyright 2013 Jeff Verkoeyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NITableViewSystem.h"

@class NITableViewModel;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewDelegate : NSObject <UITableViewDelegate,
UIScrollViewDelegate> {

}

@property (nonatomic, strong) NITableViewModel *dataSource;

@property (nonatomic, unsafe_unretained) NITableViewSystem *tableSystem;
@property (nonatomic, unsafe_unretained) id<NITableViewSystemDelegate, UIScrollViewDelegate> delegate;

- (id)initWithDataSource:(NITableViewModel *)dataSource;
- (id)initWithDataSource:(NITableViewModel *)dataSource
                delegate:(id<NITableViewSystemDelegate,UIScrollViewDelegate>)delegate;

@end
