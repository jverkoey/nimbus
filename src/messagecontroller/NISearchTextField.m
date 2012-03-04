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

#import "NISearchTextField.h"

// UI (private)
#import "NISearchTextFieldInternal.h"

static const CGFloat kShadowHeight = 24;
static const CGFloat kDesiredTableHeight = 150;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISearchTextField

@synthesize tableView             = _tableView;
@synthesize rowHeight             = _rowHeight;
@synthesize searchesAutomatically = _searchesAutomatically;
@synthesize showsDarkScreen       = _showsDarkScreen;
@synthesize dataSource            = _dataSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
    if (self) {
        _internal = [[NISearchTextFieldInternal alloc] initWithTextField:self];
        
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchesAutomatically = YES;
        
        [self addTarget:self action:@selector(didBeginEditing)
       forControlEvents:UIControlEventEditingDidBegin];
        [self addTarget:self action:@selector(didEndEditing)
       forControlEvents:UIControlEventEditingDidEnd];
        
        [super setDelegate:_internal];
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    _tableView.delegate = nil;
    NI_RELEASE_SAFELY(_dataSource);
    NI_RELEASE_SAFELY(_searchResults);
    NI_RELEASE_SAFELY(_internal);
    NI_RELEASE_SAFELY(_tableView);
    NI_RELEASE_SAFELY(_shadowView);
    NI_RELEASE_SAFELY(_screenView);
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showDarkScreen:(BOOL)show {
    if (show && !_screenView) {
        _screenView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _screenView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _screenView.frame = [self rectForSearchResults:NO];
        _screenView.alpha = 0;
        [_screenView addTarget:self action:@selector(doneAction)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (show) {
        [self.superviewForSearchResults addSubview:_screenView];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(screenAnimationDidStop)];
    
    _screenView.alpha = show ? 1 : 0;
    
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)searchText {
    if (!self.hasText) {
        return @"";
        
    } else {
        NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
        return [self.text stringByTrimmingCharactersInSet:whitespace];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)autoSearch {
    if (_searchesAutomatically && self.text.length) {
        [self search];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchUpdate:(NSTimer*)timer {
    _searchTimer = nil;
    [self autoSearch];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayedUpdate {
    [_searchTimer invalidate];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
                                                  selector:@selector(dispatchUpdate:) userInfo:nil repeats:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasSearchResults {
    return (_searchResults != nil);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadTable {
    if ([self hasSearchResults]) {
        [self layoutIfNeeded];
        [self showSearchResults:YES];
        [self.tableView reloadData];
        
    } else {
        [self showSearchResults:NO];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)screenAnimationDidStop {
    if (_screenView.alpha == 0) {
        [_screenView removeFromSuperview];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)doneAction {
    [self resignFirstResponder];
    
    if (self.dataSource) {
        self.text = @"";
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<UITextFieldDelegate>)delegate {
    return _internal.delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<NISearchTextFieldDelegate>)delegate {
    _internal.delegate = delegate;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(NSString*)text {
    [super setText:text];
    [self autoSearch];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    if (_rowHeight) {
        return _rowHeight;
    } else {
        return 44.0f;
        // TODO: Need to see if we can make this dynamic.
        /*
         id object = [_dataSource objectAtIndexPath:indexPath];
         Class cls = [_dataSource  tableView:tableView cellClassForObject:object];
         return [cls tableView:_tableView rowHeightForObject:object];
         */
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    // TODO: Need to react to row selection here
    //    if ([_internal.delegate respondsToSelector:@selector(textField:didSelectObject:)]) {
    //        id object = [_dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    //        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    //        if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
    //            [_internal.delegate performSelector:@selector(textField:didSelectObject:) withObject:self
    //                                     withObject:object];
    //        }
    //    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControlEvents


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didBeginEditing {
    if (_dataSource) {
        UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
        scrollView.scrollEnabled = NO;
        scrollView.scrollsToTop = NO;
        
        if (_showsDarkScreen) {
            [self showDarkScreen:YES];
        }
        if (self.hasText && self.hasSearchResults) {
            [self showSearchResults:YES];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didEndEditing {
    if (_dataSource) {
        UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
        scrollView.scrollEnabled = YES;
        scrollView.scrollsToTop = YES;
        
        [self showSearchResults:NO];
        
        if (_showsDarkScreen) {
            [self showDarkScreen:NO];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(NITableViewSearchModel*)dataSource {
    if (dataSource != _dataSource) {
        [_dataSource release];
        _dataSource = [dataSource retain];
        _dataSource.delegate = self;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView*)createTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(235, 235, 235);
        _tableView.separatorColor = [UIColor colorWithWhite:0.85 alpha:1];
        _tableView.rowHeight = _rowHeight;
        _tableView.dataSource = _searchResults;
        _tableView.delegate = self;
        _tableView.scrollsToTop = NO;
        UIView *footer =
        [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = footer;
        [footer release];
    }
    
    return _tableView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSearchesAutomatically:(BOOL)searchesAutomatically {
    _searchesAutomatically = searchesAutomatically;
    if (searchesAutomatically) {
        self.returnKeyType = UIReturnKeyDone;
        self.enablesReturnKeyAutomatically = NO;
        
    } else {
        self.returnKeyType = UIReturnKeySearch;
        self.enablesReturnKeyAutomatically = YES;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasText {
    return self.text.length;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search {
    if (_dataSource) {
        NSString* text = self.searchText;
        NI_RELEASE_SAFELY(_searchResults);
        _searchResults = [[_dataSource search:text] retain];
        _searchResults.delegate = self;
        _tableView.dataSource = _searchResults;
        [self reloadTable];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showSearchResults:(BOOL)show {
    if (show && _searchResults ) {
        [self createTableView];
        
        if (!_shadowView) {
            _shadowView = [[NIGradientView alloc] init];
            _shadowView.startColor = RGBACOLOR(0, 0, 0, 0.18);
            _shadowView.endColor = [UIColor clearColor];
            _shadowView.backgroundColor = [UIColor clearColor];
            _shadowView.userInteractionEnabled = NO;
        }
        
        if (!_tableView.superview) {
            _tableView.frame = [self rectForSearchResults:YES];
            _shadowView.frame = CGRectMake(_tableView.frame.origin.x,
                                           _tableView.frame.origin.y-1,
                                           _tableView.frame.size.width,
                                           kShadowHeight);
            
            UIView* superview = self.superviewForSearchResults;
            [superview addSubview:_tableView];
            
            if (_tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
                [superview addSubview:_shadowView];
            }
        }
        
        [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:NO];
        
    } else {
        if (_tableView) {
            [_tableView removeFromSuperview];
        }
        if(_shadowView) {
            [_shadowView removeFromSuperview];
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)superviewForSearchResults {
    UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
    if (scrollView) {
        return scrollView;
        
    } else {
        for (UIView* view = self.superview; view; view = view.superview) {
            if (view.frame.size.height > kDesiredTableHeight) {
                return view;
            }
        }
        
        return self.superview;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
    UIView* superview = self.superviewForSearchResults;
    
    CGFloat y = 0;
    UIView* view = self;
    while (view != superview) {
        y += view.frame.origin.y;
        view = view.superview;
    }
    
    CGFloat height = self.frame.size.height;
    CGFloat keyboardHeight = withKeyboard ? NIKeyboardHeightForOrientation(NIInterfaceOrientation()) : 0;
    CGFloat tableHeight = self.window.frame.size.height - (self.frame.origin.y + height + keyboardHeight);
    return CGRectMake(0, y + self.frame.size.height-1, superview.frame.size.width, tableHeight+1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdate:(BOOL)emptyText {
    [self delayedUpdate];
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NITableViewModelDelegate


/**
 * Fetches a table view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableViewModel: (NITableViewModel *)tableViewModel
                   cellForTableView: (UITableView *)tableView
                        atIndexPath: (NSIndexPath *)indexPath
                         withObject: (id)object {
    
    // A pretty standard implementation of creating table view cells follows.
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"row"];
    
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: @"row"]
                autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [object objectForKey:@"title"];
    
    return cell;
}


@end
