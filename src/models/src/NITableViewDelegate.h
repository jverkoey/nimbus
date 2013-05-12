//
// Copyright 2011 Jared Egan
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "NIPreprocessorMacros.h" /* for NI_WEAK */

#import "NITableViewSystem.h"

@class NITableViewModel;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface NITableViewDelegate : NSObject <UITableViewDelegate,
UIScrollViewDelegate>

@property (nonatomic, NI_STRONG) NITableViewModel *dataSource;

@property (nonatomic, NI_WEAK) NITableViewSystem *tableSystem;

- (id)initWithDataSource:(NITableViewModel *)dataSource;
- (id)initWithDataSource:(NITableViewModel *)dataSource
                delegate:(id<NITableViewSystemDelegate,UIScrollViewDelegate>)delegate;

@end
