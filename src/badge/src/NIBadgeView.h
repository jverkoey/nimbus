//
// Copyright 2011-2014 NimbusKit
// Originally created by Roger Chapman
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
 * On devices running operating systems that support the tintColor property on UIViews, these
 * badges will use the tintColor by default. This behavior may be overwritten by assigning a tint
 * color explicitly.
 *
 *  @image html badge.png "A default NIBadgeView"
 *  @image html badgetinted.png "A NIBadgeView on tintColor-supporting devices"
 *
 * @ingroup NimbusBadge
 */
@interface NIBadgeView : UIView

// Text attributes
@property (nonatomic, copy) NSString* text;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;

// Badge attributes
@property (nonatomic, strong) UIColor* tintColor;
@property (nonatomic, strong) UIColor* shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowBlur;

@end

/** @name Accessing the Text Attributes */

/**
 * The text displayed within the badge.
 *
 * As with a UILabel you should call sizeToFit after setting the badgeView properties so that it
 * will update its frame to fit the contents.
 *
 * @fn NIBadgeView::text
 */

/**
 * The font of the text within the badge.
 *
 * The default font is:
 *
 *   iOS 6: [UIFont boldSystemFontOfSize:17]
 *   iOS 7: [UIFont systemFontOfSize:16]
 *
 * @sa text
 * @fn NIBadgeView::font
 */

/**
 * The color of the text in the badge.
 *
 * The default color is [UIColor whiteColor].
 *
 * @fn NIBadgeView::textColor
 */

/** @name Accessing the Badge Attributes */

/**
 * The tint color of the badge.
 *
 * This is the color drawn within the badge's borders.
 *
 * The default color is
 *
 *   iOS 6: [UIColor redColor].
 *   iOS 7: self.tintColor
 *
 * On devices that support global tintColor (iOS 7) the global tint color is used unless a tint
 * color has been explicitly assigned to this badge view, in which case the assigned tint color will be used.
 *
 * @fn NIBadgeView::tintColor
 */

/**
 * The shadow color of the badge.
 *
 * This is the shadow drawn beneath the badge's outline.
 *
 * The default color is
 *
 *   iOS 6: [UIColor colorWithWhite:0 alpha:0.5].
 *   iOS 7: nil
 *
 * On devices that support global tintColor (iOS 7) it is possible, though not encouraged, to use
 * a shadow on badges.
 *
 * @sa shadowOffset
 * @sa shadowBlur
 * @fn NIBadgeView::shadowColor
 */

/**
 * The shadow offset (measured in points) for the badge.
 *
 * This is the offset of the shadow drawn beneath the badge's outline.
 *
 * The default value is CGSizeMake(0, 3.f).
 *
 * @sa shadowColor
 * @sa shadowBlur
 * @fn NIBadgeView::shadowOffset
 */

/**
 * The shadow blur (measured in points) for the badge.
 *
 * This is the blur of the shadow drawn beneath the badge's outline.
 *
 * The default value is 3.
 *
 * @sa shadowOffset
 * @sa shadowColor
 * @fn NIBadgeView::shadowBlur
 */
