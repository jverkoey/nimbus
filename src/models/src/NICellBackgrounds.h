//
// Copyright 2012 Jeff Verkoeyen
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

#import "NIPreprocessorMacros.h" /* for NI_WEAK */

/**
 * The NIGroupedCellAppearance protocol provides support for each cell to adjust their appearance.
 *
 *      @ingroup TableCellBackgrounds
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
 *      @ingroup TableCellBackgrounds
 */
@interface NIGroupedCellBackground : NSObject

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted; // Default: drawDivider: True
- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted drawDivider:(BOOL)drawDivider;

@property (nonatomic, NI_STRONG) UIColor* innerBackgroundColor; // Default: [UIColor whiteColor]
@property (nonatomic, NI_STRONG) NSMutableArray* highlightedInnerGradientColors; // Default: RGBCOLOR(53, 141, 245), RGBCOLOR(16, 93, 230)
@property (nonatomic, assign) CGFloat shadowWidth; // Default: 4
@property (nonatomic, assign) CGSize shadowOffset; // Default: CGSizeMake(0, 1)
@property (nonatomic, NI_STRONG) UIColor* shadowColor; // Default: RGBACOLOR(0, 0, 0, 0.3)
@property (nonatomic, NI_STRONG) UIColor* borderColor; // Default: RGBACOLOR(0, 0, 0, 0.07)
@property (nonatomic, NI_STRONG) UIColor* dividerColor; // Default: RGBCOLOR(230, 230, 230)
@property (nonatomic, assign) CGFloat borderRadius; // Default: 5

@end

/**
 * Returns an image for use with the given cell configuration.
 *
 * The returned image is cached internally after the first request. Changing any of the display
 * properties will invalidate the cached images.
 *
 *      @param first YES will round the top corners.
 *      @param last  YES will round the bottom corners.
 *      @param highlighed YES will fill the contents with the highlightedInnerGradientColors.
 *      @returns A UIImage representing the given configuration.
 *      @fn NIGroupedCellBackground::imageForFirst:last:highlighted:
 */
