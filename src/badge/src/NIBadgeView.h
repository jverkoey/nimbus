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

#import <UIKit/UIKit.h>

/**
 * A view that mimics the iOS notification badge style.
 *
 * Any NSString can be displayed in this view, though in practice you should only show numbers
 * ranging from 1...99 or the string @"99+". Apple is quite consistent about using the red badge
 * views to represent notification badges, so you should do your best not to attach additional
 * meaning to the red badge.
 *
 *  @image html badge.png "A default NIBadgeView"
 *
 *      @ingroup NimbusBadge
 */
@interface NIBadgeView : UIView

// Text attributes
@property (nonatomic, readwrite, copy) NSString* text;
@property (nonatomic, readwrite, retain) UIFont* font;
@property (nonatomic, readwrite, retain) UIColor* textColor;

// Badge attributes
@property (nonatomic, readwrite, retain) UIColor* tintColor;
@property (nonatomic, readwrite, retain) UIColor* shadowColor;
@property (nonatomic, readwrite, assign) CGSize shadowOffset;
@property (nonatomic, readwrite, assign) CGFloat shadowBlur;

@end

/** @name Accessing the Text Attributes */

/**
 * The text displayed within the badge.
 *
 * As with a UILabel you should call sizeToFit after setting the badgeView properties so that it
 * will update its frame to fit the contents.
 *
 *      @fn NIBadgeView::text
 */

/**
 * The font of the text within the badge.
 *
 * The default font is [UIFont boldSystemFontOfSize:17].
 *
 *      @sa text
 *      @fn NIBadgeView::font
 */

/**
 * The color of the text in the badge.
 *
 * The default color is [UIColor whiteColor].
 *
 *      @fn NIBadgeView::textColor
 */

/** @name Accessing the Badge Attributes */

/**
 * The tint color of the badge.
 *
 * This is the color drawn within the badge's borders.
 *
 * The default color is [UIColor redColor].
 *
 *      @fn NIBadgeView::tintColor
 */

/**
 * The shadow color of the badge.
 *
 * This is the shadow drawn beneath the badge's outline.
 *
 * The default color is [UIColor colorWithWhite:0 alpha:0.5].
 *
 *      @sa shadowOffset
 *      @sa shadowBlur
 *      @fn NIBadgeView::shadowColor
 */

/**
 * The shadow offset (measured in points) for the badge.
 *
 * This is the offset of the shadow drawn beneath the badge's outline.
 *
 * The default value is CGSizeMake(0, 3.f).
 *
 *      @sa shadowColor
 *      @sa shadowBlur
 *      @fn NIBadgeView::shadowOffset
 */

/**
 * The shadow blur (measured in points) for the badge.
 *
 * This is the blur of the shadow drawn beneath the badge's outline.
 *
 * The default value is 3.
 *
 *      @sa shadowOffset
 *      @sa shadowColor
 *      @fn NIBadgeView::shadowBlur
 */
