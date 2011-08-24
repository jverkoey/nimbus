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

// In standard UI text alignment we do not have justify, however we can justify in CoreText
#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)

#import <UIKit/UIKit.h>

@class NIAttributedLabel;
@protocol NIAttributedLabelDelegate <NSObject>
@optional
-(void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectLink:(NSURL*)url;
@end

/**
 * A UILabel that utilizes NSAttributedString
 *
 *      @ingroup NimbusAttributedLabel
 *
 *
 */

@interface NIAttributedLabel : UILabel {
  NSMutableAttributedString*  _attributedText;
  
  CTFrameRef                  _textFrame;
	CGRect                      _drawingRect;
  NSTextCheckingResult*       _currentLink;
}

/**
 * The attributted string to display
 *
 * Use this instead of the inherited text property on UILabel
 */
@property(nonatomic, copy) NSAttributedString* attributedText;

@property(nonatomic, assign) IBOutlet id<NIAttributedLabelDelegate> delegate;

@end
