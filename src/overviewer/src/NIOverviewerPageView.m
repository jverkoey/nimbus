//
// Copyright 2011 Jeff Verkoeyen
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

#import "NIOverviewerPageView.h"

#ifdef DEBUG

#import "NIOverviewer.h"
#import "NIDeviceInfo.h"
#import "NIOverviewerGraphView.h"
#import "NIOverViewerLogger.h"

static UIEdgeInsets kPagePadding;
static const CGFloat kGraphRightMargin = 5;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerPageView

@synthesize pageTitle = _pageTitle;
@synthesize titleLabel = _titleLabel;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)initialize {
  kPagePadding = UIEdgeInsetsMake(5, 5, 10, 5);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pageTitle);
  _titleLabel = nil;

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIOverviewerPageView *)page {
  return [[[[self class] alloc] initWithFrame:CGRectZero] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel *)label {
  UILabel* label = [[[UILabel alloc] init] autorelease];
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont boldSystemFontOfSize:12];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
  label.shadowOffset = CGSizeMake(0, 1);
  
  return label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.clipsToBounds = YES;

    _titleLabel = [[[UILabel alloc] init] autorelease];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:11];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self addSubview:_titleLabel];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  
  [_titleLabel sizeToFit];
  CGRect frame = _titleLabel.frame;
  frame.origin.x = floorf((self.bounds.size.width - frame.size.width) / 2);
  frame.origin.y = self.bounds.size.height - frame.size.height;
  _titleLabel.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPageTitle:(NSString *)pageTitle {
  if (_pageTitle != pageTitle) {
    [_pageTitle release];
    _pageTitle = [pageTitle copy];

    _titleLabel.text = _pageTitle;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  // No-op.
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerGraphPageView

@synthesize label1 = _label1;
@synthesize label2 = _label2;
@synthesize graphView = _graphView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _label1 = nil;
  _label2 = nil;
  _graphView = nil;

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory", @"Overview Page Title: Memory");
    
    _label1 = [self label];
    [self addSubview:_label1];
    _label2 = [self label];
    [self addSubview:_label2];
    
    _graphView = [[[NIOverviewerGraphView alloc] init] autorelease];
    [self addSubview:_graphView];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat contentWidth = self.frame.size.width - kPagePadding.left - kPagePadding.right;
  CGFloat contentHeight = self.frame.size.height - kPagePadding.top - kPagePadding.bottom;
  
  [_label1 sizeToFit];
  [_label2 sizeToFit];
  
  CGFloat maxLabelWidth = MAX(_label1.frame.size.width,
                              _label2.frame.size.width);
  CGFloat remainingContentWidth = contentWidth - maxLabelWidth - kGraphRightMargin;
  
  CGRect frame = _label1.frame;
  frame.origin.x = kPagePadding.left + remainingContentWidth + kGraphRightMargin;
  frame.origin.y = kPagePadding.top;
  _label1.frame = frame;
  
  frame = _label2.frame;
  frame.origin.x = kPagePadding.left + remainingContentWidth + kGraphRightMargin;
  frame.origin.y = CGRectGetMaxY(_label1.frame);
  _label2.frame = frame;
  
  frame = self.titleLabel.frame;
  frame.origin.x = kPagePadding.left + remainingContentWidth + kGraphRightMargin;
  frame.origin.y = CGRectGetMaxY(_label2.frame);
  self.titleLabel.frame = frame;
  
  _graphView.frame = CGRectMake(kPagePadding.left, kPagePadding.top,
                                remainingContentWidth, contentHeight);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  [_graphView setNeedsDisplay];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerMemoryPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_enumerator);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory", @"Overview Page Title: Memory");
    
    self.graphView.dataSource = self;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  [super update];

  [NIDeviceInfo beginCachedDeviceInfo];

  self.label1.text = [NSString stringWithFormat:@"%@ free",
                      NIStringFromBytes([NIDeviceInfo bytesOfFreeMemory])];
  
  self.label2.text = [NSString stringWithFormat:@"%@ total",
                      NIStringFromBytes([NIDeviceInfo bytesOfTotalMemory])];

  [NIDeviceInfo endCachedDeviceInfo];

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma NIOverviewerGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewXRange:(NIOverviewerGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
  NIOverviewerLogEntry* firstEntry = [deviceLogs firstObject];
  NIOverviewerLogEntry* lastEntry = [deviceLogs lastObject];
  NSTimeInterval interval = [lastEntry.timestamp timeIntervalSinceDate:firstEntry.timestamp];
  return interval;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewerGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
  if ([deviceLogs count] == 0) {
    return 0;
  }

  unsigned long long minY = (unsigned long long)-1;
  unsigned long long maxY = 0;
  for (NIOverviewerDeviceLogEntry* entry in deviceLogs) {
    minY = MIN(entry.bytesOfFreeMemory, minY);
    maxY = MAX(entry.bytesOfFreeMemory, maxY);
  }
  unsigned long long range = maxY - minY;
  _minMemory = minY;
  return ((double)range / 1024.0 / 1024.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
  NI_RELEASE_SAFELY(_enumerator);
  _enumerator = [[[[NIOverviewer logger] deviceLogs] objectEnumerator] retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewerGraphView *)graphView
                       point: (CGPoint *)point {
  NIOverviewerDeviceLogEntry* entry = [_enumerator nextObject];
  if (nil != entry) {
    NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
    NIOverviewerLogEntry* firstEntry = [deviceLogs firstObject];
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:firstEntry.timestamp];
    *point = CGPointMake(interval, ((double)(entry.bytesOfFreeMemory - _minMemory)) / 1024.0 / 1024.0);
  }
  return nil != entry;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerDiskPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_enumerator);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Storage", @"Overview Page Title: Storage");
    
    self.graphView.dataSource = self;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  [super update];
  
  [NIDeviceInfo beginCachedDeviceInfo];
  
  self.label1.text = [NSString stringWithFormat:@"%@ free",
                      NIStringFromBytes([NIDeviceInfo bytesOfFreeDiskSpace])];
  
  self.label2.text = [NSString stringWithFormat:@"%@ total",
                      NIStringFromBytes([NIDeviceInfo bytesOfTotalDiskSpace])];
  
  [NIDeviceInfo endCachedDeviceInfo];
  
  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma NIOverviewerGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewXRange:(NIOverviewerGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
  NIOverviewerLogEntry* firstEntry = [deviceLogs firstObject];
  NIOverviewerLogEntry* lastEntry = [deviceLogs lastObject];
  NSTimeInterval interval = [lastEntry.timestamp timeIntervalSinceDate:firstEntry.timestamp];
  return interval;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewerGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
  if ([deviceLogs count] == 0) {
    return 0;
  }
  
  unsigned long long minY = (unsigned long long)-1;
  unsigned long long maxY = 0;
  for (NIOverviewerDeviceLogEntry* entry in deviceLogs) {
    minY = MIN(entry.bytesOfFreeDiskSpace, minY);
    maxY = MAX(entry.bytesOfFreeDiskSpace, maxY);
  }
  unsigned long long range = maxY - minY;
  _minDiskUse = minY;
  return ((double)range / 1024.0 / 1024.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
  _enumerator = [[[NIOverviewer logger] deviceLogs] objectEnumerator];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewerGraphView *)graphView
                       point: (CGPoint *)point {
  NIOverviewerDeviceLogEntry* entry = [_enumerator nextObject];
  if (nil != entry) {
    // TODO: This doesn't work very well.
    NILinkedList* deviceLogs = [[NIOverviewer logger] deviceLogs];
    NIOverviewerLogEntry* firstEntry = [deviceLogs firstObject];
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:firstEntry.timestamp];
    double difference = ((double)entry.bytesOfFreeDiskSpace / 1024.0 / 1024.0
                         - (double)_minDiskUse / 1024.0 / 1024.0);
    *point = CGPointMake(interval, difference);
  }
  return nil != entry;
}


@end

#endif
