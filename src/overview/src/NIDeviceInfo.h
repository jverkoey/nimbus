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
#import <UIKit/UIKit.h>

/**
 * Formats a number of bytes in a human-readable format.
 *
 * Will create a string showing the size in bytes, KBs, MBs, or GBs.
 */
NSString* NIStringFromBytes(unsigned long long bytes);


/**
 * An interface for accessing device information.
 *
 *      @ingroup Overview-Sensors
 *
 * This class is not meant to be instantiated. All methods are class implementations.
 *
 * This class aims to simplify the interface for collecting device information. The low-level
 * mach APIs provide a host of valuable information but it's often in formats that aren't
 * particularly ready for presentation.
 *
 *      @attention When using this class on the simulator, the values returned will reflect
 *                 those of the computer within which you're running the simulator, not the
 *                 simulated device. This is because the simulator is a first-class citizen
 *                 on the computer and has full access to your RAM and disk space.
 */
@interface NIDeviceInfo : NSObject

#pragma mark Memory /** @name Memory */

/**
 * The number of bytes in memory that are free.
 *
 * Calculated using the number of free pages of memory.
 */
+ (unsigned long long)bytesOfFreeMemory;

/**
 * The total number of bytes of memory.
 *
 * Calculated by adding together the number of free, wired, active, and inactive pages of memory.
 *
 * This value may change over time on the device due to the way iOS partitions available memory
 * for applications.
 */
+ (unsigned long long)bytesOfTotalMemory;

/**
 * Simulate low memory warning
 *
 * Don't use this in production because it uses private API
 */
+ (void)simulateLowMemoryWarning;

#pragma mark Disk Space /** @name Disk Space */

/**
 * The number of bytes free on disk.
 */
+ (unsigned long long)bytesOfFreeDiskSpace;

/**
 * The total number of bytes of disk space.
 */
+ (unsigned long long)bytesOfTotalDiskSpace;


#pragma mark Battery /** @name Battery */

/**
 * The battery charge level in the range 0 .. 1.0. -1.0 if UIDeviceBatteryStateUnknown.
 *
 * This is a thin wrapper for [[UIDevice currentDevice] batteryLevel].
 */
+ (CGFloat)batteryLevel;

/**
 * The current battery state.
 *
 * This is a thin wrapper for [[UIDevice currentDevice] batteryState].
 */
+ (UIDeviceBatteryState)batteryState;


#pragma mark Caching /** @name Caching */

/**
 * Fetches the device's current information and then caches it.
 *
 * All subsequent calls to NIDeviceInfo methods will use this cached information.
 *
 * This can be a useful way to freeze the device info at a moment in time.
 *
 * Example:
 *
 * @code
 *  [NIDeviceInfo beginCachedDeviceInfo];
 *
 *  // All calls to NIDeviceInfo methods here will use the information retrieved when
 *  // beginCachedDeviceInfo was called.
 *
 *  [NIDeviceInfo endCachedDeviceInfo];
 * @endcode
 */
+ (BOOL)beginCachedDeviceInfo;

/**
 * Stop using the cache for the device info methods.
 */
+ (void)endCachedDeviceInfo;


@end
