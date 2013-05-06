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

#pragma mark - Nimbus Collections

/**
 * @defgroup NimbusCollections Nimbus Collections
 * @{
 *
 * <div id="github" feature="collections"></div>
 *
 * Collection views are a new feature in iOS 6 that enable powerful collections of views to be
 * built.
 *
 * Collection views introduce a new concept of "layout" alongside the existing data source and
 * delegate concepts. Nimbus Collections provides support only for the data source with the
 * NICollectionViewModel. NICollectionViewModel behaves similarly to NITableViewModel in that you
 * provide it with an array of objects which are mapped to cells using a factory.
 */

#pragma mark * Collection View Models

/**
 * @defgroup CollectionViewModels Collection View Models
 */

#pragma mark * Collection View Cell Factory

/**
 * @defgroup CollectionViewCellFactory Collection View Cell Factory
 */

#pragma mark * Model Tools

/**
 * @defgroup CollectionViewTools Collection View Tools
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NICollectionViewActions.h"
#import "NICollectionViewCellFactory.h"
#import "NICollectionViewModel.h"
#import "NIMutableCollectionViewModel.h"

/**@}*/
