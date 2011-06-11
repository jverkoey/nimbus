//
// Copyright 2011 Jeff Verkoeyen
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
#import <UIKit/UIKit.h>

#ifdef BASE_PRODUCT_NAME
#import "NimbusLauncher/NILauncherView.h"
#else
#import "NILauncherView.h"
#endif

/**
 * @brief A view controller that displays a launcher view and manages its state.
 * @ingroup Launcher-User-Interface
 */
@interface NILauncherViewController : UIViewController <
  NILauncherDelegate,
  NILauncherDataSource
> {
@private
  NILauncherView* _launcherView;

  NSMutableArray* _pages; // Array< Array<NILauncherItemDetails *> >
}

@end
