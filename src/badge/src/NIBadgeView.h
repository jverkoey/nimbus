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
 * A styled view that mimics the iOS badge on a app icon.
 *
 *      @ingroup NimbusBadge
 *
 * This style comprises of four elements: the main colored background, the
 * white border, the gloss effect and a drop shadow. The tint color of the
 * view is customizable, but defaults to to the standard red. 
 
 * This view is drawn using Quartz which means there are no loading of 
 * streachable images, or laying out subviews; thus creating a highly 
 * performant view. 
 */
@interface NIBadgeView : UIView {
  NSString* _text;
  UIColor* _tintColor;
  UIFont* _font;
  UIColor* _textColor;
}

/*
 * The text to display within the badge.
 *
 *      @attention  If you want the view to rezise based on the text be sure
 *                  be sure to call -sizeToFit after you set the text, as this 
 *                  will not happen automatically.
       
 */
@property (nonatomic, readwrite, copy) NSString* text;


/*
 * The tint color of the badge. The default color is red.
 */
@property (nonatomic, readwrite, assign) UIColor* tintColor;


/*
 * The font of the text within the badge. 
 * The default is bold system font of size 13.
 *
 *      @attention  If you want the view to rezise based on the font size be 
 *                  sure be sure to call -sizeToFit after you set the text, as  
 *                  this will not happen automatically.
 */
@property (nonatomic, readwrite, assign) UIFont* font;


/*
 * The text color for the badge. The default color is white.
 */
@property (nonatomic, readwrite, assign) UIColor* textColor;

@end
