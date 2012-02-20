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

#import "TableViewKeyValue.h"

@implementation TableViewKeyValue

@synthesize key = _key;
@synthesize value = _value;

- (void)dealloc {
  [_key release];
  [_value release];

  [super dealloc];
}

+ (id)objectWithKey:(NSString *)key value:(NSString *)value {
  return [[[self alloc] initWithKey:key value:value] autorelease];
}

- (id)initWithKey:(NSString *)key value:(NSString *)value {
  if ((self = [super init])) {
    _key = [key copy];
    _value = [value copy];
  }
  return self;
}

- (Class)cellClass {
  return [TableViewKeyValueCell class];
}

- (UITableViewCellStyle)cellStyle {
  return UITableViewCellStyleValue2;
}

@end

@implementation TableViewKeyValueCell

- (BOOL)shouldUpdateCellWithObject:(TableViewKeyValue *)object {
  self.textLabel.text = object.key;
  self.detailTextLabel.text = object.value;
  self.accessoryType = UITableViewCellAccessoryNone;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  return YES;
}

@end
