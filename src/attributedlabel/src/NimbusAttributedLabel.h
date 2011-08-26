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

/**
 * @defgroup NimbusAttributedLabel Nimbus Attributed Label
 * @{
 *
 * The Nimbus Attributed Label is a regular UILabel that utilizes the great power of
 * NSAttributtedString. In essence it transforms a simple label into a fully formattable
 * label using the CoreText framework.
 *
 * <h2>Key Features</h2>
 * 
 * Some of the features that are possible with NIAttributedLabel that you can't achieve with
 * a regular UILabel are:
 *
 * - Underlined text
 * - Justified paragraph style
 * - Link detection
 * - Text stroke
 *
 * @defgroup NimbusAttributedLabel-Protocol Protocol
 *
 * @} */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

#import "NimbusCore.h"
#import "NIAttributedLabel.h"
