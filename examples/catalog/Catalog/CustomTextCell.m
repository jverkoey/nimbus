//
// Copyright 2011-2014 Jeff Verkoeyen
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

#import "CustomTextCell.h"

@implementation CustomTextCellObject

+ (instancetype)objectWithTitle:(NSString *)title {
  CustomTextCellObject* object = [[[self class] alloc] init];
  object.title = title;
  return object;
}

#pragma mark - NICollectionViewNibCellObject

- (UINib *)collectionViewCellNib {
  return [UINib nibWithNibName:NSStringFromClass([CustomTextCell class]) bundle:nil];
}

@end

@implementation CustomTextCell

#pragma mark - NICollectionViewCell

- (BOOL)shouldUpdateCellWithObject:(CustomTextCellObject *)object {
  self.label.text = object.title;
  return YES;
}

@end
