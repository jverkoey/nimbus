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

typedef CGFloat (^NICellDrawRectBlock)(CGRect rect, id object, UITableViewCell* cell);

/**
 * An object that will draw the contents of the cell using a provided block.
 *
 * @ingroup TableCellCatalog
 */
@interface NIDrawRectBlockCellObject : NICellObject
// Designated initializer.
- (id)initWithBlock:(NICellDrawRectBlock)block object:(id)object;
+ (id)objectWithBlock:(NICellDrawRectBlock)block object:(id)object;
@property (nonatomic, copy) NICellDrawRectBlock block;
@property (nonatomic, strong) id object;
@end

/**
 * An object for displaying a single-line title in a table view cell.
 *
 * This object maps by default to a NITextCell and displays the title with a
 * UITableViewCellStyleDefault cell. You can customize the cell class using the
 * NICellObject methods.
 *
 * @ingroup TableCellCatalog
 */
@interface NITitleCellObject : NICellObject
// Designated initializer.
- (id)initWithTitle:(NSString *)title image:(UIImage *)image cellClass:(Class)cellClass userInfo:(id)userInfo;
- (id)initWithTitle:(NSString *)title image:(UIImage *)image;
- (id)initWithTitle:(NSString *)title;
+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image;
+ (id)objectWithTitle:(NSString *)title;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UIImage* image;
@end

/**
 * An object for displaying two lines of text in a table view cell.
 *
 * This object maps by default to a NITextCell and displays the title with a
 * UITableViewCellStyleSubtitle cell. You can customize the cell class using the
 * NICellObject methods.
 *
 * @ingroup TableCellCatalog
 */
@interface NISubtitleCellObject : NITitleCellObject
// Designated initializer.
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image cellClass:(Class)cellClass userInfo:(id)userInfo;
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image;
+ (id)objectWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image;
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
+ (id)objectWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
@property (nonatomic, copy) NSString* subtitle;
@property (nonatomic, assign) UITableViewCellStyle cellStyle;
@end

/**
 * A general-purpose cell for displaying text.
 *
 * When given a NITitleCellObject, will set the textLabel's text with the title.
 * When given a NISubtitleCellObject, will also set the detailTextLabel's text with the subtitle.
 *
 * @ingroup TableCellCatalog
 */
@interface NITextCell : UITableViewCell <NICell>
@end

/**
 * A cell that renders its contents using a block.
 *
 * @ingroup TableCellCatalog
 */
@interface NIDrawRectBlockCell : UITableViewCell <NICell>
@property (nonatomic, strong) UIView* blockView;
@end

/**
 * Initializes the NITitleCellObject with the given title, image, cellClass, and userInfo.
 *
 * This is the designated initializer. Use of this initializer allows for customization of the
 * associated cell class for this object.
 *
 * @fn NITitleCellObject::initWithTitle:image:cellClass:userInfo:
 */

/**
 * Initializes the NITitleCellObject with NITextCell as the cell class and the given title text and
 * image.
 *
 * @fn NITitleCellObject::initWithTitle:image:
 */

/**
 * Initializes the NITitleCellObject with NITextCell as the cell class and the given title text.
 *
 * @fn NITitleCellObject::initWithTitle:
 */

/**
 * Convenience method for initWithTitle:image:.
 *
 * @fn NITitleCellObject::objectWithTitle:image:
 * @returns Autoreleased instance of NITitleCellObject.
 */

/**
 * Convenience method for initWithTitle:.
 *
 * @fn NITitleCellObject::objectWithTitle:
 * @returns Autoreleased instance of NITitleCellObject.
 */

/**
 * The text to be displayed in the cell.
 *
 * @fn NITitleCellObject::title
 */

/**
 * Initializes the NISubtitleCellObject with the given title, subtitle, image, cellClass, and
 * userInfo.
 *
 * This is the designated initializer. Use of this initializer allows for customization of the
 * associated cell class for this object.
 *
 * @fn NISubtitleCellObject::initWithTitle:subtitle:image:cellClass:userInfo:
 */

/**
 * Initializes the NICellObject with NITextCell as the cell class and the given title and subtitle
 * text.
 *
 * @fn NISubtitleCellObject::initWithTitle:subtitle:
 */

/**
 * Convenience method for initWithTitle:subtitle:.
 *
 * @fn NISubtitleCellObject::objectWithTitle:subtitle:
 * @returns Autoreleased instance of NISubtitleCellObject.
 */

/**
 * The text to be displayed in the subtitle portion of the cell.
 *
 * @fn NISubtitleCellObject::subtitle
 */

/**
 * The type of UITableViewCell to instantiate.
 *
 * By default this is UITableViewCellStyleSubtitle.
 *
 * @fn NISubtitleCellObject::cellStyle
 */
