//
//  AppendObjectClassObjectCell.h
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NimbusModels.h"

@interface AppendObjectClassObjectCell : UITableViewCell <NICell>

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

@end
