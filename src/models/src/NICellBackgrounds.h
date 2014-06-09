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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "NIPreprocessorMacros.h" /* for weak */

/**
 * The NIGroupedCellAppearance protocol provides support for each cell to adjust their appearance.
 *
 * @ingroup TableCellBackgrounds
 */
@protocol NIGroupedCellAppearance <NSObject>

@optional

/**
 * Determines whether or not to draw a divider between cells. 
 * 
 * If the cell does not implement this method, a cell divider will be provided.
 */
- (BOOL)drawsCellDivider;

@end


// Flags set on the cell's backgroundView's tag property.
typedef enum {
  NIGroupedCellBackgroundFlagIsLast       = (1 << 0),
  NIGroupedCellBackgroundFlagIsFirst      = (1 << 1),
  NIGroupedCellBackgroundFlagInitialized  = (1 << 2),
  NIGroupedCellBackgroundFlagNoDivider    = (1 << 3),
} NIGroupedCellBackgroundFlag;

/**
 * The NIGroupedCellBackground class provides support for generating grouped UITableView cell
 * backgrounds.
 *
 * @ingroup TableCellBackgrounds
 */
@interface NIGroupedCellBackground : NSObject

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted; // Default: drawDivider: True
- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider;

- (id)cacheKeyForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider;
- (NSInteger)backgroundTagForFirst:(BOOL)isFirst last:(BOOL)isLast drawDivider:(BOOL)drawDivider;

@property (nonatomic, strong) UIColor* innerBackgroundColor; // Default: [UIColor whiteColor]
@property (nonatomic, strong) NSMutableArray* highlightedInnerGradientColors; // Default: RGBCOLOR(53, 141, 245), RGBCOLOR(16, 93, 230)
@property (nonatomic, assign) CGFloat shadowWidth; // Default: 4
@property (nonatomic, assign) CGSize shadowOffset; // Default: CGSizeMake(0, 1)
@property (nonatomic, strong) UIColor* shadowColor; // Default: RGBACOLOR(0, 0, 0, 0.3)
@property (nonatomic, strong) UIColor* borderColor; // Default: RGBACOLOR(0, 0, 0, 0.07)
@property (nonatomic, strong) UIColor* dividerColor; // Default: RGBCOLOR(230, 230, 230)
@property (nonatomic, assign) CGFloat borderRadius; // Default: 5

@end

/**
 * Returns an image for use with the given cell configuration.
 *
 * The returned image is cached internally after the first request. Changing any of the display
 * properties will invalidate the cached images.
 *
 * @param first YES will round the top corners.
 * @param last  YES will round the bottom corners.
 * @param highlighed YES will fill the contents with the highlightedInnerGradientColors.
 * @returns A UIImage representing the given configuration.
 * @fn NIGroupedCellBackground::imageForFirst:last:highlighted:
 */

/**
 * Returns an image for use with the given cell configuration.
 *
 * The returned image is cached internally after the first request. Changing any of the display
 * properties will invalidate the cached images.
 *
 *      @param first YES will round the top corners.
 *      @param last  YES will round the bottom corners.
 *      @param highlighed YES will fill the contents with the highlightedInnerGradientColors.
 *      @param drawDivider YES will draw a divider between this and the next cell if necessary.
 *      @returns A UIImage representing the given configuration.
 *      @fn NIGroupedCellBackground::imageForFirst:last:highlighted:drawDivider:
 */

/**
 * Returns a cache key for the images returned by imageForFirst:last:highlighted:drawDivider:
 * Subclaseses that alter the behaviour of imageForFirst:last:highlighted:drawDivider: need to
 * override this method such that different images will have different cache keys. In particular,
 * this this will be necessary if the appearance of the image depends on anything other than the
 * arguments to the imageForFirst:last:highlighted:drawDivider: method.
 *
 *      @param first YES if the image is for the first row in a section
 *      @param last  YES if the image is for the last row in a section
 *      @param highlighted YES if the image is for a highlighted cell
 *      @param drawDivider YES if the image includes a divider
 *      @returns A cache key for an image that matches the given parameters.
 *      @fn NIGroupedCellBackground::cacheKeyForFirst:last:highlighted:drawDivider:
 */

/**
 * Returns a tag for a cell's background image. This is used to prevent a cell's background
 * image from being set again when it already has the correct image. Similar to the cache key,
 * subclasses that alter the behaviour of imageForFirst:last:highlighted:drawDivider: need to
 * override this method, if the appearance of the image depends on anything other than the
 * arguments to the imageForFirst:last:highlighted:drawDivider: method.
 * Note that the highlighted state is irrelevant to the background tag.
 *
 *      @param first YES if the image is for the first row in a section
 *      @param last  YES if the image is for the last row in a section
 *      @param drawDivider YES if the image includes a divider
 *      @returns A tag for an image that matches the given parameters.
 *      @fn NIGroupedCellBackground::backgroundTagForFirst:last:drawDivider:
*/
