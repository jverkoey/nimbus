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

#import "NIOverviewPageView.h"

#if defined(DEBUG) || defined(NI_DEBUG)

#import "NIOverview.h"
#import "NIOverviewView.h"
#import "NIDeviceInfo.h"
#import "NIOverviewGraphView.h"
#import "NIOverviewLogger.h"
#import <QuartzCore/QuartzCore.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static UIEdgeInsets kPagePadding;
static const CGFloat kGraphRightMargin = 5;

@interface NSObject ()
- (id)initWithMemoryCache:(NIMemoryCache *)memoryCache;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewPageView

@synthesize pageTitle = _pageTitle;
@synthesize titleLabel = _titleLabel;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)initialize {
  kPagePadding = UIEdgeInsetsMake(5, 5, 10, 5);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIOverviewPageView *)page {
  return [[[self class] alloc] initWithFrame:CGRectZero];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel *)label {
  UILabel* label = [[UILabel alloc] init];
  label.backgroundColor = [UIColor clearColor];
  label.font = [UIFont boldSystemFontOfSize:12];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
  label.shadowOffset = CGSizeMake(0, 1);
  
  return label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.clipsToBounds = YES;

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:11];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.8f];
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
@implementation NIOverviewGraphPageView

@synthesize label1 = _label1;
@synthesize label2 = _label2;
@synthesize graphView = _graphView;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory", @"Overview Page Title: Memory");

    _label1 = [self label];
    [self addSubview:_label1];
    _label2 = [self label];
    [self addSubview:_label2];
    
    _graphView = [[NIOverviewGraphView alloc] init];
    _graphView.dataSource = self;
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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOverviewGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewXRange:(NIOverviewGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverview logger] deviceLogs];
  NIOverviewLogEntry* firstEntry = [deviceLogs firstObject];
  NIOverviewLogEntry* lastEntry = [deviceLogs lastObject];
  NSTimeInterval interval = [lastEntry.timestamp timeIntervalSinceDate:firstEntry.timestamp];
  return (CGFloat)interval;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewGraphView *)graphView {
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewGraphView *)graphView
                       point: (CGPoint *)point {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)initialTimestamp {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetEventIterator {
  _eventEnumerator = [[[NIOverview logger] eventLogs] objectEnumerator];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextEventInGraphView: (NIOverviewGraphView *)graphView
                      xValue: (CGFloat *)xValue
                       color: (UIColor **)color {
  static NSArray* sEventColors = nil;
  if (nil == sEventColors) {
    sEventColors = [NSArray arrayWithObjects:
                     [UIColor redColor], // NIOverviewEventDidReceiveMemoryWarning
                     nil];
  }
  NIOverviewEventLogEntry* entry = [_eventEnumerator nextObject];
  if (nil != entry) {
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:[self initialTimestamp]];
    *xValue = (CGFloat)interval;
    *color = [sEventColors objectAtIndex:entry.type];
  }
  return nil != entry;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewMemoryPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory", @"Overview Page Title: Memory");
    
    self.graphView.dataSource = self;

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    // We still want to be able to drag the pages.
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
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
- (void)didTap:(UIGestureRecognizer *)gesture {
  // Simulate low memory warning while tapping on NIOverviewMemoryPageView
  [NIDeviceInfo simulateLowMemoryWarning];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOverviewGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverview logger] deviceLogs];
  if ([deviceLogs count] == 0) {
    return 0;
  }

  unsigned long long minY = (unsigned long long)-1;
  unsigned long long maxY = 0;
  for (NIOverviewDeviceLogEntry* entry in deviceLogs) {
    minY = MIN(entry.bytesOfFreeMemory, minY);
    maxY = MAX(entry.bytesOfFreeMemory, maxY);
  }
  unsigned long long range = maxY - minY;
  _minMemory = minY;
  return (CGFloat)((double)range / 1024.0 / 1024.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
  _enumerator = [[[NIOverview logger] deviceLogs] objectEnumerator];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)initialTimestamp {
  NILinkedList* deviceLogs = [[NIOverview logger] deviceLogs];
  NIOverviewLogEntry* firstEntry = [deviceLogs firstObject];
  return firstEntry.timestamp;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewGraphView *)graphView
                       point: (CGPoint *)point {
  NIOverviewDeviceLogEntry* entry = [_enumerator nextObject];
  if (nil != entry) {
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:[self initialTimestamp]];
    *point = CGPointMake((CGFloat)interval,
                         (CGFloat)(((double)(entry.bytesOfFreeMemory - _minMemory))
                                   / 1024.0 / 1024.0));
  }
  return nil != entry;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewDiskPageView


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
#pragma mark -
#pragma mark NIOverviewGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewGraphView *)graphView {
  NILinkedList* deviceLogs = [[NIOverview logger] deviceLogs];
  if ([deviceLogs count] == 0) {
    return 0;
  }
  
  unsigned long long minY = (unsigned long long)-1;
  unsigned long long maxY = 0;
  for (NIOverviewDeviceLogEntry* entry in deviceLogs) {
    minY = MIN(entry.bytesOfFreeDiskSpace, minY);
    maxY = MAX(entry.bytesOfFreeDiskSpace, maxY);
  }
  unsigned long long range = maxY - minY;
  _minDiskUse = minY;
  return (CGFloat)((double)range / 1024.0 / 1024.0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
  _enumerator = [[[NIOverview logger] deviceLogs] objectEnumerator];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)initialTimestamp {
  NILinkedList* deviceLogs = [[NIOverview logger] deviceLogs];
  NIOverviewLogEntry* firstEntry = [deviceLogs firstObject];
  return firstEntry.timestamp;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewGraphView *)graphView
                       point: (CGPoint *)point {
  NIOverviewDeviceLogEntry* entry = [_enumerator nextObject];
  if (nil != entry) {
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:[self initialTimestamp]];
    double difference = ((double)entry.bytesOfFreeDiskSpace / 1024.0 / 1024.0
                         - (double)_minDiskUse / 1024.0 / 1024.0);
    *point = CGPointMake((CGFloat)interval, (CGFloat)difference);
  }
  return nil != entry;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewConsoleLogPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel *)label {
  UILabel* label = [[UILabel alloc] init];
  
  label.font = [UIFont boldSystemFontOfSize:11];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
  label.shadowOffset = CGSizeMake(0, 1);
  label.backgroundColor = [UIColor clearColor];
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.numberOfLines = 0;
  
  return label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Logs", @"Overview Page Title: Logs");

    self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5f];

    _logScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _logScrollView.showsHorizontalScrollIndicator = NO;
    _logScrollView.alwaysBounceVertical = YES;
    _logScrollView.contentInset = kPagePadding;

    _logScrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];

    [self addSubview:_logScrollView];

    _logLabel = [self label];
    [_logScrollView addSubview:_logLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didAddLog:)
                                                 name: NIOverviewLoggerDidAddConsoleLog
                                               object: nil];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)contentSizeChanged {
  BOOL isBottomNearby = NO;
  if (_logScrollView.contentOffset.y + _logScrollView.bounds.size.height
      >= _logScrollView.contentSize.height - _logScrollView.bounds.size.height) {
    isBottomNearby = YES;
  }
  
  _logScrollView.frame = CGRectMake(0, 0,
                                    self.bounds.size.width,
                                    self.bounds.size.height);
  
  CGSize labelSize = [_logLabel.text sizeWithFont: _logLabel.font
                                constrainedToSize: CGSizeMake(_logScrollView.bounds.size.width,
                                                              CGFLOAT_MAX)
                                    lineBreakMode: _logLabel.lineBreakMode];
  _logLabel.frame = CGRectMake(0, 0,
                               labelSize.width, labelSize.height);
  
  _logScrollView.contentSize = CGSizeMake(_logScrollView.bounds.size.width
                                          - kPagePadding.left - kPagePadding.right,
                                          _logLabel.frame.size.height);
  
  if (isBottomNearby) {
    _logScrollView.contentOffset = CGPointMake(-kPagePadding.left,
                                               MAX(_logScrollView.contentSize.height
                                                   - _logScrollView.bounds.size.height
                                                   + kPagePadding.top,
                                                   -kPagePadding.top));
    [_logScrollView flashScrollIndicators];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  [self contentSizeChanged];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect labelFrame = self.titleLabel.frame;
  labelFrame.origin.x = (self.bounds.size.width
                         - kPagePadding.right - self.titleLabel.frame.size.width);
  labelFrame.origin.y = (self.bounds.size.height
                         - kPagePadding.bottom - self.titleLabel.frame.size.height);
  self.titleLabel.frame = labelFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAddLog:(NSNotification *)notification {
  NIOverviewConsoleLogEntry* entry = [[notification userInfo] objectForKey:@"entry"];

  static NSDateFormatter* formatter = nil;
  if (nil == formatter) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterNoStyle];
  }

  NSString* formattedLog = [NSString stringWithFormat:@"%@: %@",
                            [formatter stringFromDate:entry.timestamp],
                            entry.log];

  if (nil != _logLabel.text) {
    _logLabel.text = [_logLabel.text stringByAppendingFormat:@"\n%@", formattedLog];
  } else {
    _logLabel.text = formattedLog;
  }
  
  [self contentSizeChanged];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewMaxLogLevelPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel *)label {
  UILabel* label = [[UILabel alloc] init];
  
  label.font = [UIFont boldSystemFontOfSize:11];
  label.textColor = [UIColor whiteColor];
  label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
  label.shadowOffset = CGSizeMake(0, 1);
  label.backgroundColor = [UIColor clearColor];
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.numberOfLines = 0;
  
  return label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateLabels {
  _warningLogLevelLabel.textColor = [_warningLogLevelLabel.textColor colorWithAlphaComponent:
                                     (NIMaxLogLevel >= NILOGLEVEL_WARNING) ? 1 : 0.6f];
  _infoLogLevelLabel.textColor = [_infoLogLevelLabel.textColor colorWithAlphaComponent:
                                  (NIMaxLogLevel >= NILOGLEVEL_INFO) ? 1 : 0.6f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Max Log Level", @"Overview Page Title: Max Log Level");

    self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5f];

    _logLevelSlider = [[UISlider alloc] init];
    _logLevelSlider.minimumValue = 1;
    _logLevelSlider.maximumValue = 5;
    [_logLevelSlider addTarget: self
                        action: @selector(didChangeSliderValue:)
              forControlEvents: UIControlEventValueChanged];
    [self addSubview:_logLevelSlider];

    _logLevelSlider.value = NIMaxLogLevel;

    _errorLogLevelLabel = [self label];
    _warningLogLevelLabel = [self label];
    _infoLogLevelLabel = [self label];

    _errorLogLevelLabel.text = NSLocalizedString(@"Error", @"Maximum log level: error");
    _warningLogLevelLabel.text = NSLocalizedString(@"Warning", @"Maximum log level: warning");
    _infoLogLevelLabel.text = NSLocalizedString(@"Info", @"Maximum log level: info");

    [self addSubview:_errorLogLevelLabel];
    [self addSubview:_warningLogLevelLabel];
    [self addSubview:_infoLogLevelLabel];

    [self updateLabels];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat contentSize = self.bounds.size.width - kPagePadding.left - kPagePadding.right;

  _logLevelSlider.frame = CGRectMake(kPagePadding.left, kPagePadding.top,
                                     contentSize,
                                     20);

  CGFloat sliderBottom = CGRectGetMaxY(_logLevelSlider.frame);

  [_errorLogLevelLabel sizeToFit];
  _errorLogLevelLabel.frame = CGRectMake(kPagePadding.left, sliderBottom,
                                         _errorLogLevelLabel.frame.size.width,
                                         _errorLogLevelLabel.frame.size.height);

  [_warningLogLevelLabel sizeToFit];
  _warningLogLevelLabel.frame = CGRectMake(floorf((self.bounds.size.width
                                                   - _warningLogLevelLabel.frame.size.width) / 2),
                                           sliderBottom,
                                           _warningLogLevelLabel.frame.size.width,
                                           _warningLogLevelLabel.frame.size.height);

  [_infoLogLevelLabel sizeToFit];
  _infoLogLevelLabel.frame = CGRectMake(kPagePadding.left + contentSize
                                        - _infoLogLevelLabel.frame.size.width,
                                        sliderBottom,
                                        _infoLogLevelLabel.frame.size.width,
                                        _infoLogLevelLabel.frame.size.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didChangeSliderValue:(UISlider *)slider {
  slider.value = roundf(slider.value);
  NIMaxLogLevel = lround(slider.value);

  [self updateLabels];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIOverviewMemoryCacheEntry : NSObject
@property (nonatomic, readwrite, retain) NSDate* timestamp;
@property (nonatomic, readwrite, assign) NSUInteger numberOfObjects;
@end
@implementation NIOverviewMemoryCacheEntry
@synthesize timestamp;
@synthesize numberOfObjects;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIOverviewImageMemoryCacheEntry : NIOverviewMemoryCacheEntry
@property (nonatomic, readwrite, assign) NSUInteger numberOfPixels;
@property (nonatomic, readwrite, assign) NSUInteger maxNumberOfPixels;
@property (nonatomic, readwrite, assign) NSUInteger maxNumberOfPixelsUnderStress;
@end
@implementation NIOverviewImageMemoryCacheEntry
@synthesize numberOfPixels;
@synthesize maxNumberOfPixels;
@synthesize maxNumberOfPixelsUnderStress;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NIOverviewMemoryCachePageView()
@property (nonatomic, readwrite, assign) unsigned long long minValue;
@property (nonatomic, readwrite, retain) NSEnumerator* enumerator;
@property (nonatomic, readwrite, retain) NILinkedList* history;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewMemoryCachePageView

@synthesize minValue = _minValue;
@synthesize enumerator = _enumerator;
@synthesize history = _history;
@synthesize cache = _cache;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory Cache", @"Overview Page Title: Memory Cache");
    self.cache = [Nimbus imageMemoryCache];

    self.history = [NILinkedList linkedList];
    self.graphView.dataSource = self;

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    // We still want to be able to drag the pages.
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (id)pageWithCache:(NIMemoryCache *)cache {
  NIOverviewMemoryCachePageView* pageView = [[[self class] alloc] initWithFrame:CGRectZero];
  pageView.cache = cache;
  return pageView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  [super update];

  NIOverviewMemoryCacheEntry* entry = nil;
  // Update the labels.
  if ([self.cache isKindOfClass:[NIImageMemoryCache class]]) {
    NIImageMemoryCache* imageCache = (NIImageMemoryCache *)self.cache;
    self.label1.text = [NSString stringWithFormat:@"%@ total",
                        NIStringFromBytes(imageCache.numberOfPixels)];

    self.label2.text = [NSString stringWithFormat:@"%@|%@",
                        NIStringFromBytes(imageCache.maxNumberOfPixelsUnderStress),
                        NIStringFromBytes(imageCache.maxNumberOfPixels)];

    NIOverviewImageMemoryCacheEntry* imageEntry = [[NIOverviewImageMemoryCacheEntry alloc] init];
    imageEntry.numberOfPixels = imageCache.numberOfPixels;
    imageEntry.maxNumberOfPixels = imageCache.maxNumberOfPixels;
    imageEntry.maxNumberOfPixelsUnderStress = imageCache.maxNumberOfPixelsUnderStress;
    entry = imageEntry;

  } else {
    self.label1.text = [NSString stringWithFormat:@"%d objects", self.cache.count];
    self.label2.text = nil;

    entry = [[NIOverviewMemoryCacheEntry alloc] init];
  }

  entry.timestamp = [NSDate date];
  entry.numberOfObjects = self.cache.count;
  [self.history addObject:entry];

  NSDate* cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-[NIOverview logger].oldestLogAge];
  while ([[(NIOverviewMemoryCacheEntry *)self.history.firstObject timestamp] compare:cutoffDate] == NSOrderedAscending) {
    [self.history removeFirstObject];
  }

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didTap:(UIGestureRecognizer *)gesture {
  UIViewController* rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
  if ([rootController respondsToSelector:@selector(pushViewController:animated:)]) {
    // We want a weak dependency on the overview memory cache controller so that we don't force
    // a dependency on the models feature.
    Class class = NSClassFromString(@"NIOverviewMemoryCacheController");
    if (nil != class) {
      id instance = [class alloc];
      SEL initSelector = @selector(initWithMemoryCache:);
      NIDASSERT([instance respondsToSelector:initSelector]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      UIViewController* controller = [instance performSelector:initSelector withObject:self.cache];
#pragma clang diagnostic pop
      controller.title = @"Memory Cache";
      [(id)rootController pushViewController:controller animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NIOverviewGraphViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)graphViewYRange:(NIOverviewGraphView *)graphView {
  if (0 == self.history.count) {
    return 0;
  }

  unsigned long long minY = (unsigned long long)-1;
  unsigned long long maxY = 0;

  if ([self.cache isKindOfClass:[NIImageMemoryCache class]]) {
    // For image caches we want to show the number of pixels over time.
    for (NIOverviewImageMemoryCacheEntry* entry in self.history) {
      minY = MIN(entry.numberOfPixels, minY);
      maxY = MAX(entry.numberOfPixels, maxY);
    }
    unsigned long long range = maxY - minY;
    self.minValue = minY;
    return (CGFloat)((double)range / 1024.0 / 1024.0);

  } else {
    // For regular memory caches we'll just show the count of objects.
    for (NIOverviewMemoryCacheEntry* entry in self.history) {
      minY = MIN(entry.numberOfObjects, minY);
      maxY = MAX(entry.numberOfObjects, maxY);
    }
    unsigned long long range = maxY - minY;
    self.minValue = minY;
    return (CGFloat)range;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetPointIterator {
  _enumerator = [self.history objectEnumerator];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)initialTimestamp {
  NIOverviewMemoryCacheEntry* entry = self.history.firstObject;
  return entry.timestamp;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)nextPointInGraphView: (NIOverviewGraphView *)graphView
                       point: (CGPoint *)point {
  NIOverviewMemoryCacheEntry* entry = [_enumerator nextObject];
  if (nil != entry) {
    NSTimeInterval interval = [entry.timestamp timeIntervalSinceDate:[self initialTimestamp]];

    if ([self.cache isKindOfClass:[NIImageMemoryCache class]]) {
      NIOverviewImageMemoryCacheEntry* imageEntry = (NIOverviewImageMemoryCacheEntry *)entry;
      *point = CGPointMake((CGFloat)interval,
                           (CGFloat)(((double)(imageEntry.numberOfPixels - self.minValue))
                                     / 1024.0 / 1024.0));

    } else {
      *point = CGPointMake((CGFloat)interval,
                           (CGFloat)(entry.numberOfObjects - self.minValue));
    }
  }
  return nil != entry;
}

@end

typedef BOOL (^NIViewRecursionBlock)(UIView *view);
static const CGFloat kButtonSize = 44;
static const CGFloat kButtonMargin = 5;
static const CGFloat kMinimumFontSize = 12;
static const CGFloat kPadding = 10;
static const CGFloat kAvoidedTopHeight = 80;
static const NSTimeInterval kAutoresizingAnimationDuration = 2;

@class NIViewInspectionView;
static NIViewInspectionView *visibleInspectionView = nil;

@interface NIViewInspectionView : UIView
@end

@implementation NIViewInspectionView {
  UIView *touchedView_;
  UIView *interactingView_;

  // For displaying the autoresizing mask visually.
  UIView *containerView_;
  UIView *autoresizingView_;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // We want our touches to hit the real application views beneath this view.
    self.userInteractionEnabled = NO;
    self.opaque = NO;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGRect bounds = self.bounds;
  CGContextRef cx = UIGraphicsGetCurrentContext();

  CGContextClearRect(cx, bounds);

  if (touchedView_) {
    [[UIColor colorWithWhite:0 alpha:0.8f] set];
    UIRectFill(bounds);

    CGRect frame = [touchedView_ convertRect:touchedView_.bounds toView:self];
    if (!CGRectEqualToRect(frame, bounds)) {
      CGContextClearRect(cx, frame);
    }
    [[UIColor colorWithWhite:0 alpha:0.1f] set];
    UIRectFrame(frame);

    [[UIColor whiteColor] set];

    CGPoint offset = CGPointMake(kPadding, NIStatusBarHeight() + kPadding);
    if (CGRectGetMaxY(frame) - kAvoidedTopHeight < offset.y) {
      offset.y += kAvoidedTopHeight;
    }

    offset.y += [self drawTitle:@"Responder: "
                          value:NSStringFromClass([interactingView_ class])
                        atPoint:offset];
    offset.y += [self drawTitle:@"Touched: "
                          value:NSStringFromClass([touchedView_ class])
                        atPoint:offset];
    offset.y += [self drawTitle:@"Frame: "
                          value:NSStringFromCGRect(touchedView_.frame)
                        atPoint:offset];
    UILabel *label = nil;
    if ([touchedView_ isKindOfClass:[UILabel class]]) {
      label =  (UILabel *)touchedView_;
    } else if ([touchedView_ isKindOfClass:[UIButton class]]) {
      UIButton *button =  (UIButton *)touchedView_;
      label =  (UILabel *)button.titleLabel;
      // Display button title frame as well.
      offset.y += [self drawTitle:@"Title frame: "
                            value:NSStringFromCGRect(label.frame)
                          atPoint:offset];
    }
    if (label) {
      const CGFloat *components = CGColorGetComponents(label.textColor.CGColor);
      offset.y += [self drawTitle:@"Font: "
                            value:[NSString stringWithFormat:@"%0.1fpx, "
                                   "color: (%x,%x,%x)",
                                   label.font.pointSize,
                                   (int)(components[0]*255),
                                   (int)(components[1]*255),
                                   (int)(components[2]*255)]
                          atPoint:offset];
    }

  } else {
    [[UIColor colorWithWhite:1 alpha:0.5f] set];
    UIRectFill(bounds);

    [[UIColor colorWithWhite:0.5 alpha:0.5f] set];
    UIRectFrame(NIRectShift(CGRectInset(bounds, kPadding, kPadding),
                            0,
                            NIStatusBarHeight()));
  }
}

- (CGFloat)drawTitle:(NSString *)title
               value:(NSString *)value
             atPoint:(CGPoint)point {
  UIFont *infoFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
  CGSize size = [title drawAtPoint:point withFont:infoFont];
  point = CGPointMake(point.x + size.width, point.y);
  CGRect bounds = self.bounds;
  [value drawAtPoint:point
      forWidth:bounds.size.width - point.x - kPadding
      withFont:infoFont
      minFontSize:kMinimumFontSize
      actualFontSize:nil
      lineBreakMode:NSLineBreakByTruncatingMiddle
      baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  return size.height;
}

- (void)setTouchedView:(UIView *)view
       interactingView:(UIView *)interactingView {
  interactingView_ = interactingView;

  if (touchedView_ != view) {
    touchedView_ = view;

    [containerView_ removeFromSuperview];

    containerView_ = [[UIView alloc] init];
    containerView_.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7f];
    autoresizingView_ = [[UIView alloc] init];
    autoresizingView_.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    autoresizingView_.layer.borderColor =
        [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    autoresizingView_.layer.borderWidth = 1;
    autoresizingView_.autoresizingMask = view.autoresizingMask;
    [self addSubview:containerView_];
    [containerView_ addSubview:autoresizingView_];

    containerView_.frame =
        CGRectMake(kPadding,
                   self.bounds.size.height - 80 - 30 - kPadding, 100, 80);
    autoresizingView_.frame = CGRectInset(containerView_.bounds, 20, 20);

    void (^animationBlock)(void) = ^{
      containerView_.frame = NIRectExpand(containerView_.frame, 50, 30);
    };

    [UIView animateWithDuration:kAutoresizingAnimationDuration
                          delay:0
                        options:(UIViewAnimationOptionRepeat
                                 | UIViewAnimationOptionAutoreverse)
                     animations:animationBlock
                     completion:nil];
  }

  [self setNeedsDisplay];
}

@end

@interface UIView (DebugUtilities)
@property (nonatomic, assign) BOOL debugColorizeSubviews;
- (void)recurseWithCallback:(NIViewRecursionBlock)callback;
@end

@implementation UIView (DebugUtilities)

@dynamic debugColorizeSubviews;

- (void)recurseWithCallback:(NIViewRecursionBlock)callback {
  if (callback(self)) {
    for (UIView *subview in self.subviews) {
      [subview recurseWithCallback:callback];
    }
  }
}

@end

@interface UIWindow (Interceptor)
@end

@implementation UIWindow (Interceptor)

- (void)_azInterceptSendEvent:(UIEvent *)event {
  if (event.type == UIEventTypeTouches) {
    UITouch *touch = [[event allTouches] anyObject];

    if ([touch.view isDescendantOfView:[NIOverview view]]) {
      [self _azInterceptSendEvent:event];
    } else {
      UIView *interactingView = touch.view;
      CGPoint touchPoint = [touch locationInView:self];
      __block UIView *touchedView = [self hitTest:[touch locationInView:self]
                                        withEvent:event];
      [touchedView recurseWithCallback:^(UIView *view) {
        CGPoint viewPoint = [view convertPoint:touchPoint fromView:self];
        if ([view pointInside:viewPoint withEvent:event]) {
          touchedView = view;
          if ([touchedView isKindOfClass:[UIButton class]]
              || [touchedView isKindOfClass:[UITextField class]]) {
            // Don't select any subviews of these classes.
            return NO;
          }
        }
        return YES;
      }];
      [visibleInspectionView setTouchedView:touchedView
                            interactingView:interactingView];
    }
  } else {
    [self _azInterceptSendEvent:event];
  }
}

@end

@implementation NIInspectionOverviewPageView {
  NSArray *buttons_;
  NIViewInspectionView *inspectionView_;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = @"Inspection";

    UIButton *colorizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorizeButton setBackgroundImage:[self backgroundForColorizeButton]
                              forState:UIControlStateNormal];
    colorizeButton.frame =
        CGRectMake(0, 0, kButtonSize, kButtonSize);
    [self addSubview:colorizeButton];
    [colorizeButton addTarget:self
                       action:@selector(didTapColorizeButton:)
             forControlEvents:UIControlEventTouchUpInside];

    UIButton *pinpointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pinpointButton setBackgroundImage:[self backgroundForPinpointButton]
                              forState:UIControlStateNormal];
    pinpointButton.frame =
        CGRectMake(0, 0, kButtonSize, kButtonSize);
    [self addSubview:pinpointButton];
    [pinpointButton addTarget:self
                       action:@selector(didTapPinpointButton:)
             forControlEvents:UIControlEventTouchUpInside];

    buttons_ = [NSArray arrayWithObjects:colorizeButton, pinpointButton, nil];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat leftEdge = kButtonMargin;
  for (UIButton *button in buttons_) {
    CGRect frame = button.frame;
    frame.origin = CGPointMake(leftEdge, kButtonMargin);
    button.frame = frame;

    leftEdge = CGRectGetMaxX(button.frame) + kButtonMargin;
  }
}

#pragma mark - User Actions

- (void)didTapColorizeButton:(UIButton *)button {
  [[self rootView] recurseWithCallback:^(UIView *view) {
    if ([view respondsToSelector:@selector(setDebugColorizeSubviews:)]) {
      [(id)view setDebugColorizeSubviews:YES];
      [view setNeedsLayout];
    }
    return YES;
  }];
}

- (void)didTapPinpointButton:(UIButton *)button {
  NISwapInstanceMethods([UIWindow class],
                        @selector(sendEvent:),
                        @selector(_azInterceptSendEvent:));

  if (inspectionView_ != nil) {
    [inspectionView_ removeFromSuperview];
    inspectionView_ = nil;
    visibleInspectionView = nil;
    return;
  }

  UIView *rootView = [self rootView];
  [rootView endEditing:YES];
  inspectionView_ = [[NIViewInspectionView alloc] initWithFrame:rootView.bounds];
  inspectionView_.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
  [rootView addSubview:inspectionView_];
  visibleInspectionView = inspectionView_;
}

#pragma mark - Utilities

- (UIView *)rootView {
  return [UIApplication sharedApplication].keyWindow.rootViewController.view;
}

#pragma mark - Button Images

- (UIColor *)randomColor {
  return RGBCOLOR(arc4random_uniform(128) + 128,
                  arc4random_uniform(128) + 128,
                  arc4random_uniform(128) + 128);
}

- (UIImage *)backgroundForColorizeButton {
  CGRect imageRect = CGRectMake(0, 0, kButtonSize, kButtonSize);
  UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);

  CGContextRef cx = UIGraphicsGetCurrentContext();

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  NSArray *gradientColors = [NSMutableArray arrayWithObjects:
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             (id)[self randomColor].CGColor,
                             nil];
  CGGradientRef gradient =
  CGGradientCreateWithColors(colorSpace,
                             (__bridge CFArrayRef)gradientColors,
                             nil);
  CGColorSpaceRelease(colorSpace);
  colorSpace = nil;

  CGContextDrawRadialGradient(cx,
                              gradient,
                              CGPointMake(0, 0),
                              0,
                              CGPointMake(kButtonSize, kButtonSize),
                              kButtonSize,
                              0);
  CGGradientRelease(gradient);
  gradient = nil;

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

- (UIImage *)backgroundForPinpointButton {
  CGRect imageRect = CGRectMake(0, 0, kButtonSize, kButtonSize);
  UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);

  CGContextRef cx = UIGraphicsGetCurrentContext();

  [[UIColor whiteColor] set];
  CGContextStrokeEllipseInRect(cx, CGRectInset(imageRect, 10, 10));

  CGFloat midX = CGRectGetMidX(imageRect);
  CGFloat midY = CGRectGetMidY(imageRect);
  CGContextBeginPath(cx);
  CGContextMoveToPoint(cx, midX, midY - kButtonSize / 2);
  CGContextAddLineToPoint(cx, midX, midY + kButtonSize / 2);
  CGContextMoveToPoint(cx, midX - kButtonSize / 2, midY);
  CGContextAddLineToPoint(cx, midX + kButtonSize / 2, midY);
  CGContextStrokePath(cx);

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

@end

#endif
