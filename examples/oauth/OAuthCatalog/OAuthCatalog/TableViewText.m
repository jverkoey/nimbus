//
// Copyright 2012 Jeff Verkoeyen
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

#import "TableViewText.h"

@implementation TableViewText

@synthesize object = _object;
@synthesize text = _text;

- (void)dealloc {
  [_object release];
  [_text release];

  [super dealloc];
}

+ (id)objectWithText:(NSString *)text object:(Class)object {
  return [[[self alloc] initWithText:text object:object] autorelease];
}

- (id)initWithText:(NSString *)text object:(Class)object {
  if ((self = [super init])) {
    _text = [text copy];
    _object = [object retain];
  }
  return self;
}

- (Class)cellClass {
  return [TableViewTextCell class];
}

@end

@implementation TableViewTextCell

- (BOOL)shouldUpdateCellWithObject:(TableViewText *)object {
  self.textLabel.text = object.text;
  if ([object.object isKindOfClass:[NSNumber class]]
      || nil == object.object) {
    self.textLabel.textAlignment = UITextAlignmentCenter;
    self.accessoryType = UITableViewCellAccessoryNone;
    if (nil == object.object) {
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
      self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
  } else {
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return YES;
}

@end
