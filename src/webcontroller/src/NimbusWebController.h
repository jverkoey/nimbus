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

/**
 * @defgroup NimbusWebController Nimbus Web Controller
 * @{
 *
 * <div id="github" feature="webcontroller"></div>
 *
 * This controller presents a UIWebView with a toolbar containing basic chrome for interacting
 * with it. The chrome shows forward, back, stop and refresh buttons on a toolbar aligned
 * to the bottom of the view controller's view. The toolbar includes an option to open the
 * URL in Safari. If the controller is shown in a navigation controller, self.title will
 * show the current web page's title. A spinner will be shown in the navigation bar's right
 * bar button area if there are any active requests.
 *
 * @image html webcontroller-iphone-example1.png "Screenshot of a basic web controller on the iPhone"
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
 * Source located in <code>src/webcontroller/src</code>
 *
 * <h2>Adding the Web Controller to Your Application</h2>
 *
 * The web controller uses a small number of custom icons that are stored in the NimbusWebController
 * bundle. You must add this bundle to your application, ensuring that you select the "Create Folder
 * References" option and that the bundle is copied in the "Copy Bundle Resources" phase.
 *
 * The bundle can be found at <code>src/webcontroller/resources/NimbusWebController.bundle</code>.
 *
 * @}*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NimbusCore.h"
#import "NIWebController.h"
