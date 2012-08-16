//
//  SearchTableViewModel.m
//  BasicMessageController
//
//  Created by Tony Lewis on 3/1/12.
//  Copyright (c) 2012 Taknology, Inc. All rights reserved.
//

#import "SearchTableViewModel.h"

#import "NITableViewModel.h"
#import "NITableViewModel+Private.h"

@implementation SearchTableViewModel

- (NITableViewModel*)search:(NSString*)text {
    NSMutableArray* searchResults = [NSMutableArray array];
    for(NITableViewModelSection* section in self.sections) {
        for(NSDictionary* item in section.rows) {
            if ([[item objectForKey:@"title"] rangeOfString:text].location != NSNotFound) {
                [searchResults addObject:[NSDictionary dictionaryWithObject:[item objectForKey:@"title"] forKey:@"title"]];
            }
        }
    }
    
    if ([searchResults count] > 0) {
        return [[NITableViewModel alloc] initWithListArray:searchResults delegate:nil];
    } else {
        return nil;
    }
}

@end
