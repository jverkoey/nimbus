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

#import <Foundation/Foundation.h>

// This class is only available in debug builds of the app.
#ifdef DEBUG

@interface NIDeviceInfo : NSObject

/**
 * The number of bytes in memory that are free.
 */
+ (unsigned long long)bytesOfFreeMemory;

/**
 * The total number of bytes of disk space.
 */
+ (unsigned long long)bytesOfTotalDiskSpace;

/**
 * The number of bytes free on disk.
 */
+ (unsigned long long)bytesOfFreeDiskSpace;

/**
 * The battery charge level in the range 0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown
 */
+ (CGFloat)batteryLevel;

/**
 * The current battery state.
 */
+ (UIDeviceBatteryState)batteryState;


#pragma mark Caching

/**
 * Fetches the current device's state and then caches it.
 *
 * All subsequent calls to NIDeviceInfo methods will use this cached information.
 *
 * This can be a useful way to freeze the device info at a moment in time.
 */
+ (BOOL)beginCachedDeviceInfo;

/**
 * Stop using the cache for the device info methods.
 */
+ (void)endCachedDeviceInfo;

@end

#endif
