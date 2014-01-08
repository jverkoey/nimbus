//
//  AppendObjectClassObject.m
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import "AppendObjectClassObject.h"
#import "AppendObjectClassObjectCell.h"

@implementation AppendObjectClassObject


- (Class)cellClass {
    if (_cellClass == nil) {
       _cellClass = [AppendObjectClassObjectCell class];
    }
    
    return _cellClass;
}


@end
