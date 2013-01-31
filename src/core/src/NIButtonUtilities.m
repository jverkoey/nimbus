//
// Copyright 2011-2013 Jeff Verkoeyen
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

#import "NIButtonUtilities.h"

void NIApplyImageSelectorToButton(SEL selector, id target, UIButton* button) {
  IMP method = [target methodForSelector:selector];
  UIImage* image = nil;

  image = method(target, selector, UIControlStateNormal);
  [button setImage:image forState:UIControlStateNormal];

  image = method(target, selector, UIControlStateHighlighted);
  [button setImage:image forState:UIControlStateHighlighted];

  image = method(target, selector, UIControlStateDisabled);
  [button setImage:image forState:UIControlStateDisabled];

  image = method(target, selector, UIControlStateSelected);
  [button setImage:image forState:UIControlStateSelected];

  UIControlState selectedHighlightState = UIControlStateSelected | UIControlStateHighlighted;
  image = method(target, selector, selectedHighlightState);
  [button setImage:image forState:selectedHighlightState];
}

void NIApplyBackgroundImageSelectorToButton(SEL selector, id target, UIButton* button) {
  IMP method = [target methodForSelector:selector];
  UIImage* image = nil;

  image = method(target, selector, UIControlStateNormal);
  [button setBackgroundImage:image forState:UIControlStateNormal];

  image = method(target, selector, UIControlStateHighlighted);
  [button setBackgroundImage:image forState:UIControlStateHighlighted];

  image = method(target, selector, UIControlStateDisabled);
  [button setBackgroundImage:image forState:UIControlStateDisabled];

  image = method(target, selector, UIControlStateSelected);
  [button setBackgroundImage:image forState:UIControlStateSelected];

  UIControlState selectedHighlightState = UIControlStateSelected | UIControlStateHighlighted;
  image = method(target, selector, selectedHighlightState);
  [button setBackgroundImage:image forState:selectedHighlightState];
}

void NIApplyTitleColorSelectorToButton(SEL selector, id target, UIButton* button) {
  IMP method = [target methodForSelector:selector];
  UIColor* color = nil;

  color = method(target, selector, UIControlStateNormal);
  [button setTitleColor:color forState:UIControlStateNormal];

  color = method(target, selector, UIControlStateHighlighted);
  [button setTitleColor:color forState:UIControlStateHighlighted];

  color = method(target, selector, UIControlStateDisabled);
  [button setTitleColor:color forState:UIControlStateDisabled];

  color = method(target, selector, UIControlStateSelected);
  [button setTitleColor:color forState:UIControlStateSelected];

  UIControlState selectedHighlightState = UIControlStateSelected | UIControlStateHighlighted;
  color = method(target, selector, selectedHighlightState);
  [button setTitleColor:color forState:selectedHighlightState];
}
