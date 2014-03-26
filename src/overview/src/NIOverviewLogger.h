//
// Copyright 2011-2014 NimbusKit
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

extern NSString* const NIOverviewLoggerDidAddDeviceLog;
extern NSString* const NIOverviewLoggerDidAddConsoleLog;
extern NSString* const NIOverviewLoggerDidAddEventLog;

@class NIOverviewDeviceLogEntry;
@class NIOverviewConsoleLogEntry;
@class NIOverviewEventLogEntry;

/**
 * The Overview logger.
 *
 * @ingroup Overview-Logger
 *
 * This object stores all of the historical information used to draw the graphs in the
 * Overview memory and disk pages, as well as the console log page.
 *
 * The primary log should be accessed by calling [NIOverview @link NIOverview::logger logger@endlink].
 */
@interface NIOverviewLogger : NSObject

#pragma mark Configuration Settings /** @name Configuration Settings */

/**
 * The oldest age of a memory or disk log entry.
 *
 * Log entries older than this number of seconds will be pruned from the log.
 *
 * By default this is 1 minute.
 */
@property (nonatomic, assign) NSTimeInterval oldestLogAge;


+ (NIOverviewLogger*)sharedLogger;


#pragma mark Adding Log Entries /** @name Adding Log Entries */

/**
 * Add a device log.
 *
 * This method will first prune expired entries and then add the new entry to the log.
 */
- (void)addDeviceLog:(NIOverviewDeviceLogEntry *)logEntry;

/**
 * Add a console log.
 *
 * This method will not prune console log entries.
 */
- (void)addConsoleLog:(NIOverviewConsoleLogEntry *)logEntry;

/**
 * Add a event log.
 *
 * This method will first prune expired entries and then add the new entry to the log.
 */
- (void)addEventLog:(NIOverviewEventLogEntry *)logEntry;


#pragma mark Accessing Logs /** @name Accessing Logs */

/**
 * The linked list of device logs.
 *
 * Log entries are in increasing chronological order.
 */
@property (nonatomic, readonly, strong) NSMutableOrderedSet* deviceLogs;

/**
 * The linked list of console logs.
 *
 * Log entries are in increasing chronological order.
 */
@property (nonatomic, readonly, strong) NSMutableOrderedSet* consoleLogs;

/**
 * The linked list of events.
 *
 * Log entries are in increasing chronological order.
 */
@property (nonatomic, readonly, strong) NSMutableOrderedSet* eventLogs;

@end


/**
 * The basic requirements for a log entry.
 *
 * @ingroup Overview-Logger-Entries
 *
 * A basic log entry need only define a timestamp in order to be particularly useful.
 */
@interface NIOverviewLogEntry : NSObject

#pragma mark Creating an Entry /** @name Creating an Entry */

/**
 * Designated initializer.
 */
- (id)initWithTimestamp:(NSDate *)timestamp;


#pragma mark Entry Information /** @name Entry Information */

/**
 * The timestamp for this log entry.
 */
@property (nonatomic, retain) NSDate* timestamp;

@end


/**
 * A device log entry.
 *
 * @ingroup Overview-Logger-Entries
 */
@interface NIOverviewDeviceLogEntry : NIOverviewLogEntry

#pragma mark Entry Information /** @name Entry Information */

/**
 * The number of bytes of free memory.
 */
@property (nonatomic, assign) unsigned long long bytesOfFreeMemory;

/**
 * The number of bytes of total memory.
 */
@property (nonatomic, assign) unsigned long long bytesOfTotalMemory;

/**
 * The number of bytes of free disk space.
 */
@property (nonatomic, assign) unsigned long long bytesOfFreeDiskSpace;

/**
 * The number of bytes of total disk space.
 */
@property (nonatomic, assign) unsigned long long bytesOfTotalDiskSpace;

/**
 * The battery level.
 */
@property (nonatomic, assign) CGFloat batteryLevel;

/**
 * The state of the battery.
 */
@property (nonatomic, assign) UIDeviceBatteryState batteryState;

@end


/**
 * A console log entry.
 *
 * @ingroup Overview-Logger-Entries
 */
@interface NIOverviewConsoleLogEntry : NIOverviewLogEntry

#pragma mark Creating an Entry /** @name Creating an Entry */

/**
 * Designated initializer.
 */
- (id)initWithLog:(NSString *)log;


#pragma mark Entry Information /** @name Entry Information */

/**
 * The text that was written to the console log.
 */
@property (nonatomic, copy) NSString* log;

@end


typedef enum {
  NIOverviewEventDidReceiveMemoryWarning,
} NIOverviewEventType;

/**
 * An event log entry.
 *
 * @ingroup Overview-Logger-Entries
 */
@interface NIOverviewEventLogEntry : NIOverviewLogEntry

#pragma mark Creating an Entry /** @name Creating an Entry */

/**
 * Designated initializer.
 */
- (id)initWithType:(NSInteger)type;


#pragma mark Entry Information /** @name Entry Information */

/**
 * The type of event.
 */
@property (nonatomic, assign) NSInteger type;

@end
