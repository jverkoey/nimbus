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

/**
 * @defgroup NimbusLauncher Nimbus Launcher
 * @{
 *
 * <div id="github" feature="launcher"></div>
 *
 * A launcher view is best exemplified in Apple's home screen interface. It consists of a set
 * of pages that each contain a set of buttons that the user may tap to access a consistent,
 * focused aspect of the application or operating system. The user may swipe the screen to the
 * left or right or tap the pager control at the bottom of the screen to change pages.
 *
 * @image html NILauncherViewControllerExample1.png "Example of an NILauncherViewController as seen in the BasicLauncher demo application."
 *
 * <h2>Minimum Requirements</h2>
 *
 * Required frameworks:
 *
 * - Foundation.framework
 * - UIKit.framework
 *
 * Minimum Operating System: <b>iOS 4.0</b>
 *
 * Source located in <code>src/launcher/src</code>
 */

/**
 * @defgroup NimbusLauncherModel Nimbus Launcher Model
 *
 * The Nimbus Launcher provides a model object that can store all of the launcher data. This model
 * object works similarly to NITableViewModel.
 *
 * Presented below is an example of subclassing a NILauncherViewController and using a
 * NILauncherViewModel to supply the data source information.
 *
@code
@implementation CustomLauncherViewController()
@property (nonatomic, readwrite, retain) NILauncherViewModel* model;
@end

@interface CustomLauncherViewController

@synthesize model = _model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    NSArray* contents =
    [NSArray arrayWithObjects:
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Nimbus" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 2" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 3" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 5" image:image],
      [NILauncherViewObject objectWithTitle:@"Nimbus 6" image:image],
      nil],
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Page 2" image:image],
      nil],
     [NSArray arrayWithObjects:
      [NILauncherViewObject objectWithTitle:@"Page 3" image:image],
      nil],
     nil];

    _model = [[NILauncherViewModel alloc] initWithArrayOfPages:contents delegate:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.launcherView.dataSource = self.model;
}
@end
@endcode
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Dependencies
#import "NimbusCore.h"
#import "NimbusPagingScrollView.h"

#import "NILauncherButtonView.h"
#import "NILauncherViewModel.h"
#import "NILauncherViewObject.h"
#import "NILauncherViewController.h"
#import "NILauncherView.h"

/**@}*/
