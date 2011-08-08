//
// Copyright 2011 Roger Chapman
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
 * It's common functionality to display a web page within an application without
 * switching out to safari. This controller allows you to open a URL in a browser
 * view and includes common browser functionality such as forward, back, stop and
 * refresh buttons on a toolbar. The toolbar also includes an option to open the
 * URL in safari. The controller displays the document.title in the NavigationBar
 * and includes a spinner when loading.
 *
 * <h2>Adding the Web Controller to Your Application</h2>
 *
 * The Web Controller uses a small number of custom icons that are stored in the
 * NimbusWebController bundle. You must add this bundle to your application, ensuring
 * that you select the "Create Folder References" option and that the bundle is
 * copied in the "Copy Bundle Resources" phase.
 *
 * The bundle can be found at <code>src/webcontroller/resources/NimbusWebController.bundle</code>.
 *
 * <h2>Example Applications</h2>
 *
 * <h3>Basic Web Controller</h3>
 *
 * <a
 * href="https://github.com/jverkoey/nimbus/tree/master/examples/webcontroller/BasicWebController">
 * View the README on GitHub</a>
 *
 * This sample application demos the use of the web controller on iPhone and iPad
 *
 * <h2>Screenshots</h2>
 *
 * @image html webcontroller-iphone-example1.png "Screenshot of a basic web controller on iPhone"
 *
 * <h2>The Web Controller on iPad</h2>
 *
 * With an increase is screen size it makes sence for the web controller to have the control buttons nested
 * withing the navigation bar at the top. 
 * Although the current implementation works on the iPad the toolbar feels wrongly placed.
 * 
 * In a future version we hope to have navigation controls appropriately place for the iPad.
 *
 * @}*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NimbusCore.h"
#import "NIWebController.h"
