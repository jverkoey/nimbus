//
//  NibCellTableModelViewConroller.m
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import "NibCellTableModelViewConroller.h"
#import "NimbusModels.h"
#import "Question.h"

#import "AppendObjectClassObject.h"
#import "AppendObjectClassObjectCell.h"
#import "AppendObjectClassObjectCell2.h"

@interface NibCellTableModelViewConroller ()

@property (nonatomic, readwrite, retain) NITableViewModel* model;

@end

@implementation NibCellTableModelViewConroller

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"nib cell model";
        // Question load QuestionCell from Nib see `-[QuestionCell shouldLoadNib]`
        //
        // AppendObjectClassObject *a1 maps to AppendObjectClassObjectCell
        // AppendObjectClassObject *a2 maps to AppendObjectClassObjectCell2
        // AppendObjectClassObjectCell and AppendObjectClassObjectCell2 have set shouldAppendObjectClassToReuseIdentifier YES
        // so the identifier of cell xib and the cell file name would like `AppendObjectClassObjectCell.AppendObjectClassObject` and `AppendObjectClassObjectCell2.AppendObjectClassObject`.
        // or else it wont be load
        
        Question *q1 = [Question new];
        q1.title = @"Can I use Nib to load cell?";
        q1.content = @"YES";
        
        AppendObjectClassObject *a1 = [AppendObjectClassObject new];
        a1.title = @"AppendObjectClassObject maps to";
        a1.content = @"AppendObjectClassObjectCell";
        a1.cellClass = [AppendObjectClassObjectCell class];
        
        AppendObjectClassObject *a2 = [AppendObjectClassObject new];
        a2.title = @"AppendObjectClassObject maps to ";
        a2.content = @"AppendObjectClassObjectCell2";
        a2.cellClass = [AppendObjectClassObjectCell2 class];
        
        NSArray* tableContents =
        [NSArray arrayWithObjects:


         q1,
         a1,
         a2,
         nil];
        
        _model = [[NITableViewModel alloc] initWithListArray:tableContents
                                                    delegate:(id)[NICellFactory class]];

    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
    //return [NICellFactory tableView:tableView heightForRowAtIndexPath:indexPath model:self.model];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self.model;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
