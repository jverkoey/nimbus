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

@interface MashupViewController : UIViewController<NIAttributedLabelDelegate> {
  NIAttributedLabel *nimbusTitle;
  NIAttributedLabel *label1;
  NIAttributedLabel *label2;
  NIAttributedLabel *label3;
  NIAttributedLabel *label4;
}

@property (nonatomic, retain) IBOutlet NIAttributedLabel *nimbusTitle;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *label1;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *label2;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *label3;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *label4;

@end
