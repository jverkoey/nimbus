//
// Copyright 2011 Max Metral
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
 * UITextField leaves a little to be desired on the visual customization front.
 * NITextField attempts to solve the most basic of those gaps so that
 * the CSS subsystem can function properly.
 */
@interface NITextField : UITextField

/**
 * If non-nil, this color will be used to draw the placeholder text.
 * If nil, we will use the system default.
 */
@property (nonatomic,strong) UIColor *placeholderTextColor;

/**
 * If non-nil, this font will be used to draw the placeholder text.
 * else the text field font will be used.
 */
@property (nonatomic,strong) UIFont *placeholderFont;

/**
 * The amount to inset the text by, or zero to use default behavior
 */
@property (nonatomic,assign) UIEdgeInsets textInsets;

@end
