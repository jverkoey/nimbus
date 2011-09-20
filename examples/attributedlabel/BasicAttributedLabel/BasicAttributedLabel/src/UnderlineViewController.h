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

@interface UnderlineViewController : UIViewController {
  NIAttributedLabel *single;
  NIAttributedLabel *thick;
  NIAttributedLabel *ddouble;
  NIAttributedLabel *dot;
  NIAttributedLabel *dash;
  NIAttributedLabel *dashdot;
  NIAttributedLabel *dashdotdot;
  NIAttributedLabel *doubledashdotdot;
}

@property (nonatomic, retain) IBOutlet NIAttributedLabel *single;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *thick;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *ddouble;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *dot;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *dash;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *dashdot;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *dashdotdot;
@property (nonatomic, retain) IBOutlet NIAttributedLabel *doubledashdotdot;

@end
