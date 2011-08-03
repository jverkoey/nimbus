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

@interface NIBadgeView : UIView {
  NSString* _text;
  UIColor* _tintColor;
  UIFont* _font;
}

/*
 * The text to display within the badge.
 */
@property (nonatomic, readwrite, copy) NSString* text;


/*
 * The tint color of the badge. The default color is red.
 */
@property (nonatomic, readwrite, assign) UIColor* tintColor;


/*
 * The font of the text within the badge. The default is the bold system
 * font of size 13
 */
@property (nonatomic, readwrite, assign) UIFont* font;

@end
