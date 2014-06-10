//
// Copyright 2011-2014 NimbusKit
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

#import "BadgedLauncherButtonView.h"

#import "NimbusBadge.h"

@implementation BadgedLauncherViewObject


- (id)initWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber {
  if ((self = [super initWithTitle:title image:image])) {
    _badgeNumber = badgeNumber;
  }
  return self;
}

+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image badgeNumber:(NSInteger)badgeNumber {
  return [[self alloc] initWithTitle:title image:image badgeNumber:badgeNumber];
}

- (Class)buttonViewClass {
  return [BadgedLauncherButtonView class];
}

@end

@implementation BadgedLauncherButtonView


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
    _badgeView = [[NIBadgeView alloc] initWithFrame:CGRectZero];
    _badgeView.backgroundColor = [UIColor clearColor];
    _badgeView.hidden = YES;

    // This ensures that the badge will not eat taps.
    _badgeView.userInteractionEnabled = NO;

    [self addSubview:_badgeView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [self.badgeView sizeToFit];
  // Find the image's top right corner.
  CGPoint imageTopRight = CGPointMake(floorf((self.button.frame.size.width
                                              + [self.button imageForState:UIControlStateNormal].size.width)
                                             / 2.f),
                                      floorf((self.button.frame.size.height
                                              - [self.button imageForState:UIControlStateNormal].size.height)
                                             / 2.f));

  // Center the badge on the image's top right corner.
  self.badgeView.frame = CGRectMake(floorf(imageTopRight.x - self.badgeView.frame.size.width / 2.f),
                                    floorf(imageTopRight.y - self.badgeView.frame.size.height / 3.f),
                                    self.badgeView.frame.size.width, self.badgeView.frame.size.height);
}

- (void)shouldUpdateViewWithObject:(BadgedLauncherViewObject *)object {
  [super shouldUpdateViewWithObject:object];

  NSInteger badgeNumber = NIBoundi(object.badgeNumber, 0, 100);
  if (object.badgeNumber > 0) {
    if (badgeNumber < 100) {
      self.badgeView.text = [NSString stringWithFormat:@"%zd", badgeNumber];
    } else {
      self.badgeView.text = @"99+";
    }
    self.badgeView.hidden = NO;

  } else {
    self.badgeView.hidden = YES;
  }
}

@end
