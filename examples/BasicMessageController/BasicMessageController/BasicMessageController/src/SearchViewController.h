//
//  SearchViewController.h
//  BasicMessageController
//
//  Created by Tony Lewis on 3/1/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchTableViewModel.h"

@protocol SearchViewControllerDelegate;

@interface SearchViewController : UITableViewController
<UISearchDisplayDelegate,UITableViewDataSource,NITableViewModelDelegate> {
    SearchTableViewModel* _model;
    UISearchDisplayController* _searchController;
    id<SearchViewControllerDelegate> _delegate;
}

@property (nonatomic, retain) SearchTableViewModel* model;
@property (nonatomic, assign) id<SearchViewControllerDelegate> delegate;

@end


@protocol SearchViewControllerDelegate <NSObject>

@optional
- (void)searchViewController:(SearchViewController *)controller didSelectObject:(id)object;

@end