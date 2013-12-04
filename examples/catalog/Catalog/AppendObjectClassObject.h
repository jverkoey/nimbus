//
//  AppendObjectClassObject.h
//  NimbusCatalog
//
//  Created by Ryan Wang on 12/4/13.
//  Copyright (c) 2013 Nimbus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NimbusModels.h"

@interface AppendObjectClassObject : NSObject  <NICellObject>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) Class cellClass; // makes one object map to different cells


@end
