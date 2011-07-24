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

#import "NIOverviewerView.h"

#ifdef DEBUG

#import "NIDeviceInfo.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NIOverviewerView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  NI_RELEASE_SAFELY(_memoryLabel);
  
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _memoryLabel = [[UILabel alloc] init];
    UIImage* patternImage = [UIImage imageWithContentsOfFile:NIPathForBundleResource(nil, @"blueprint.gif")];
    self.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    _memoryLabel.backgroundColor = [UIColor clearColor];
    _memoryLabel.font = [UIFont boldSystemFontOfSize:12];
    _memoryLabel.textColor = [UIColor whiteColor];
    _memoryLabel.shadowColor = [UIColor blackColor];
    _memoryLabel.shadowOffset = CGSizeMake(0, 1);
    [self addSubview:_memoryLabel];
    
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(memoryTick)
                                   userInfo:nil repeats:YES];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)memoryTick {
  [NIDeviceInfo beginCachedDeviceInfo];
  
  _memoryLabel.text = [NSString stringWithFormat:
                       @"Remaining memory: %.2f MBs Total disk space: %.2f Free disk space: %.2f"
                       @" Battery percentage: %.2f Battery state: %d",
                       (((CGFloat)[NIDeviceInfo bytesOfFreeMemory] / 1024.0f) / 1024.0f),
                       (((CGFloat)[NIDeviceInfo bytesOfTotalDiskSpace] / 1024.0f) / 1024.0f),
                       (((CGFloat)[NIDeviceInfo bytesOfFreeDiskSpace] / 1024.0f) / 1024.0f),
                       [NIDeviceInfo batteryLevel] * 100, [NIDeviceInfo batteryState]];
  [_memoryLabel sizeToFit];
  
  [NIDeviceInfo endCachedDeviceInfo];
}


@end

#endif