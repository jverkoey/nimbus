//
//  TableViewSystemViewController.m
//  NimbusCatalog
//
//  Created by Metral, Max on 7/1/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import "TableViewSystemViewController.h"
#import "NITableViewSystem.h"
#import "NICellCatalog.h"

@interface TableViewSystemViewController () <
    NITableViewSystemDelegate
>
@property (nonatomic,strong) NITableViewSystem *tableSystem;
@end

@implementation TableViewSystemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableSystem = [[NITableViewSystem alloc] initWithDelegate:self];
    self.tableSystem.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableSystem.tableView];
    
    [self.tableSystem setDataSourceWithArray:@[
     [self.tableSystem.actions attachToObject:[NITitleCellObject objectWithTitle:@"Lighting"] detailSelector:@selector(lights:)],
     [self.tableSystem.actions attachToObject:[NITitleCellObject objectWithTitle:@"Temperature"] tapBlock:^BOOL(NITitleCellObject* tableCellObject, TableViewSystemViewController* target, NSIndexPath *indexPath) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                        message:@"You tapped Temperature"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return YES;
    }],
     [self.tableSystem.actions attachToObject: [NITitleCellObject objectWithTitle:@"Audio"] navigationBlock:NIPushDeselectingControllerAction([TableViewSystemViewController class])]
     ]];
}

-(void)lights: (NITitleCellObject*) sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                    message:@"Lights Disclosure Pressed"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableSystem.tableView.frame = self.view.bounds;
}
@end
