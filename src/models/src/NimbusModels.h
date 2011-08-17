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
 * @defgroup NimbusModels Nimbus Models
 * @{
 *
 * A model is an implementation of a data source protocol. Data sources are required by various
 * UI components throughout UIKit and Nimbus. It can be painful to have to rewrite the same
 * data source logic over and over again. Nimbus models allow you to separate the data
 * source logic from your view controller and recycle common functionality throughout
 * your application. You'll find that your view controller can then focus on the broader
 * implementation details rather than implementing dozens of data source methods.
 */

/**
 * @defgroup TableViewModels Table View Models
 *
 * Nimbus table view models make building table views remarkably easy. Rather than implement
 * the data source methods in each table view controller, you can assign a model to
 * self.tableView.dataSource and only think about row creation.
 *
 * Nimbus table view models implement much of the standard functionality required for
 * table views, including section titles, grouped rows, and section indices. By
 * providing this functionality in one object Nimbus can also provide much more
 * efficient implementations than one-off, naive implementations that might otherwise
 * be copied from one controller to another.
 *
 * See example: @link ExampleStaticTableModel.m Static Table Model Creation@endlink
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Dependencies
#import "NimbusCore.h"

#import "NITableViewModel.h"

/**@}*/
