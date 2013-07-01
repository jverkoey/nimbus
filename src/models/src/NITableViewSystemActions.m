//
//  NITableViewSystemActions.m
//  Nimbus
//
//  Created by Metral, Max on 7/1/13.
//  Copyright (c) 2013 Jeff Verkoeyen. All rights reserved.
//

#import "NITableViewSystemActions.h"
#import "NITableViewActions+Private.h"
#import "NICellFactory.h"
#import <objc/runtime.h>

@implementation NITableViewSystemActions

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldForwardSelector:(SEL)selector {
  BOOL shouldWe = [super shouldForwardSelector:selector];
  if (!shouldWe) {
    struct objc_method_description description;
    description = protocol_getMethodDescription(@protocol(UITableViewDelegate), selector, NO, YES);
    return (description.name != NULL && description.types != NULL);
  } else {
    return YES;
  }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [((NITableViewModel*)tableView.dataSource) objectAtIndexPath:indexPath];
    
    if ([object conformsToProtocol:@protocol(NICellObject)]) {
        Class cls = [(id<NICellObject>)object cellClass];
        if ([cls conformsToProtocol:@protocol(NICell)]) {
            Method method = class_getClassMethod(cls, @selector(heightForObject:atIndexPath:tableView:));
            
            if (method != NULL) {
                return [cls heightForObject:object
                                atIndexPath:indexPath
                                  tableView:tableView];
            }
        }
    }
    
    // Default option
    return tableView.rowHeight;

}

@end
