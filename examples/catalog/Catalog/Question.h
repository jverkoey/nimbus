//
//  Question.h
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NimbusModels.h"

@interface Question : NSObject <NICellObject>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@end
