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

#ifdef NIMBUS_STATIC_LIBRARY
#import "NimbusCore/NimbusCore.h"
#else
#import "NimbusCore.h"
#endif

extern NSString* const NIOverviewerLoggerDidAddConsoleLog;

@class NIOverviewerDeviceLogEntry;
@class NIOverviewerConsoleLogEntry;
@class NIOverviewerEventLogEntry;

@interface NIOverviewerLogger : NSObject {
@private
  NILinkedList* _deviceLogs;
  NILinkedList* _consoleLogs;
  NILinkedList* _eventLogs;
  NSTimeInterval _oldestLogAge;
}

/**
 * The oldest age of a log item.
 *
 * Log items older than this amount will be pruned from the log.
 *
 * By default this is 1 minute.
 */
@property (nonatomic, readwrite, assign) NSTimeInterval oldestLogAge;

/**
 * Add a device log.
 */
- (void)addDeviceLog:(NIOverviewerDeviceLogEntry *)logEntry;

/**
 * Add a console log.
 */
- (void)addConsoleLog:(NIOverviewerConsoleLogEntry *)logEntry;

/**
 * Add a event log.
 */
- (void)addEventLog:(NIOverviewerEventLogEntry *)logEntry;

@property (nonatomic, readonly, retain) NILinkedList* deviceLogs;
@property (nonatomic, readonly, retain) NILinkedList* consoleLogs;
@property (nonatomic, readonly, retain) NILinkedList* eventLogs;

@end


/**
 * The basic requirements for a log entry.
 */
@interface NIOverviewerLogEntry : NSObject {
@private
  NSDate* _timestamp;
}

/**
 * The timestamp for this log entry.
 */
@property (nonatomic, readwrite, retain) NSDate* timestamp;

/**
 * Designated initializer.
 */
- (id)initWithTimestamp:(NSDate *)timestamp;

@end


/**
 * A device log entry.
 */
@interface NIOverviewerDeviceLogEntry : NIOverviewerLogEntry {
@private
  unsigned long long _bytesOfFreeMemory;
  unsigned long long _bytesOfTotalMemory;
  unsigned long long _bytesOfTotalDiskSpace;
  unsigned long long _bytesOfFreeDiskSpace;

  CGFloat _batteryLevel;
  UIDeviceBatteryState _batteryState;
}

@property (nonatomic, readwrite, assign) unsigned long long bytesOfFreeMemory;
@property (nonatomic, readwrite, assign) unsigned long long bytesOfTotalMemory;
@property (nonatomic, readwrite, assign) unsigned long long bytesOfTotalDiskSpace;
@property (nonatomic, readwrite, assign) unsigned long long bytesOfFreeDiskSpace;
@property (nonatomic, readwrite, assign) CGFloat batteryLevel;
@property (nonatomic, readwrite, assign) UIDeviceBatteryState batteryState;

@end

/**
 * A console log entry.
 */
@interface NIOverviewerConsoleLogEntry : NIOverviewerLogEntry {
@private
  NSString* _log;
}

/**
 * Designated initializer.
 */
- (id)initWithLog:(NSString *)log;

@property (nonatomic, readwrite, copy) NSString* log;

@end

typedef enum {
  NIOverviewerEventDidReceiveMemoryWarning,
} NIOverviewerEventType;

/**
 * A console log entry.
 */
@interface NIOverviewerEventLogEntry : NIOverviewerLogEntry {
@private
  NSInteger _eventType;
}

/**
 * Designated initializer.
 */
- (id)initWithType:(NSInteger)type;

@property (nonatomic, readwrite, assign) NSInteger type;

@end
