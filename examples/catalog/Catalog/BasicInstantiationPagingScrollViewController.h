//
// Copyright 2012 Manu Cornet
// Copyright 2011-2012 Jeff Verkoeyen
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

#import <UIKit/UIKit.h>

@class NIPagingScrollView;

// All docs are in the .m.
@interface BasicInstantiationPagingScrollViewController : UIViewController

// We must retain the paging scroll view in order to autorotate it correctly.
@property (nonatomic, readwrite, retain) NIPagingScrollView* pagingScrollView;

@end
