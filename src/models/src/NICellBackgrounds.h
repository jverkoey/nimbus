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

/**
 * The NIGroupedCellBackground class provides support for generating grouped UITableView cell
 * backgrounds.
 *
 *      @ingroup TableCellBackgrounds
 */
@interface NIGroupedCellBackground : NSObject

- (UIImage *)imageForFirst:(BOOL)first last:(BOOL)last highlighted:(BOOL)highlighted;

@property (nonatomic, retain) UIColor* innerBackgroundColor; // Default: [UIColor whiteColor]
@property (nonatomic, retain) NSMutableArray* highlightedInnerGradientColors; // Default: RGBCOLOR(53, 141, 245), RGBCOLOR(16, 93, 230)
@property (nonatomic, assign) CGFloat shadowWidth; // Default: 4
@property (nonatomic, retain) UIColor* shadowColor; // Default: RGBACOLOR(0, 0, 0, 0.3)
@property (nonatomic, retain) UIColor* borderColor; // Default: RGBACOLOR(0, 0, 0, 0.07)
@property (nonatomic, retain) UIColor* dividerColor; // Default: RGBCOLOR(230, 230, 230)

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
