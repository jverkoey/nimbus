//
// Copyright 2012 Manu Cornet
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

#import "SamplePageView.h"

@implementation SamplePageView

@synthesize pageIndex = _pageIndex;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithFrame:CGRectZero])) {
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    _label.font = [UIFont systemFontOfSize:26];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_label];
      
    self.reuseIdentifier = reuseIdentifier;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithReuseIdentifier:nil];
}

- (void)setPageIndex:(NSInteger)pageIndex {
  _pageIndex = pageIndex;
  
  self.label.text = [NSString stringWithFormat:@"This is page %zd", pageIndex];
  
  UIColor* bgColor;
  UIColor* textColor;
  // Change the background and text color depending on the index.
  switch (pageIndex % 4) {
    case 0:
      bgColor = [UIColor redColor];
      textColor = [UIColor whiteColor];
      break;
    case 1:
      bgColor = [UIColor blueColor];
      textColor = [UIColor whiteColor];
      break;
    case 2:
      bgColor = [UIColor yellowColor];
      textColor = [UIColor blackColor];
      break;
    case 3:
      bgColor = [UIColor greenColor];
      textColor = [UIColor blackColor];
      break;
  }
  
  self.backgroundColor = bgColor;
  self.label.textColor = textColor;
  
  [self setNeedsLayout];
}

- (void)prepareForReuse {
  self.label.text = nil;
}

@end
