//
// Copyright 2011-2014 NimbusKit
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

#import "NICellFactory.h"

API_DEPRECATED_BEGIN("🕘 Schedule time to migrate. "
                     "Use branded UITableView or UICollectionView instead: go/material-ios-lists. "
                     "This is go/material-ios-migrations#not-scriptable 🕘",
                     ios(12, API_TO_BE_DEPRECATED))

// Private classes for use in Nimbus.
@interface NICellObject ()

// A property to change the cell class of this cell object.
@property(nonatomic, assign) Class cellClass;

@end

API_DEPRECATED_END
