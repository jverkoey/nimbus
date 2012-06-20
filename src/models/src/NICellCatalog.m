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

#import "NICellCatalog.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITitleCellObject

@synthesize title = _title;
@synthesize image = _image;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCellClass:(Class)cellClass userInfo:(id)userInfo {
  return [super initWithCellClass:cellClass userInfo:userInfo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title image:(UIImage *)image {
  if ((self = [self initWithCellClass:[NITextCell class] userInfo:nil])) {
    _title = [title copy];
    _image = image;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title {
  return [self initWithTitle:title image:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithTitle:(NSString *)title image:(UIImage *)image {
  return [[self alloc] initWithTitle:title image:image];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithTitle:(NSString *)title {
  return [[self alloc] initWithTitle:title image:nil];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NISubtitleCellObject

@synthesize subtitle = _subtitle;
@synthesize cellStyle = _cellStyle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
  if ((self = [super initWithTitle:title image:image])) {
    _subtitle = [subtitle copy];
    _cellStyle = UITableViewCellStyleSubtitle;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
  return [self initWithTitle:title subtitle:subtitle image:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image {
  return [[self alloc] initWithTitle:title subtitle:subtitle image:image];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)objectWithTitle:(NSString *)title subtitle:(NSString *)subtitle {
  return [[self alloc] initWithTitle:title subtitle:subtitle image:nil];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NITextCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithStyle:style reuseIdentifier:[reuseIdentifier stringByAppendingFormat:@"%d", style]])) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  [super prepareForReuse];

  self.imageView.image = nil;
  self.textLabel.text = nil;
  self.detailTextLabel.text = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldUpdateCellWithObject:(id)object {
  if ([object isKindOfClass:[NITitleCellObject class]]) {
    NITitleCellObject* titleObject = object;
    self.textLabel.text = titleObject.title;
    self.imageView.image = titleObject.image;
  }
  if ([object isKindOfClass:[NISubtitleCellObject class]]) {
    NISubtitleCellObject* subtitleObject = object;
    self.detailTextLabel.text = subtitleObject.subtitle;
  }
  return YES;
}

@end
