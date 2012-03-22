//
//  SearchTableViewModel.m
//  BasicMessageController
//
//  Created by Tony Lewis on 3/1/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "NITableViewSearchModel.h"

#import "NITableViewModel+Private.h"

@implementation NITableViewSearchModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NITableViewModel*)search:(NSString*)text {
    NSMutableArray* searchResults = [NSMutableArray array];
    NSInteger sectionIndex = 1;
    for(NITableViewModelSection* section in self.sections) {
        NSInteger rowIndex = 0;
        for(NSDictionary* item in section.rows) {
            if ([[item objectForKey:@"title"] rangeOfString:text].location != NSNotFound) {
                [searchResults addObject:[NSDictionary dictionaryWithObject:[item objectForKey:@"title"] forKey:@"title"]];
            }
            rowIndex++;
        }
        sectionIndex++;
    }
    
    return [[NITableViewModel alloc] initWithListArray:searchResults delegate:nil];
}

@end
