//
//  SearchViewController.m
//  BasicMessageController
//
//  Created by Tony Lewis on 3/1/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end


@implementation SearchViewController

@synthesize model = _model;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISearchBar* searchBar = [[[UISearchBar alloc] init] autorelease];
    [searchBar sizeToFit];
    _searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchController.delegate = self;
    self.tableView.tableHeaderView = _searchController.searchBar;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(cancel)];
    [self.tableView setContentOffset:CGPointMake(0.0f, 33.0f)];
}


-(void)cancel {
    [self dismissModalViewControllerAnimated:YES];
}


-(void)setModel:(SearchTableViewModel*)model {
    if (model != _model) {
        if (_model) {
            [_model release];
        }
        _model = [model retain];
        _model.delegate = self;
        self.tableView.dataSource = _model;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
     */
    SearchTableViewModel* entry = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        entry = [(NITableViewModel*)self.searchDisplayController.searchResultsDataSource objectAtIndexPath:indexPath];
    }
    else
    {
        entry = [_model objectAtIndexPath:indexPath];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewController:didSelectObject:)]) {
        [_delegate searchViewController:self didSelectObject:entry];
        [self dismissModalViewControllerAnimated:YES];
    }
}


#pragma mark -
#pragma mark NITableViewModelDelegate

/**
 * Fetches a table view cell at a given index path with a given object.
 *
 * The implementation of this method will generally use object to customize the cell.
 */
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

#pragma mark -
#pragma mark UISearchDisplayDelegate


- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    tableView.delegate = self;
}

// return YES to reload table. called when search string/option changes. convenience methods on top UISearchBar delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NITableViewModel* searchResults = [_model search:searchString];
    searchResults.delegate = self;
    controller.searchResultsDataSource = searchResults;
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}


@end
