//
// Copyright 2011-2012 Jeff Verkoeyen
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

#import "NILauncherPageView.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NILauncherPageView()
@property (nonatomic, readwrite, NI_STRONG) NSMutableArray* mutableRecyclableViews;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NILauncherPageView

@synthesize viewRecycler = _viewRecycler;
@synthesize mutableRecyclableViews = _mutableRecyclableViews;
@synthesize contentInset = _contentInset;
@synthesize viewSize = _viewSize;
@synthesize viewMargins = _viewMargins;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithReuseIdentifier:reuseIdentifier])) {
    _mutableRecyclableViews = [NSMutableArray array];

    // The view frames are calculated manually in layoutSubviews.
    self.autoresizesSubviews = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  const CGFloat leftEdge = self.contentInset.left;
  const CGFloat topEdge = self.contentInset.top;
  const CGFloat rightEdge = self.bounds.size.width - self.contentInset.right;
  const CGSize viewSize = self.viewSize;
  const CGSize viewMargins = self.viewMargins;

  CGFloat contentWidth = (self.bounds.size.width - self.contentInset.left - self.contentInset.right);
  NSInteger numberOfColumns = floorf((contentWidth + viewMargins.width) / (viewSize.width + viewMargins.width));
  CGFloat viewWidth = numberOfColumns * viewSize.width;
  CGFloat distributedHorizontalMargin = floorf((contentWidth - viewWidth) / (CGFloat)(numberOfColumns + 1));
  
  const CGFloat horizontalDelta = viewSize.width + distributedHorizontalMargin;
  const CGFloat verticalDelta = viewSize.height + viewMargins.height;

  CGFloat x = leftEdge + distributedHorizontalMargin;
  CGFloat y = topEdge;

  for (UIView* view in self.mutableRecyclableViews) {
    view.frame = CGRectMake(x, y, viewSize.width, viewSize.height);
    x += horizontalDelta;
    if (x + viewSize.width > rightEdge) {
      x = leftEdge + distributedHorizontalMargin;
      y += verticalDelta;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NIRecyclableView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForReuse {
  // You forgot to provide a view recycler.
  NIDASSERT(nil != self.viewRecycler);

  for (UIView<NIRecyclableView>* view in self.mutableRecyclableViews) {
    [view removeFromSuperview];
    [self.viewRecycler recycleView:view];
  }
  [self.mutableRecyclableViews removeAllObjects];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRecyclableView:(UIView<NIRecyclableView> *)view {
  [self addSubview:view];
  [self.mutableRecyclableViews addObject:view];

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)recyclableViews {
  return [self.mutableRecyclableViews copy];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setContentInset:(UIEdgeInsets)contentInset {
  _contentInset = contentInset;

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setviewSize:(CGSize)viewSize {
  _viewSize = viewSize;

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setviewMargins:(CGSize)viewMargins {
  _viewMargins = viewMargins;

  [self setNeedsLayout];
}

@end
