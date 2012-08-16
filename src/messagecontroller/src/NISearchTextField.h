//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "NimbusCore.h"
#import "NITableViewSearchModel.h"
#import "NIGradientView.h"

@class NISearchTextFieldInternal;

@interface NISearchTextField : UITextField <NITableViewModelDelegate,UITableViewDelegate> {
    NISearchTextFieldInternal*  _internal;
    
    UITableView* _tableView;
    NIGradientView*      _shadowView;
    UIButton*    _screenView;
    
    NSTimer*  _searchTimer;
    CGFloat   _rowHeight;
    
    BOOL _searchesAutomatically;
    BOOL _showsDarkScreen;
    
    NITableViewSearchModel* _dataSource;
    NITableViewModel* _searchResults;
}

@property (nonatomic, readonly) UITableView*  tableView;
@property (nonatomic)           CGFloat       rowHeight;

@property (nonatomic, readonly) BOOL hasText;
@property (nonatomic)           BOOL searchesAutomatically;
@property (nonatomic)           BOOL showsDarkScreen;

@property (nonatomic)   NITableViewSearchModel* dataSource;

- (void)search;

- (void)showSearchResults:(BOOL)show;

- (UIView*)superviewForSearchResults;

- (CGRect)rectForSearchResults:(BOOL)withKeyboard;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end



@class NISearchTextField;

@protocol NISearchTextFieldDelegate <UITextFieldDelegate>
@optional

- (void)textField:(NISearchTextField*)textField didSelectObject:(id)object;

@end
