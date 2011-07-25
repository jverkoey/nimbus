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

#import "NIDeviceInfo.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerPageView

@synthesize pageTitle = _pageTitle;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_pageTitle);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NIOverviewerPageView *)page {
  return [[[[self class] alloc] initWithFrame:CGRectZero] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  // No-op.
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerMemoryPageView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _memoryLabel = nil;
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.pageTitle = NSLocalizedString(@"Memory", @"Overview Page Title: Memory");

    self.clipsToBounds = YES;

    _memoryLabel = [[[UILabel alloc] init] autorelease];
    _memoryLabel.backgroundColor = [UIColor clearColor];
    _memoryLabel.font = [UIFont boldSystemFontOfSize:12];
    _memoryLabel.textColor = [UIColor whiteColor];
    _memoryLabel.shadowColor = [UIColor blackColor];
    _memoryLabel.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:_memoryLabel];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update {
  [NIDeviceInfo beginCachedDeviceInfo];
  
  _memoryLabel.text = [NSString stringWithFormat:
                       @"Remaining memory: %@ Total disk space: %@ Free disk space: %@"
                       @" Battery percentage: %.2f Battery state: %d",
                       NIStringFromBytes([NIDeviceInfo bytesOfFreeMemory]),
                       NIStringFromBytes([NIDeviceInfo bytesOfTotalDiskSpace]),
                       NIStringFromBytes([NIDeviceInfo bytesOfFreeDiskSpace]),
                       [NIDeviceInfo batteryLevel] * 100, [NIDeviceInfo batteryState]];
  [_memoryLabel sizeToFit];
  
  [NIDeviceInfo endCachedDeviceInfo];
}


@end

#endif