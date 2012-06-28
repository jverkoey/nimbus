//
// Copyright 2012 Manu Cornet
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

#import "NIVerticalPagingScrollView.h"

const CGFloat NIPagingScrollViewDefaultPageVerticalMargin = 10;

@implementation NIVerticalPagingScrollView

@synthesize pageVerticalMargin = _pageVerticalMargin;

// All overridden methods in this class merely mirror the logic between x/y and width/height so
// that everything is vertical instead of horizontal.

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageVerticalMargin = NIPagingScrollViewDefaultPageVerticalMargin;
  }
  return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Page Layout

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPagingScrollView {
  CGRect frame = self.bounds;

  frame.origin.y -= self.pageVerticalMargin;
  frame.size.height += (2 * self.pageVerticalMargin);

  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPageAtIndex:(NSInteger)pageIndex {

  CGRect bounds = self.pagingScrollView.bounds;
  CGRect pageFrame = bounds;

  pageFrame.size.height -= self.pageVerticalMargin * 2;
  pageFrame.origin.y = (bounds.size.height * pageIndex) + self.pageVerticalMargin;

  return pageFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)contentSizeForPagingScrollView {
  CGRect bounds = self.pagingScrollView.bounds;
  return CGSizeMake(bounds.size.width, bounds.size.height * self.numberOfPages);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)adjustOffsetWithMargin:(CGPoint)offset {
  offset.y -= self.pageVerticalMargin;
  return offset;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)pageScrollableDimension {
  return self.pagingScrollView.bounds.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)contentOffsetFromOffset:(CGFloat)offset {
  return CGPointMake(0, offset);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)scrolledPageOffset {
  return self.pagingScrollView.contentOffset.y;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Visible Page Management

///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)currentVisiblePageIndex {
  CGPoint contentOffset = self.pagingScrollView.contentOffset;
  CGSize boundsSize = self.pagingScrollView.bounds.size;
  
  return boundi((NSInteger)(floorf((contentOffset.y + boundsSize.height / 2) / boundsSize.height)
                            + 0.5f),
                0, self.numberOfPages - 1);
}

@end
